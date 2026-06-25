from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

import click

# Repo root: cli-tools/devtools/commands/ → cli-tools/devtools/ → cli-tools/ → repo root
_REPO_ROOT = Path(__file__).parents[3]

_FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---", re.DOTALL)


def _parse_frontmatter(text: str) -> tuple[dict[str, Any], list[str]]:
    """Return (parsed dict, warnings). Gracefully handles missing or invalid frontmatter."""
    warnings: list[str] = []
    match = _FRONTMATTER_RE.match(text)
    if not match:
        warnings.append("sin frontmatter")
        return {}, warnings
    raw = match.group(1)
    try:
        import yaml  # optional; only available if installed
        data: dict[str, Any] = yaml.safe_load(raw) or {}
    except ImportError:
        # Minimal key: value parser when PyYAML is not available
        data = {}
        for line in raw.splitlines():
            if ":" in line and not line.startswith(" "):
                k, _, v = line.partition(":")
                data[k.strip()] = v.strip()
    except Exception as exc:
        warnings.append(f"frontmatter inválido: {exc}")
        data = {}
    return data, warnings


def _derive_status(text: str, fm: dict[str, Any]) -> str:
    """Infer artifact status from content heuristics."""
    if not fm.get("name") and not fm.get("description"):
        return "pendiente"
    content_upper = text.upper()
    if "TODO" in content_upper or "[UPPERCASE]" in text or "[UPPER" in text:
        return "en progreso"
    return "disponible"


def _truncate(value: str, max_len: int) -> str:
    return value[:max_len] + ("…" if len(value) > max_len else "")


# ---------------------------------------------------------------------------
# Scanners
# ---------------------------------------------------------------------------

def _scan_skills(
    repo_root: Path, namespace_filter: str | None
) -> tuple[list[dict[str, str]], list[str]]:
    items: list[dict[str, str]] = []
    warnings: list[str] = []
    skills_dir = repo_root / "skills"
    if not skills_dir.exists():
        return items, warnings
    for skill_md in sorted(skills_dir.rglob("SKILL.md")):
        rel = skill_md.parent.relative_to(skills_dir)
        parts = rel.parts
        namespace = parts[0] if parts else "global"
        name = parts[-1] if len(parts) >= 2 else (parts[0] if parts else skill_md.parent.name)
        if namespace_filter and namespace != namespace_filter:
            continue
        try:
            text = skill_md.read_text(encoding="utf-8")
            fm, warns = _parse_frontmatter(text)
            for w in warns:
                warnings.append(f"skills/{rel}/SKILL.md: {w}")
        except Exception as exc:
            warnings.append(f"skills/{rel}/SKILL.md: error de lectura — {exc}")
            fm, text = {}, ""
        desc = str(fm.get("description") or "").strip().replace("\n", " ")
        items.append({
            "type": "skill",
            "namespace": namespace,
            "name": name,
            "status": _derive_status(text, fm),
            "description": _truncate(desc, 70),
        })
    return items, warnings


def _scan_agents(
    repo_root: Path, namespace_filter: str | None
) -> tuple[list[dict[str, str]], list[str]]:
    items: list[dict[str, str]] = []
    warnings: list[str] = []
    agents_dir = repo_root / "agents"
    if not agents_dir.exists():
        return items, warnings
    for agent_md in sorted(agents_dir.rglob("*.agent.md")):
        rel = agent_md.relative_to(agents_dir)
        parts = rel.parts
        namespace = parts[0] if len(parts) >= 2 else "global"
        name = agent_md.name.removesuffix(".agent.md")
        if namespace_filter and namespace != namespace_filter:
            continue
        try:
            text = agent_md.read_text(encoding="utf-8")
            fm, warns = _parse_frontmatter(text)
            for w in warns:
                warnings.append(f"agents/{rel}: {w}")
        except Exception as exc:
            warnings.append(f"agents/{rel}: error de lectura — {exc}")
            fm, text = {}, ""
        desc = str(fm.get("description") or "").strip().replace("\n", " ")
        items.append({
            "type": "agent",
            "namespace": namespace,
            "name": name,
            "status": _derive_status(text, fm),
            "description": _truncate(desc, 70),
        })
    return items, warnings


def _scan_instructions(
    repo_root: Path, namespace_filter: str | None
) -> tuple[list[dict[str, str]], list[str]]:
    items: list[dict[str, str]] = []
    warnings: list[str] = []
    instructions_dir = repo_root / "instructions"
    if not instructions_dir.exists():
        return items, warnings
    for instr_md in sorted(instructions_dir.glob("devkit-*.instructions.md")):
        stem = instr_md.stem  # e.g. "devkit-android-compose.instructions"
        after_devkit = stem.removeprefix("devkit-").removesuffix(".instructions")
        # namespace = first segment after 'devkit-'
        namespace = after_devkit.split("-")[0] if "-" in after_devkit else after_devkit
        if namespace_filter and namespace != namespace_filter:
            continue
        try:
            text = instr_md.read_text(encoding="utf-8")
            fm, warns = _parse_frontmatter(text)
            for w in warns:
                warnings.append(f"instructions/{instr_md.name}: {w}")
        except Exception as exc:
            warnings.append(f"instructions/{instr_md.name}: error de lectura — {exc}")
            fm, text = {}, ""
        desc = str(fm.get("description") or f"Instrucciones para {after_devkit}").strip()
        items.append({
            "type": "instructions",
            "namespace": namespace,
            "name": instr_md.name.removesuffix(".md"),
            "status": _derive_status(text, fm),
            "description": _truncate(desc, 70),
        })
    return items, warnings


# ---------------------------------------------------------------------------
# Output rendering
# ---------------------------------------------------------------------------

def _print_table(items: list[dict[str, str]]) -> None:
    if not items:
        click.echo("(sin resultados)")
        return
    col_type = max(len("TIPO"), max(len(i["type"]) for i in items))
    col_ns = max(len("NAMESPACE"), max(len(i["namespace"]) for i in items))
    col_name = max(len("NOMBRE"), max(len(i["name"]) for i in items))
    col_status = max(len("ESTADO"), max(len(i["status"]) for i in items))
    col_desc = 62

    header = (
        f"{'TIPO':<{col_type}}  {'NAMESPACE':<{col_ns}}  "
        f"{'NOMBRE':<{col_name}}  {'ESTADO':<{col_status}}  DESCRIPCIÓN"
    )
    sep = "-" * (col_type + col_ns + col_name + col_status + col_desc + 8)
    click.echo(header)
    click.echo(sep)
    for item in items:
        click.echo(
            f"{item['type']:<{col_type}}  {item['namespace']:<{col_ns}}  "
            f"{item['name']:<{col_name}}  {item['status']:<{col_status}}  "
            f"{item['description'][:col_desc]}"
        )


# ---------------------------------------------------------------------------
# Command
# ---------------------------------------------------------------------------

@click.command("list")
@click.option(
    "--namespace",
    default=None,
    help="Filtra por namespace (global, android, ios, backend, multiplatform, etc.).",
)
@click.option(
    "--type",
    "artifact_type",
    default=None,
    type=click.Choice(["skill", "agent", "instructions"], case_sensitive=False),
    help="Filtra por tipo de artefacto.",
)
@click.option(
    "--format",
    "output_format",
    default="table",
    show_default=True,
    type=click.Choice(["table", "json"], case_sensitive=False),
    help="Formato de salida.",
)
@click.option(
    "--repo",
    "repo_path",
    default=None,
    help="Ruta raíz del repo DevTools-AI (por defecto, autodetectada desde la ubicación del CLI).",
)
def list_cmd(
    namespace: str | None,
    artifact_type: str | None,
    output_format: str,
    repo_path: str | None,
) -> None:
    """Lista los artefactos disponibles en DevTools-AI (skills, agentes, instrucciones)."""
    repo_root = Path(repo_path) if repo_path else _REPO_ROOT
    if not repo_root.is_dir():
        raise click.ClickException(f"Ruta de repo no encontrada: '{repo_root}'")

    all_items: list[dict[str, str]] = []
    all_warnings: list[str] = []

    scanners = {
        "skill": _scan_skills,
        "agent": _scan_agents,
        "instructions": _scan_instructions,
    }

    active_scanners = (
        {artifact_type: scanners[artifact_type]} if artifact_type and artifact_type in scanners
        else scanners
    )

    for scanner in active_scanners.values():
        items, warns = scanner(repo_root, namespace)
        all_items.extend(items)
        all_warnings.extend(warns)

    if output_format == "json":
        click.echo(json.dumps(all_items, ensure_ascii=False, indent=2))
    else:
        _print_table(all_items)
        click.echo(f"\nTotal: {len(all_items)} artefacto(s)")

    if all_warnings:
        for w in all_warnings:
            click.echo(f"[WARN] {w}", err=True)
