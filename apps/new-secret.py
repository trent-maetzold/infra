#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["typer"]
# ///
"""Encrypt a secret to the deploy key as <name>.age in the secrets repo."""

import re
import secrets
import string
import subprocess
from getpass import getpass
from pathlib import Path
from typing import Annotated, Optional

import typer

ALPHABET = string.ascii_letters + string.digits

app = typer.Typer()


@app.command()
def main(
    name: Annotated[str, typer.Argument(help="Kebab-case name; becomes <name>.age.")],
    length: Annotated[
        Optional[int],
        typer.Argument(help="Generate an alphanumeric password this long instead of prompting."),
    ] = None,
    repo: Annotated[Path, typer.Option(envvar="NIX_SECRETS")] = Path.home() / "code/nix-secrets",
    key: Annotated[Path, typer.Option(envvar="NIX_SECRETS_KEY")] = Path.home() / ".ssh/id_ed25519.pub",
) -> None:
    if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name):
        raise typer.BadParameter("must be kebab-case", param_hint="NAME")
    if length is not None:
        secret = "".join(secrets.choice(ALPHABET) for _ in range(length))
    else:
        secret = getpass(f"Secret for {name}: ")
        if not secret or secret != getpass("Confirm: "):
            raise typer.Exit("empty or mismatched secret")
    out = repo / f"{name}.age"
    subprocess.run(["@rage@", "-e", "-R", key, "-o", out], input=secret.encode(), check=True)
    typer.echo(f"wrote {out}")


if __name__ == "__main__":
    app()
