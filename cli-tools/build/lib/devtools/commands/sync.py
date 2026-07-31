from __future__ import annotations

import hashlib
import json
import shutil
from datetime import datetime, timezone
from pathlib import Path

import click

MANIFEST_FILE = "devtools.manifest.json"
LOCK_FILE = "devtools.lock.json"


# ---------------------------------------------------------------------------
# Incompatibility detection (US-086)
# ---------------------------------------------------------------------------

def _build_manifest_keys(manifest: dict) -> set[str]:
    """Return the set of artifact keys declared in the manifest."""
    keys: set[str] = set()
    for artifact in manifest.get("artifacts", []):
        artifact_type = artifact.get("type", "skills")
        namespace = artifact.get("namespace", "")
        for item in artifact.get("items", []):
            key = f"{artifact_type}/{namespace}/{item}".strip("/").replace("//", "/")
            keys.add(key)
    return keys


def _check_incompatibilities(
    manifest: dict, source_base: Path, lock_data: dict
) -> list[str]:
    """
    Return a list of incompatibility messages.
    Checks:
      1. Missing 'requires' dependencies — an artifact needs another not in the manifest.
      2. Orphaned lock entries — artifacts in the lock that were removed from the manifest.
      3. Invalid source paths — items declared in the manifest that don't exist in source.
    """
    issues: list[str] = []
    manifest_keys = _build_manifest_keys(manifest)

    for artifact in manifest.get("artifacts", []):
        artifact_type = artifact.get("type", "skills")
        namespace = artifact.get("namespace", "")
        base = (
            source_base / artifact_type / namespace
            if namespace
            else source_base / artifact_type
        )

        for item in artifact.get("items", []):
            # 1. Check requires dependencies
            for req in artifact.get("requires", []):
                if req not in manifest_keys:
                    issues.append(
                        f"'{item}' requiere '{req}' pero ese artefacto no está en el manifest"
                    )

            # 2. Validate source path exists
            source_path = base / item
            if not source_path.exists():
                issues.append(
                    f"'{item}' (type={artifact_type}, namespace={namespace or '—'}) "
                    f"no existe en source: '{source_path}'"
                )

    # 3. Orphaned lock entries
    lock_artifacts: list[dict] = lock_data.get("artifacts", [])
    for entry in lock_artifacts:
        key = entry.get("artifact", "")
        if key and key not in manifest_keys:
            issues.append(
                f"Artefacto '{key}' está en el lock pero ya no aparece en el manifest "
                f"(puede haber sido eliminado; usa --force para limpiar el lock)"
            )

    return issues


def _sha256(path: Path) -> str:
    """Return first 8 chars of SHA-256 for a file or a directory tree."""
    h = hashlib.sha256()
    if path.is_file():
        h.update(path.read_bytes())
    elif path.is_dir():
        for f in sorted(path.rglob("*")):
            if f.is_file():
                h.update(f.read_bytes())
    return h.hexdigest()[:8]


def _load_manifest(manifest_file: Path) -> dict:
    try:
        return json.loads(manifest_file.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise click.ClickException(
            f"JSON inválido en '{manifest_file}': {exc}"
        ) from exc


def _load_lock(lock_path: Path) -> dict:
    if not lock_path.exists():
        return {}
    try:
        return json.loads(lock_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}


def _save_lock(lock_path: Path, lock_data: dict) -> None:
    lock_path.write_text(
        json.dumps(lock_data, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


def _resolve_items(source_base: Path, artifact: dict) -> list[tuple[str, Path]]:
    """Return (item_name, abs_source_path) for each item in an artifact entry."""
    artifact_type = artifact.get("type", "skills")
    namespace = artifact.get("namespace", "")
    base = source_base / artifact_type / namespace if namespace else source_base / artifact_type
    return [(item, base / item) for item in artifact.get("items", [])]


@click.command()
@click.option(
    "--manifest",
    "manifest_path",
    default=MANIFEST_FILE,
    show_default=True,
    help="Ruta al archivo devtools.manifest.json.",
)
@click.option("--dry-run", is_flag=True, help="Muestra qué se copiaría sin aplicar cambios.")
@click.option("--force", is_flag=True, help="Sobreescribe cambios locales sin preguntar.")
def sync(manifest_path: str, dry_run: bool, force: bool) -> None:
    """Importa artefactos desde DevTools-AI según devtools.manifest.json."""
    manifest_file = Path(manifest_path)
    if not manifest_file.exists():
        raise click.ClickException(
            f"No se encontró '{manifest_path}'. "
            "Crea un devtools.manifest.json en la raíz del proyecto consumidor."
        )

    manifest = _load_manifest(manifest_file)

    source_cfg = manifest.get("source", {})
    if source_cfg.get("type") != "local":
        raise click.ClickException(
            "Solo se soporta source.type='local' en esta versión."
        )

    source_base = Path(source_cfg.get("path", ""))
    if not source_base.is_dir():
        raise click.ClickException(f"source.path no existe o no es un directorio: '{source_base}'")

    sync_cfg = manifest.get("sync", {})
    destination_base = Path(sync_cfg.get("destination_base", ".github"))

    lock_path = Path(LOCK_FILE)
    lock_data = _load_lock(lock_path)
    lock_index: dict[str, dict] = {
        a["artifact"]: a for a in lock_data.get("artifacts", [])
    }

    # --- Incompatibility check (US-086) ---
    incompatibilities = _check_incompatibilities(manifest, source_base, lock_data)
    if incompatibilities:
        if not force:
            msg_lines = "\n  ".join(incompatibilities)
            raise click.ClickException(
                f"Se detectaron {len(incompatibilities)} incompatibilidad(es). "
                f"Usa --force para continuar de todas formas:\n  {msg_lines}"
            )
        else:
            for issue in incompatibilities:
                click.echo(f"  [WARN] incompatibilidad (ignorada por --force): {issue}")

    newly_synced: list[dict] = []
    warnings: int = 0

    for artifact in manifest.get("artifacts", []):
        destination_rel = artifact.get("destination", "")
        dest_base = destination_base / destination_rel if destination_rel else destination_base

        for item_name, source_path in _resolve_items(source_base, artifact):
            artifact_type = artifact.get("type", "skills")
            namespace = artifact.get("namespace", "")
            artifact_key = f"{artifact_type}/{namespace}/{item_name}".strip("/").replace("//", "/")
            dest_path = dest_base / item_name

            if not source_path.exists():
                click.echo(f"  [WARN] '{source_path}' no encontrado en source — saltando")
                warnings += 1
                continue

            source_sha = _sha256(source_path)
            prev = lock_index.get(artifact_key)

            # Skip if nothing changed since last sync
            if prev and prev.get("source_sha") == source_sha and dest_path.exists() and not force:
                continue

            # Conflict: dest was modified locally after last sync
            if dest_path.exists() and not dry_run and not force and prev is not None:
                dest_sha = _sha256(dest_path)
                if dest_sha != prev.get("source_sha"):
                    answer = click.prompt(
                        f"  '{dest_path}' tiene cambios locales. ¿Sobrescribir? [y/N]",
                        default="N",
                    )
                    if answer.strip().lower() != "y":
                        click.echo(f"  [SKIP] Conservando '{dest_path}'")
                        continue

            if dry_run:
                click.echo(f"  [DRY-RUN] Copiaría: '{source_path}' → '{dest_path}'")
            else:
                dest_path.parent.mkdir(parents=True, exist_ok=True)
                if source_path.is_dir():
                    if dest_path.exists():
                        shutil.rmtree(dest_path)
                    shutil.copytree(source_path, dest_path)
                else:
                    shutil.copy2(source_path, dest_path)
                click.echo(f"  [OK] {artifact_key} → '{dest_path}'")

            newly_synced.append({
                "artifact": artifact_key,
                "source_sha": source_sha,
                "destination": str(dest_path),
                "synced_at": datetime.now(timezone.utc).isoformat(),
            })

    if not newly_synced and not dry_run:
        if warnings == 0:
            click.echo("✓ Todo sincronizado, nada que hacer")
        return

    if not dry_run and newly_synced:
        updated_keys = {e["artifact"] for e in newly_synced}
        preserved = [a for a in lock_data.get("artifacts", []) if a["artifact"] not in updated_keys]
        new_lock = {
            "synced_at": datetime.now(timezone.utc).isoformat(),
            "artifacts": preserved + newly_synced,
        }
        _save_lock(lock_path, new_lock)
        click.echo(
            f"\n✓ {len(newly_synced)} artefacto(s) sincronizado(s). Lock actualizado: '{lock_path}'"
        )
    elif dry_run:
        click.echo(f"\n[DRY-RUN] {len(newly_synced)} artefacto(s) se copiarían.")
