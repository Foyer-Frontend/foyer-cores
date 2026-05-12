#!/usr/bin/env python3
"""
Aggregator step for the smart-matrix build.

Inputs (CLI flags):
  --tag           the release tag we're publishing under (CalVer)
  --repo          github org/repo (used to build asset URLs)
  --recipes-dir   path to foyer-cores/recipes/
  --artifacts-dir dir of freshly built foyer-<core>.nro files (skipped cores
                  contribute no file here)
  --prev-manifest path to the previous release's manifest.json (or empty if
                  there isn't one yet)
  --out           where to write the new manifest.json

For each recipe under recipes/, the script decides one of:
  fresh   — a matching foyer-<core>.nro exists in --artifacts-dir. Recompute
            size/sha256/url/upstream_fingerprint/recipe_sha and pin
            last_built_tag to --tag.
  inherit — copy the prior manifest entry verbatim. Its `url` still points
            at the older release where the nro was actually built, so the
            browser downloads it directly from there.
  drop    — neither freshly built nor in the prior manifest (e.g. a brand new
            recipe whose first matrix run failed). Skipped from the output.

`recipe_sha` and `upstream_fingerprint` are recorded so the next nightly's
matrix can compare against them without re-resolving every upstream branch.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


def sha256_of(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def recipe_blob_sha(recipes_dir: Path, name: str) -> str:
    """Content sha of the recipe file. Reused as a 'has the recipe changed
    since the last build' signal — distinct from upstream commit motion."""
    p = recipes_dir / f"{name}.cmake"
    if not p.is_file():
        return ""
    return hashlib.sha1(p.read_bytes()).hexdigest()


def upstream_fingerprint(recipes_dir: Path, name: str) -> str:
    """Call the sibling fingerprint script so the same logic the matrix uses
    to decide skip-vs-build also lands in the manifest."""
    script = Path(__file__).parent / "upstream_fingerprint.py"
    recipe = recipes_dir / f"{name}.cmake"
    try:
        return subprocess.check_output(
            [sys.executable, str(script), str(recipe)],
            timeout=120,
        ).decode().strip()
    except Exception as exc:
        print(f"build_manifest: fingerprint for {name} failed: {exc}", file=sys.stderr)
        return ""


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--tag", required=True)
    p.add_argument("--repo", required=True, help="org/name")
    p.add_argument("--recipes-dir", required=True, type=Path)
    p.add_argument("--artifacts-dir", required=True, type=Path)
    p.add_argument("--prev-manifest", type=Path)
    p.add_argument("--out", required=True, type=Path)
    args = p.parse_args()

    prev: dict[str, Any] = {}
    if args.prev_manifest and args.prev_manifest.is_file():
        try:
            prev = json.loads(args.prev_manifest.read_text())
        except json.JSONDecodeError:
            print("build_manifest: prev manifest unparseable, ignoring", file=sys.stderr)
            prev = {}

    prev_by_name = {c["name"]: c for c in prev.get("cores", []) if "name" in c}

    cores_out: list[dict[str, Any]] = []
    counts = {"fresh": 0, "inherit": 0, "drop": 0}

    for recipe in sorted(args.recipes_dir.glob("*.cmake")):
        name = recipe.stem
        # Skip our build-helper cmake — those aren't cores.
        if name.endswith("_stubs") or name in {"core_recipe", "rcheevos"}:
            continue
        artifact = args.artifacts_dir / f"foyer-{name}.nro"
        if artifact.is_file():
            sum256 = sha256_of(artifact)
            entry = {
                "name": name,
                "version": sum256[:7],
                "nro": artifact.name,
                "size": artifact.stat().st_size,
                "sha256": sum256,
                "url": f"https://github.com/{args.repo}/releases/download/{args.tag}/{artifact.name}",
                "upstream_fingerprint": upstream_fingerprint(args.recipes_dir, name),
                "recipe_sha": recipe_blob_sha(args.recipes_dir, name),
                "last_built_tag": args.tag,
            }
            cores_out.append(entry)
            counts["fresh"] += 1
        elif name in prev_by_name:
            cores_out.append(prev_by_name[name])
            counts["inherit"] += 1
        else:
            counts["drop"] += 1

    out_doc = {
        "version": args.tag,
        "cores": cores_out,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(out_doc, indent=2) + "\n")
    print(
        f"build_manifest: tag={args.tag} fresh={counts['fresh']} "
        f"inherit={counts['inherit']} drop={counts['drop']} total={len(cores_out)}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
