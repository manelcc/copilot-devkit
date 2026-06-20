import click

from devtools.commands.sync import sync
from devtools.commands.scaffold import scaffold
from devtools.commands.validate import validate
from devtools.commands.list_cmd import list_cmd


@click.group()
@click.version_option(package_name="devtools")
def main() -> None:
    """DevTools CLI — gestiona artefactos de automatización IA (skills, agentes, prompts)."""


main.add_command(sync)
main.add_command(scaffold)
main.add_command(validate)
main.add_command(list_cmd, name="list")
