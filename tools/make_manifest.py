#!/usr/bin/env python3
"""make_manifest.py - write chartread-fgK.manifest.json next to a freshly built engine.

Copyright 2026 the freeglaz contributors. SPDX-License-Identifier: AGPL-3.0-or-later

  make_manifest.py <binary> --patch <patch file> --platform linux|darwin --arch x86_64|arm64
                   [--usb-only] [--source-zip <Argyll_V3.5.0_src.zip>] [--toolchain TEXT]

Schema 1 of freeglaz (lib/z9_client/chartread_fgk/engine.py). Reads files only, never runs
the binary. Hash the binary AFTER every step that changes its bytes (strip, signature):
the manifest describes the file as it is shipped.

The manifest is INTEGRITY, not trust: it says which binary, patch and source this is, and
anyone who can write the binary can write it too. freeglaz trusts a build only through the
sha256 pinned in its own code (TRUSTED_BUILDS)."""
import argparse
import hashlib
import json
import sys
from pathlib import Path

KNOWN_PATCHES = {   # sha256 of the .patch file → version
    "f38d53cadb0b9bb49d5ae0a2d82e0f852f2033eb6cdca81dabf13246a2b68cd8": "3",
    "7c3dcdc6676f5ad1c7613cf1be9bb929845eaba39ff153f628aca748dba6b5c4": "3.1",  # v3 + dated AGPL notice
}
ARGYLL_ZIP = "f8576ce5589fd15620abb73ff049ea31f55ddbd1bba6d1ffa87452658e7bc85f"


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("binary")
    ap.add_argument("--patch", required=True)
    ap.add_argument("--platform", required=True, choices=["linux", "darwin"])
    ap.add_argument("--arch", required=True, choices=["x86_64", "arm64"])
    ap.add_argument("--usb-only", action="store_true")
    ap.add_argument("--source-zip")
    ap.add_argument("--toolchain", default="")
    a = ap.parse_args()
    psha = sha(a.patch)
    if psha not in KNOWN_PATCHES:
        sys.exit(f"unknown patch {psha[:12]}… (known: {sorted(KNOWN_PATCHES.values())})")
    if a.source_zip and sha(a.source_zip) != ARGYLL_ZIP:
        sys.exit("the ArgyllCMS source zip is not the official 3.5.0 one")
    b = Path(a.binary)
    man = {"schema": "freeglaz.chartread_fgk_manifest", "schema_version": 1,
           "binary": b.name, "sha256": sha(b), "argyll_version": "3.5.0",
           "patch": {"name": "fg-chartread-checkpoint", "version": KNOWN_PATCHES[psha], "sha256": psha},
           "build": {"platform": a.platform, "arch": a.arch, "usb_only": bool(a.usb_only),
                     "toolchain": a.toolchain},
           "source": {"argyll_zip_sha256": ARGYLL_ZIP,
                      "argyll_url": "https://www.argyllcms.com/Argyll_V3.5.0_src.zip",
                      "licence": "AGPL-3.0 (ArgyllCMS chartread.c, the checkpoint patch)",
                      "corresponding_source": "source/ next to this file"}}
    out = b.parent / "chartread-fgK.manifest.json"
    out.write_text(json.dumps(man, indent=1) + "\n")
    print(out, man["sha256"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
