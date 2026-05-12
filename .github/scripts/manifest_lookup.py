#!/usr/bin/env python3
"""
Read one field for one core from a manifest.json. Used by the matrix gate
step so it doesn't have to depend on `jq` being installed inside the
foyer-cores-builder container.

Usage: manifest_lookup.py <manifest_path> <core_name> <field>
Prints the field value (or empty string when missing) to stdout.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: manifest_lookup.py <manifest_path> <core_name> <field>",
              file=sys.stderr)
        return 2

    manifest, name, field = sys.argv[1], sys.argv[2], sys.argv[3]
    p = Path(manifest)
    if not p.is_file():
        print("")
        return 0

    try:
        doc = json.loads(p.read_text())
    except json.JSONDecodeError:
        print("")
        return 0

    for c in doc.get("cores", []):
        if c.get("name") == name:
            print(c.get(field, "") or "")
            return 0

    print("")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
