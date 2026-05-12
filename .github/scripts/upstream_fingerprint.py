#!/usr/bin/env python3
"""
Extract the upstream-state fingerprint for one core recipe.

For each FetchContent_Declare block in the recipe, collect (repo, ref). If ref
looks like a 40-char hex commit, keep it literally; otherwise resolve it via
`git ls-remote` against the repo so we have a real commit sha for comparison.

Output is one line: `<repo>@<sha>|<repo>@<sha>|...` — stable across days as long
as upstream branches haven't moved. Used by the nightly smart-matrix workflow
to decide whether to rebuild a core; compared byte-for-byte against the
fingerprint recorded in the previous release's manifest.json.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

HEX40 = re.compile(r"^[0-9a-f]{40}$")
REPO_RE = re.compile(r"GIT_REPOSITORY\s+(\S+)")
TAG_RE = re.compile(r"GIT_TAG\s+(\S+)")


def declare_blocks(text: str) -> list[str]:
    """Return the body of every FetchContent_Declare(...) call. Tracks paren
    depth so comments containing parens (e.g. "Update atari800 from 3.1.0)")
    don't terminate the block early — a naive `.*?\\)` regex breaks here."""
    blocks: list[str] = []
    needle = "FetchContent_Declare"
    i = 0
    while True:
        idx = text.find(needle, i)
        if idx < 0:
            break
        open_paren = text.find("(", idx)
        if open_paren < 0:
            break
        depth = 1
        j = open_paren + 1
        while j < len(text) and depth > 0:
            c = text[j]
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
            j += 1
        if depth == 0:
            blocks.append(text[open_paren + 1 : j - 1])
        i = j
    return blocks


def ls_remote_sha(repo: str, ref: str) -> str:
    """Resolve a branch/tag name to a commit sha via git ls-remote.

    Tries the bare ref first, then refs/heads/<ref>, then refs/tags/<ref>.
    Returns "NONE" if all probes come back empty — caller will surface that as
    a fingerprint mismatch on the next run, which forces a rebuild that will
    either succeed or fail loudly, never silently.
    """
    for candidate in (ref, f"refs/heads/{ref}", f"refs/tags/{ref}"):
        try:
            out = subprocess.check_output(
                ["git", "ls-remote", "--quiet", repo, candidate],
                stderr=subprocess.DEVNULL,
                timeout=30,
            ).decode().strip()
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            continue
        if out:
            return out.split()[0]
    return "NONE"


def fingerprint(recipe_path: Path) -> str:
    text = recipe_path.read_text()
    parts: list[str] = []
    for block in declare_blocks(text):
        repo_m = REPO_RE.search(block)
        tag_m = TAG_RE.search(block)
        if not (repo_m and tag_m):
            continue
        repo = repo_m.group(1)
        tag = tag_m.group(1)
        sha = tag if HEX40.match(tag) else ls_remote_sha(repo, tag)
        parts.append(f"{repo}@{sha}")
    return "|".join(parts)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("recipe", help="path to recipes/<core>.cmake")
    args = p.parse_args()

    recipe = Path(args.recipe)
    if not recipe.is_file():
        print(f"upstream_fingerprint: recipe not found: {recipe}", file=sys.stderr)
        return 1

    print(fingerprint(recipe))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
