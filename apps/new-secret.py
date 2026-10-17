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

app = typer.Typer()


@app.command()
def main(
    name: Annotated[str, typer.Argument(help="Secret name, kebab-cased into <name>.age.")],
    length: Annotated[
        int | None,
        typer.Argument(help="Generate an alphanumeric password this long instead of prompting."),
    ] = None,
    repo: Annotated[Path, typer.Option(envvar="NIX_SECRETS")] = Path.home() / "code/nix-secrets",
    key: Annotated[Path, typer.Option(envvar="NIX_SECRETS_KEY")] = Path.home() / ".ssh/id_ed25519.pub",
) -> None:
    name = kebabcase(name)
    if length is not None:
        secret = "".join(secrets.choice(ALPHABET) for _ in range(length))
    else:
        secret = getpass(f"Secret for {name}: ")
        if not secret or secret != getpass("Confirm: "):
            raise typer.Exit("empty or mismatched secret")
    out = repo / f"{name}.age"
    sh.rage("-e", "-R", key, "-o", out, _in=secret)
    typer.echo(f"wrote {out}")


if __name__ == "__main__":
    app()
