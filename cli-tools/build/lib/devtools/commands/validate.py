from __future__ import annotations

import re
import subprocess
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


def _resolve_validate_script(repo_root: Path) -> Path:
    """Resolve validation script with backward-compatible fallback."""
    script_candidates = [
        repo_root / "scripts" / "validate-skill.sh",
        repo_root / "scripts" / "devkit-validate-skill.sh",
    ]
    for script in script_candidates:
        if script.is_file():
            return script
    raise click.ClickException(
        "No se encontró script de validación. Probados: scripts/validate-skill.sh y scripts/devkit-validate-skill.sh"
    )


def _has_frontmatter(content: str) -> bool:
    return bool(re.match(r"^---\n[\s\S]*?\n---\n", content))


def _frontmatter_stub(skill_name: str) -> str:
    return (
        "---\n"
        f'name: "{skill_name}"\n'
        'description: "TODO: describe la skill"\n'
        "triggers:\n"
        '  - "TODO trigger"\n'
        "non_triggers:\n"
        '  - "TODO non trigger"\n'
        "---\n\n"
    )


def _overview_stub(skill_name: str) -> str:
    return (
        f"# {skill_name} - Overview\n\n"
        "## Workflow\n\n"
        "```mermaid\n"
        "flowchart TD\n"
        "    A[Start] --> B[Analyze inputs]\n"
        "    B --> C[Apply steps]\n"
        "    C --> D[Return outputs]\n"
        "```\n"
    )


def _apply_fix(skill_path: Path) -> list[str]:
    """Apply limited auto-fixes requested by US-015."""
    fixes: list[str] = []
    skill_md_path = skill_path / "SKILL.md"
    references_path = skill_path / "references"
    overview_path = references_path / "overview.md"

    if skill_md_path.is_file():
        original = skill_md_path.read_text(encoding="utf-8")
        if not _has_frontmatter(original):
            stub = _frontmatter_stub(skill_name=skill_path.name)
            skill_md_path.write_text(stub + original, encoding="utf-8")
            fixes.append("✓ Generado frontmatter stub")

    if not overview_path.exists():
        references_path.mkdir(parents=True, exist_ok=True)
        overview_path.write_text(_overview_stub(skill_name=skill_path.name), encoding="utf-8")
        fixes.append("✓ Creado references/overview.md")

    return fixes


def _parse_checks(stdout: str) -> list[tuple[str, str]]:
    """Parse script output into table-friendly checks."""
    checks: list[tuple[str, str]] = []
    ansi_escape = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
    for line in stdout.splitlines():
        stripped = ansi_escape.sub("", line).strip()
        if stripped.startswith("[OK]"):
            checks.append(("✓", stripped.removeprefix("[OK]").strip()))
        elif stripped.startswith("[ERROR]"):
            checks.append(("✗", stripped.removeprefix("[ERROR]").strip()))
        elif stripped.startswith("[WARN]"):
            checks.append(("⚠", stripped.removeprefix("[WARN]").strip()))
    return checks


def _print_checks_table(checks: list[tuple[str, str]]) -> None:
    if not checks:
        click.echo("No se pudieron extraer checks del script de validación.")
        return

    status_width = max(len(status) for status, _ in checks)
    check_width = max(len(check) for _, check in checks)
    status_header = "Estado"
    check_header = "Criterio"
    status_width = max(status_width, len(status_header))
    check_width = max(check_width, len(check_header))

    sep = f"+-{'-' * status_width}-+-{'-' * check_width}-+"
    click.echo(sep)
    click.echo(
        f"| {status_header.ljust(status_width)} | {check_header.ljust(check_width)} |"
    )
    click.echo(sep)
    for status, check in checks:
        click.echo(f"| {status.ljust(status_width)} | {check.ljust(check_width)} |")
    click.echo(sep)


@click.group()
def validate() -> None:
    """Valida artefactos del repositorio."""


@validate.command("skill")
@click.argument("path")
@click.option("--fix", is_flag=True, help="Intenta corregir problemas básicos automáticamente.")
def validate_skill(path: str, fix: bool) -> None:
    """Valida una skill en PATH usando el script oficial del repo."""
    cwd = Path.cwd()
    repo_root = _find_repo_root(cwd)

    raw_path = Path(path)
    skill_path = raw_path if raw_path.is_absolute() else (repo_root / raw_path)
    skill_path = skill_path.resolve()

    if not skill_path.exists() or not skill_path.is_dir():
        raise click.ClickException(f"La ruta no existe o no es directorio: '{skill_path}'")

    if fix:
        fixes = _apply_fix(skill_path)
        for msg in fixes:
            click.echo(msg)

    script_path = _resolve_validate_script(repo_root)
    command = [str(script_path), str(skill_path)]

    result = subprocess.run(
        command,
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )

    combined_output = "\n".join(part for part in [result.stdout, result.stderr] if part)
    checks = _parse_checks(combined_output)
    _print_checks_table(checks)

    if result.returncode == 0:
        click.echo("✓ Skill válida")
        raise SystemExit(0)

    if combined_output.strip():
        click.echo(combined_output.strip())
    click.echo("✗ Skill inválida")
    raise SystemExit(1)
