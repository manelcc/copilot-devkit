from __future__ import annotations

import click


@click.command("list")
@click.option("--namespace", default=None, help="Filtra por namespace (global, android, ios, etc.).")
@click.option("--type", "artifact_type", default=None, help="Filtra por tipo (skills, agents, prompts).")
def list_cmd(namespace: str | None, artifact_type: str | None) -> None:
    """Lista los artefactos disponibles en DevTools-AI."""
    click.echo("TODO: implementar en US-015")
