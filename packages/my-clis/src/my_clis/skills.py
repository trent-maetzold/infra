"""List, show and search agent skills."""

from pathlib import Path

import frontmatter
import typer
from pydantic import BaseModel
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="SKILLS_")
    dir: Path = Path.home() / ".agents/skills"


class Skill(BaseModel):
    name: str
    description: str
    body: str

    @classmethod
    def load(cls, path: Path) -> "Skill":
        post = frontmatter.load(path / "SKILL.md")
        return cls(name=path.name, description=" ".join(str(post.get("description", "")).split()), body=post.content)


app = typer.Typer(no_args_is_help=True)


def skills() -> list[Skill]:
    return [Skill.load(p.parent) for p in sorted(Settings().dir.glob("*/SKILL.md"))]


@app.command("list")
def list_() -> None:
    """List skills with their descriptions."""
    for s in skills():
        print(f"{s.name}: {s.description}")


@app.command()
def show(name: str) -> None:
    """Print a skill's instructions."""
    print(Skill.load(Settings().dir / name).body)


@app.command()
def search(pattern: str) -> None:
    """List skills whose name, description or body contains PATTERN (case-insensitive)."""
    for s in skills():
        if pattern.lower() in f"{s.name}\n{s.description}\n{s.body}".lower():
            print(f"{s.name}: {s.description}")
