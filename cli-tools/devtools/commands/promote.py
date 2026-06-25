from __future__ import annotations

import shutil
from pathlib import Path

import click

# ---------------------------------------------------------------------------
# Namespace → relative path inside the devkit skills/ folder
# ---------------------------------------------------------------------------

TECH_NAMESPACES: dict[str, str] = {
    "python":         "backend/python",
    "kotlin":         "backend/kotlin-ktor",
    "kotlin-ktor":    "backend/kotlin-ktor",
    "spring":         "backend/spring-java",
    "spring-java":    "backend/spring-java",
    "android":        "android/compose",
    "android-compose":"android/compose",
    "android-legacy": "android/legacy",
    "ios":            "ios/swiftui",
    "ios-swiftui":    "ios/swiftui",
    "ios-uikit":      "ios/uikit",
    "kmp":            "multiplatform/kmp",
    "cmp":            "multiplatform/cmp",
    "global":         "global",
}


def _find_devkit_root() -> Path:
    """Walk up from this file to find the devkit repo root (has skills/ and agents/)."""
    candidate = Path(__file__).resolve()
    for parent in candidate.parents:
        if (parent / "skills").is_dir() and (parent / "agents").is_dir():
            return parent
    raise click.ClickException(
        "No se encontró el root del devkit (directorio con skills/ y agents/). "
        "Ejecuta el comando desde dentro del repo devkit o de un proyecto conectado."
    )


def _resolve_skill_source(skill_name: str, project_root: Path) -> Path:
    """Return the skill folder inside the project's .github/skills/."""
    candidates = [
        project_root / ".github" / "skills" / skill_name,
        project_root / "skills" / skill_name,
    ]
    for path in candidates:
        if path.is_dir():
            return path
    raise click.ClickException(
        f"No se encontró la skill '{skill_name}' en:\n"
        + "\n".join(f"  {p}" for p in candidates)
    )


def _validate_skill_structure(skill_path: Path) -> None:
    """Minimal structure check: SKILL.md must exist."""
    if not (skill_path / "SKILL.md").exists():
        raise click.ClickException(
            f"La skill en '{skill_path}' no tiene SKILL.md. "
            "Asegúrate de que está completa antes de promoverla."
        )


# ---------------------------------------------------------------------------
# Command
# ---------------------------------------------------------------------------

@click.command("promote")
@click.argument("skill_name")
@click.option(
    "--tech",
    required=True,
    type=click.Choice(list(TECH_NAMESPACES.keys()), case_sensitive=False),
    help="Namespace de tecnología destino (ej. python, kotlin, ios-swiftui, global).",
)
@click.option(
    "--project",
    "project_dir",
    default=".",
    show_default=True,
    help="Ruta al proyecto consumidor. Por defecto: directorio actual.",
)
@click.option(
    "--dry-run",
    is_flag=True,
    default=False,
    help="Muestra las operaciones sin ejecutarlas.",
)
def promote(skill_name: str, tech: str, project_dir: str, dry_run: bool) -> None:
    """Promueve una skill de proyecto al devkit (tech o global) y crea el symlink.

    SKILL_NAME es el nombre de la carpeta bajo .github/skills/ del proyecto.

    \b
    Flujo:
      1. Localiza la skill en el proyecto consumidor
      2. Copia la carpeta al devkit bajo skills/<tech-namespace>/<skill-name>/
      3. Elimina la copia local y sustituye por un symlink → devkit
      4. Crea symlink global en ~/.copilot/skills/ (para VS Code Copilot)

    \b
    Ejemplos:
      devtools promote devkit-auth-flow --tech python
      devtools promote devkit-retry-policy --tech kotlin --project ../mi-proyecto
      devtools promote devkit-ci-conventions --tech global
    """
    project_root = Path(project_dir).resolve()
    devkit_root = _find_devkit_root()
    tech_path = TECH_NAMESPACES[tech.lower()]

    # Source: skill folder inside the project
    source_path = _resolve_skill_source(skill_name, project_root)
    _validate_skill_structure(source_path)

    # Destination inside devkit
    devkit_dest = devkit_root / "skills" / tech_path / skill_name

    # Symlink that will replace the local copy
    project_link = source_path  # will become a symlink

    # Global symlink for VS Code Copilot
    global_link = Path.home() / ".copilot" / "skills" / skill_name

    # -----------------------------------------------------------------------
    click.echo(f"\n📦  Promoviendo '{skill_name}' → {tech_path}/")
    click.echo(f"    Origen:   {source_path}")
    click.echo(f"    Destino:  {devkit_dest}")
    click.echo(f"    Symlink proyecto: {project_link} → {devkit_dest}")
    click.echo(f"    Symlink global:   {global_link} → {devkit_dest}\n")

    if dry_run:
        click.echo("ℹ️  --dry-run activo. No se ha modificado nada.")
        return

    # 1. Check destination doesn't already exist
    if devkit_dest.exists():
        raise click.ClickException(
            f"Ya existe '{devkit_dest}' en el devkit. "
            "Borra o renombra la carpeta antes de promover."
        )

    # 2. Copy skill to devkit
    shutil.copytree(source_path, devkit_dest)
    click.echo(f"✅  Copiada al devkit: {devkit_dest}")

    # 3. Replace local folder with symlink → devkit
    shutil.rmtree(source_path)
    project_link.symlink_to(devkit_dest)
    click.echo(f"🔗  Symlink creado en proyecto: {project_link}")

    # 4. Create / update global symlink (~/.copilot/skills/)
    global_skills_dir = Path.home() / ".copilot" / "skills"
    global_skills_dir.mkdir(parents=True, exist_ok=True)

    if global_link.is_symlink():
        global_link.unlink()
    if not global_link.exists():
        global_link.symlink_to(devkit_dest)
        click.echo(f"🔗  Symlink global creado: {global_link}")
    else:
        click.echo(f"⚠️  Ya existe (no es symlink): {global_link} — omitido")

    click.echo(
        f"\n✅  '{skill_name}' promovida a {tech_path}/\n"
        f"    → Disponible para todos los proyectos via `devtools sync`\n"
        f"    → Accesible en VS Code Copilot desde cualquier workspace"
    )
