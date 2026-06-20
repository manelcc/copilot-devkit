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


def _replace_placeholders(text: str, name: str, namespace: str) -> str:
    """Replace documented placeholders and normalize template name if needed."""
    replaced = text.replace("[Name]", name).replace("[namespace]", namespace)

    # Template hardcodes a sample name; replace it for scaffolded artifacts.
    replaced = re.sub(
        r'^name:\s*"[^"]+"\s*$',
        f'name: "{name}"',
        replaced,
        flags=re.MULTILINE,
    )
    replaced = re.sub(
        r'^title:\s*"[^"]+"\s*$',
        f'title: "{name}"',
        replaced,
        flags=re.MULTILINE,
    )
    return replaced


def _scaffold_artifact(artifact_type: str, name: str, namespace: str | None = None) -> None:
    """Generic artifact scaffolding logic for skills, instructions, and prompts."""
    artifact_name = name.strip()
    
    if not artifact_name:
        raise click.ClickException(f"El nombre del {artifact_type} no puede estar vacío.")

    if "/" in artifact_name:
        raise click.ClickException(f"El nombre del {artifact_type} no puede contener '/'.")

    cwd = Path.cwd()
    repo_root = _find_repo_root(cwd)

    # Determine paths based on artifact type
    if artifact_type == "skill":
        if not namespace:
            raise click.ClickException("namespace es requerido para skills")
        normalized_namespace = namespace.strip().strip("/")
        root = repo_root / "skills"
        namespace_root = root / normalized_namespace
        template_root = root / "_TEMPLATE"
        destination_root = namespace_root / artifact_name
        
        if not namespace_root.is_dir():
            raise click.ClickException(
                f"Namespace no existe: '{normalized_namespace}'. Usa una ruta válida bajo 'skills/'."
            )
    
    elif artifact_type == "instruction":
        root = repo_root / "instructions"
        template_root = root / "_TEMPLATE"
        # Instructions are flat (no namespace)
        destination_root = root / f"{artifact_name}.instructions.md"
        normalized_namespace = "instructions"
    
    elif artifact_type == "prompt":
        if not namespace:
            raise click.ClickException("namespace es requerido para prompts")
        normalized_namespace = namespace.strip().strip("/")
        root = repo_root / "prompts"
        namespace_root = root / normalized_namespace
        template_root = root / "_TEMPLATE"
        destination_root = namespace_root / f"{artifact_name}.prompt.md"
        
        if not namespace_root.is_dir():
            raise click.ClickException(
                f"Namespace no existe: '{normalized_namespace}'. Usa una ruta válida bajo 'prompts/'."
            )
    
    else:
        raise click.ClickException(f"Tipo de artefacto no soportado: {artifact_type}")

    # Verify template exists
    if not template_root.is_dir():
        raise click.ClickException(f"No existe el template de {artifact_type}s en '{template_root}'.")

    # Check if artifact already exists
    if destination_root.exists():
        raise click.ClickException(
            f"El {artifact_type} '{artifact_name}' ya existe en '{destination_root}'."
        )

    # Copy template
    if artifact_type == "skill":
        shutil.copytree(template_root, destination_root)
        main_file = destination_root / "SKILL.md"
    elif artifact_type == "instruction":
        template_file = next(template_root.glob("*.md"), None)
        if not template_file:
            raise click.ClickException(f"No se encontró archivo template en {template_root}")
        shutil.copy2(template_file, destination_root)
        main_file = destination_root
    elif artifact_type == "prompt":
        template_file = next(template_root.glob("*.md"), None)
        if not template_file:
            raise click.ClickException(f"No se encontró archivo template en {template_root}")
        shutil.copy2(template_file, destination_root)
        main_file = destination_root

    # Replace placeholders
    if main_file.is_file():
        original = main_file.read_text(encoding="utf-8")
        updated = _replace_placeholders(
            text=original,
            name=artifact_name,
            namespace=normalized_namespace,
        )
        main_file.write_text(updated, encoding="utf-8")

    click.echo(f"✓ {artifact_type.capitalize()} creado en {main_file}")


@click.group()
def scaffold() -> None:
    """Genera la estructura base de nuevos artefactos."""


@scaffold.command("skill")
@click.argument("name")
@click.argument("namespace")
def scaffold_skill(name: str, namespace: str) -> None:
    """Crea una skill desde skills/_TEMPLATE en el namespace indicado."""
    _scaffold_artifact("skill", name, namespace)


@scaffold.command("instruction")
@click.argument("name")
def scaffold_instruction(name: str) -> None:
    """Crea una instruction desde instructions/_TEMPLATE."""
    _scaffold_artifact("instruction", name)


@scaffold.command("prompt")
@click.argument("name")
@click.argument("namespace")
def scaffold_prompt(name: str, namespace: str) -> None:
    """Crea un prompt desde prompts/_TEMPLATE en el namespace indicado."""
    _scaffold_artifact("prompt", name, namespace)
