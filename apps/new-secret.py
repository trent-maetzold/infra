#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = ["case-converter", "sh", "typer"]
# ///
"""Encrypt a secret to the deploy key as <name>.age in the secrets repo."""

import secrets
import string
from getpass import getpass
from pathlib import Path
from typing import Annotated

import sh
import typer
from caseconverter import kebabcase

ALPHABET = string.ascii_letters + string.digits
REPO = Path.home() / "code/nix-secrets"
KEY = Path.home() / ".ssh/id_ed25519.pub"

Name = Annotated[str, typer.Argument(help="Kebab-cased into <name>.age.")]
Length = Annotated[int | None, typer.Argument(help="Generate a password this long.")]
Repo = Annotated[Path, typer.Option(envvar="NIX_SECRETS")]
Key = Annotated[Path, typer.Option(envvar="NIX_SECRETS_KEY")]

app = typer.Typer()


@app.command()
def main(
    name: Name,
    length: Length = None,
    repo: Repo = REPO,
    key: Key = KEY,
) -> None:
    """Encrypt a prompted or generated secret as <name>.age."""
    name = kebabcase(name)
    if length is not None:
        secret = "".join(secrets.choice(ALPHABET) for _ in range(length))
    else:
        secret = getpass(f"Secret for {name}: ")
        if not secret or secret != getpass("Confirm: "):
            typer.echo("empty or mismatched secret", err=True)
            raise typer.Exit(1)
    out = repo / f"{name}.age"
    sh.rage("-e", "-R", key, "-o", out, _in=secret)
    typer.echo(f"wrote {out}")


if __name__ == "__main__":
    app()
