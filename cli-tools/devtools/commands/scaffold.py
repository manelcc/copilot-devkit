from __future__ import annotations

import re
import shutil
from pathlib import Path

import click


def _find_repo_root(start: Path) -> Path:
    """Find repository root by walking up until key folders are present."""
    for candidate in [start, *start.parents]:
        if (candidate / "skills").is_dir() and (candidate / "scripts").is_dir():
            return candidate
    raise click.ClickException(
        "No se pudo localizar la raíz del repositorio (faltan carpetas 'skills' y/o 'scripts')."
    )


def _replace_placeholders(text: str, skill_name: str, namespace: str) -> str:
    """Replace documented placeholders and normalize template name if needed."""
    replaced = text.replace("[Name]", skill_name).replace("[namespace]", namespace)

    # Template hardcodes a sample name; replace it for scaffolded skills.
    replaced = re.sub(
        r'^name:\s*"[^"]+"\s*$',
        f'name: "{skill_name}"',
        replaced,
        flags=re.MULTILINE,
    )
    return replaced


@click.group()
def scaffold() -> None:
    """Genera la estructura base de nuevos artefactos."""


@scaffold.command("skill")
@click.argument("name")
@click.argument("namespace")
def scaffold_skill(name: str, namespace: str) -> None:
    """Crea una skill desde skills/_TEMPLATE en el namespace indicado."""
    skill_name = name.strip()
    normalized_namespace = namespace.strip().strip("/")

    if not skill_name:
        raise click.ClickException("El nombre de la skill no puede estar vacío.")

    if "/" in skill_name:
        raise click.ClickException("El nombre de la skill no puede contener '/'.")

    cwd = Path.cwd()
    repo_root = _find_repo_root(cwd)
    skills_root = repo_root / "skills"
    template_root = skills_root / "_TEMPLATE"

    if not template_root.is_dir():
        raise click.ClickException(f"No existe el template de skills en '{template_root}'.")

    namespace_root = skills_root / normalized_namespace
    if not namespace_root.is_dir():
        raise click.ClickException(
            f"Namespace no existe: '{normalized_namespace}'. Usa una ruta válida bajo 'skills/'."
        )

    destination_root = namespace_root / skill_name
    if destination_root.exists():
        raise click.ClickException(
            f"La skill '{skill_name}' ya existe en namespace '{normalized_namespace}'."
        )

    shutil.copytree(template_root, destination_root)

    skill_md_path = destination_root / "SKILL.md"
    if skill_md_path.is_file():
        original = skill_md_path.read_text(encoding="utf-8")
        updated = _replace_placeholders(
            text=original,
            skill_name=skill_name,
            namespace=normalized_namespace,
        )
        skill_md_path.write_text(updated, encoding="utf-8")

    click.echo(f"✓ Skill creada en {skill_md_path}")
