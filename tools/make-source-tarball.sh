#!/usr/bin/env bash
# make-source-tarball.sh - the Corresponding Source of chartread-fgK (AGPL-3.0 section 6),
# as one deterministic tarball: the UNMODIFIED official ArgyllCMS 3.5.0 source zip, the
# checkpoint patch, freeglaz's own source files, the build scripts and the documents.
#
# Copyright 2026 the freeglaz contributors. SPDX-License-Identifier: AGPL-3.0-or-later
#
#   make-source-tarball.sh <Argyll_V3.5.0_src.zip> <out dir>
# Same inputs → same bytes (sorted names, fixed owner, mode and date, gzip -n). GNU tar.
set -euo pipefail
ZIP_SHA256=f8576ce5589fd15620abb73ff049ea31f55ddbd1bba6d1ffa87452658e7bc85f
REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
ZIP="$1"; OUT="$(mkdir -p "$2" && cd "$2" && pwd -P)"
[ "$(sha256sum "$ZIP" | cut -d' ' -f1)" = "$ZIP_SHA256" ] || { echo "not the official zip" >&2; exit 2; }
NAME=chartread-fgK-3.5.0-fg3.1-src
STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/$NAME/upstream"
cp "$ZIP" "$STAGE/$NAME/upstream/Argyll_V3.5.0_src.zip"
for f in README.md COPYING NOTICE.md PROVENANCE.md LICENCES.md CHANGES.md upstream.sha256 \
         upstream.sha512 patches src build tools; do
  cp -r "$REPO/$f" "$STAGE/$NAME/"
done
find "$STAGE/$NAME" -name '__pycache__' -prune -exec rm -rf {} +
tar --sort=name --owner=0 --group=0 --numeric-owner --mode='u+rwX,go+rX,go-w' \
    --mtime='2026-11-23 00:00:00Z' --format=gnu -C "$STAGE" -cf - "$NAME" | gzip -n -9 > "$OUT/$NAME.tar.gz"
sha256sum "$OUT/$NAME.tar.gz"
