#!/usr/bin/env python3
"""
wiki-cli.py — LLM file system helper for the LLM Software Wiki pattern.

Gives LLM agents safe, structured access to read project files and write to
the wiki directory. Write access is restricted to wiki/ — all other paths
are read-only. No external dependencies; stdlib only.

USAGE:
  python wiki-cli.py read <path>
  python wiki-cli.py write <path>          (content read from stdin)
  python wiki-cli.py list [directory]
  python wiki-cli.py search <pattern> [directory]
  python wiki-cli.py find <name-pattern> [directory]
  python wiki-cli.py stat <path>

All paths are relative to the project root (the directory containing this
script) unless absolute. Write paths must resolve inside wiki/.

EXAMPLES:
  python wiki-cli.py read src/auth/middleware.py
  python wiki-cli.py read wiki/components/auth.md
  cat /tmp/new-page.md | python wiki-cli.py write wiki/components/auth.md
  python wiki-cli.py list wiki/components
  python wiki-cli.py search "def authenticate" src/
  python wiki-cli.py find "*.md" wiki/
  python wiki-cli.py stat wiki/index.md
"""

import sys
import os
import re
import fnmatch
from pathlib import Path
from datetime import datetime


# ---------------------------------------------------------------------------
# Root detection
# ---------------------------------------------------------------------------

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR
WIKI_DIR = PROJECT_ROOT / "wiki"


def resolve_path(raw: str) -> Path:
    """Resolve a raw path string to an absolute Path."""
    p = Path(raw)
    if not p.is_absolute():
        p = PROJECT_ROOT / p
    return p.resolve()


def is_inside_wiki(p: Path) -> bool:
    """Return True if p is inside the wiki/ directory."""
    try:
        p.relative_to(WIKI_DIR)
        return True
    except ValueError:
        return False


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_read(args: list[str]) -> None:
    """Read a file and print it with line numbers."""
    if not args:
        print("ERROR: read requires a path argument", file=sys.stderr)
        sys.exit(1)

    path = resolve_path(args[0])

    if not path.exists():
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    if path.is_dir():
        print(f"ERROR: {path} is a directory — use 'list' instead", file=sys.stderr)
        sys.exit(1)

    try:
        content = path.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        print(f"ERROR: cannot read {path}: {e}", file=sys.stderr)
        sys.exit(1)

    lines = content.splitlines()
    width = len(str(len(lines)))
    for i, line in enumerate(lines, 1):
        print(f"{i:{width}}\t{line}")


def cmd_write(args: list[str]) -> None:
    """Write stdin content to a wiki path. Path must be inside wiki/."""
    if not args:
        print("ERROR: write requires a path argument", file=sys.stderr)
        sys.exit(1)

    path = resolve_path(args[0])

    if not is_inside_wiki(path):
        print(
            f"ERROR: write is restricted to wiki/ — {path} is outside wiki/",
            file=sys.stderr,
        )
        sys.exit(1)

    content = sys.stdin.read()

    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        print(f"OK: wrote {len(content)} bytes to {path.relative_to(PROJECT_ROOT)}")
    except OSError as e:
        print(f"ERROR: cannot write {path}: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_list(args: list[str]) -> None:
    """List files in a directory, one per line."""
    directory = resolve_path(args[0]) if args else PROJECT_ROOT

    if not directory.exists():
        print(f"ERROR: directory not found: {directory}", file=sys.stderr)
        sys.exit(1)

    if not directory.is_dir():
        print(f"ERROR: {directory} is not a directory", file=sys.stderr)
        sys.exit(1)

    entries = sorted(directory.iterdir(), key=lambda p: (p.is_file(), p.name))
    for entry in entries:
        rel = entry.relative_to(PROJECT_ROOT)
        suffix = "/" if entry.is_dir() else ""
        print(f"{rel}{suffix}")


def cmd_search(args: list[str]) -> None:
    """Search for a regex pattern in files. Output: file:line:match."""
    if not args:
        print("ERROR: search requires a pattern argument", file=sys.stderr)
        sys.exit(1)

    pattern = args[0]
    search_root = resolve_path(args[1]) if len(args) > 1 else PROJECT_ROOT

    try:
        regex = re.compile(pattern)
    except re.error as e:
        print(f"ERROR: invalid pattern '{pattern}': {e}", file=sys.stderr)
        sys.exit(1)

    if not search_root.exists():
        print(f"ERROR: directory not found: {search_root}", file=sys.stderr)
        sys.exit(1)

    match_count = 0
    for filepath in sorted(search_root.rglob("*")):
        if not filepath.is_file():
            continue
        # Skip common binary/generated directories
        parts = filepath.parts
        skip_dirs = {
            "node_modules", ".git", "__pycache__", "venv", "dist",
            "build", ".next", ".obsidian",
        }
        if any(part in skip_dirs for part in parts):
            continue
        try:
            text = filepath.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for lineno, line in enumerate(text.splitlines(), 1):
            if regex.search(line):
                rel = filepath.relative_to(PROJECT_ROOT)
                print(f"{rel}:{lineno}:{line.rstrip()}")
                match_count += 1

    if match_count == 0:
        print(f"(no matches for '{pattern}')")


def cmd_find(args: list[str]) -> None:
    """Find files matching a name pattern (glob). Output: one path per line."""
    if not args:
        print("ERROR: find requires a name-pattern argument", file=sys.stderr)
        sys.exit(1)

    name_pattern = args[0]
    search_root = resolve_path(args[1]) if len(args) > 1 else PROJECT_ROOT

    if not search_root.exists():
        print(f"ERROR: directory not found: {search_root}", file=sys.stderr)
        sys.exit(1)

    skip_dirs = {
        "node_modules", ".git", "__pycache__", "venv", "dist",
        "build", ".next",
    }
    results = []
    for filepath in sorted(search_root.rglob("*")):
        if not filepath.is_file():
            continue
        if any(part in skip_dirs for part in filepath.parts):
            continue
        if fnmatch.fnmatch(filepath.name, name_pattern):
            results.append(filepath.relative_to(PROJECT_ROOT))

    if results:
        for r in results:
            print(r)
    else:
        print(f"(no files matching '{name_pattern}')")


def cmd_stat(args: list[str]) -> None:
    """Print existence, size, and last-modified date for a path."""
    if not args:
        print("ERROR: stat requires a path argument", file=sys.stderr)
        sys.exit(1)

    path = resolve_path(args[0])
    rel = path.relative_to(PROJECT_ROOT) if path.is_relative_to(PROJECT_ROOT) else path

    if not path.exists():
        print(f"exists:   no")
        print(f"path:     {rel}")
        return

    stat = path.stat()
    mtime = datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S")
    kind = "directory" if path.is_dir() else "file"

    print(f"exists:   yes")
    print(f"path:     {rel}")
    print(f"type:     {kind}")
    if path.is_file():
        print(f"size:     {stat.st_size} bytes")
    print(f"modified: {mtime}")


# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

COMMANDS = {
    "read": cmd_read,
    "write": cmd_write,
    "list": cmd_list,
    "search": cmd_search,
    "find": cmd_find,
    "stat": cmd_stat,
}


def print_usage() -> None:
    print(
        "Usage:\n"
        "  python wiki-cli.py read <path>\n"
        "  python wiki-cli.py write <path>          (content from stdin)\n"
        "  python wiki-cli.py list [directory]\n"
        "  python wiki-cli.py search <pattern> [directory]\n"
        "  python wiki-cli.py find <name-pattern> [directory]\n"
        "  python wiki-cli.py stat <path>\n"
        "\n"
        "Write is restricted to wiki/. All other commands are read-only."
    )


def main() -> None:
    if len(sys.argv) < 2:
        print_usage()
        sys.exit(1)

    command = sys.argv[1].lower()
    args = sys.argv[2:]

    if command in ("-h", "--help", "help"):
        print_usage()
        return

    if command not in COMMANDS:
        print(f"ERROR: unknown command '{command}'", file=sys.stderr)
        print_usage()
        sys.exit(1)

    COMMANDS[command](args)


if __name__ == "__main__":
    main()
