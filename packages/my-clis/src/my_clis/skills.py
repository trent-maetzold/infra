"""List, describe, show and search agent skills."""

from pathlib import Path

import frontmatter
import typer
import yaml
from pydantic import BaseModel, ConfigDict
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="SKILLS_")
    dir: Path = Path.home() / ".agents/skills"


class Skill(BaseModel):
    model_config = ConfigDict(extra="allow")
    name: str
    description: str
    body: str

    @classmethod
    def load(cls, path: Path) -> "Skill":
        post = frontmatter.load(path / "SKILL.md")
        description = " ".join(str(post.get("description", "")).split())
        return cls.model_validate(post.metadata | {"name": path.name, "description": description, "body": post.content})


app = typer.Typer(no_args_is_help=True)


def skills() -> list[Skill]:
    return [Skill.load(p.parent) for p in sorted(Settings().dir.glob("*/SKILL.md"))]


@app.command("list")
def list_() -> None:
    """List skills with their descriptions."""
    for s in skills():
        print(f"{s.name}: {s.description}")


@app.command()
def describe(name: str) -> None:
    """Print a skill's frontmatter as YAML."""
    skill = Skill.load(Settings().dir / name)
    print(yaml.safe_dump(skill.model_dump(exclude={"body"}), sort_keys=False, allow_unicode=True, width=1 << 16), end="")


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
