#!/usr/bin/env python3
"""licence-inventory.py - the licence of every file compiled into chartread-fgK.

Copyright 2026 the freeglaz contributors. SPDX-License-Identifier: AGPL-3.0-or-later

  licence-inventory.py <build out dir> [chartread-fgK|chartread-fgK-fake]

Reads <out>/<binary>.sources (written by build-chartread-fgK.sh: every .c and .h the
compiler used) and the header comment of each file in <out>/work; prints a Markdown table.
A file whose header names no licence is reported as such: it is never guessed."""
import re
import sys
from pathlib import Path

RULES = [   # first match wins, on the first 60 lines, case-insensitive
    ("AGPL-3.0-or-later", r"SPDX-License-Identifier:\s*AGPL-3\.0-or-later"),
    ("AGPL-3.0", r"AFFERO GENERAL PUBLIC LICENSE"),
    ("GPL-2.0-or-later", r"GENERAL PUBLIC LICENSE\s*Version 2 or later"),
    ("GPL-2.0 (only?)", r"GENERAL PUBLIC LICENSE\s*Version 2"),
    ("GPL-3.0", r"GENERAL PUBLIC LICENSE\s*Version 3"),
    ("MIT", r"Permission is hereby granted, free of charge"),
    ("MIT (cgats/License4.txt)", r'"MIT" free use license'),
    ("not copyrighted (Mark Adler, gzip 1.2.4)", r"Not copyrighted 1992 by Mark Adler"),
    ("public domain", r"public domain"),
    ("zlib", r"This software is provided 'as-is'"),
]


def licence(path: Path) -> str:
    head = "\n".join(path.read_text(errors="replace").splitlines()[:60])
    head = re.sub(r"\s+", " ", head)
    for name, rx in RULES:
        if re.search(rx, head, re.I):
            return name
    return "NOT STATED IN THE FILE"


def main() -> int:
    out = Path(sys.argv[1])
    binary = sys.argv[2] if len(sys.argv) > 2 else "chartread-fgK"
    files = [ln.strip() for ln in (out / f"{binary}.sources").read_text().splitlines() if ln.strip()]
    rows, counts = [], {}
    for f in files:
        lic = licence(out / "work" / f)
        counts[lic] = counts.get(lic, 0) + 1
        origin = ("freeglaz (patched)" if f == "gen/chartread.c" else
                  "freeglaz" if f.startswith("fg/") else
                  "ArgyllCMS 3.5.0 (copied)" if f.startswith("gen/") else "ArgyllCMS 3.5.0")
        rows.append(f"| `{f}` | {origin} | {lic} |")
    print(f"# Files compiled into `{binary}`\n")
    print(f"{len(files)} files. " + ", ".join(f"{k}: {v}" for k, v in sorted(counts.items())) + "\n")
    print("| File | Origin | Licence stated in the file |\n|---|---|---|")
    print("\n".join(rows))
    return 0


if __name__ == "__main__":
    sys.exit(main())
