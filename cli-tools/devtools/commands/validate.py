from __future__ import annotations

import click


@click.command()
@click.argument("path", default=".", required=False)
def validate(path: str) -> None:
    """Valida la estructura y frontmatter de skills en PATH."""
    click.echo("TODO: implementar en US-015")
