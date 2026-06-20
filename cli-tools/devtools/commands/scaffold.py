from __future__ import annotations

import click


@click.command()
@click.argument("artifact_type", metavar="TYPE", required=False)
@click.argument("name", required=False)
def scaffold(artifact_type: str | None, name: str | None) -> None:
    """Genera la estructura base de un nuevo artefacto (skill, agente, prompt)."""
    click.echo("TODO: implementar en US-015")
