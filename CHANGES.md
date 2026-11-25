# Changes

## 3.5.0-fg3.1 (not released)

- This repository: the official source zip kept unmodified in `upstream/`, so that a build
  needs nothing else; freeglaz builds it at a fixed commit in its release workflow.

- Patch v3.1: v3 plus the dated notice of modification (AGPL v3 section 5a) in the header
  comment of `chartread.c`. No code change: same binary as v3 with the same toolchain.

## 3.5.0-fg3 (lab, never distributed)

- `EOPNOTSUPP` joins `ENOTSUP` and `EINVAL` as "`F_FULLFSYNC` not supported" where it is a
  distinct value (macOS): fallback to `fsync()` only, reported.

## Earlier lab versions (never distributed)

- v2: the file and, after the rename, its directory are flushed with `fsync()` then
  `F_FULLFSYNC` where it exists. `F_FULLFSYNC` refused with `ENOTSUP`/`EINVAL` falls back
  to `fsync()` and is reported ("Checkpoint durability reduced"). A failed directory
  flush after the rename is reported ("Checkpoint not durable"); before the rename, any
  failure refuses the save ("Checkpoint not saved") and the previous file stays.
- v1: first `-K`: temporary file, `fsync()`, rename. A failed directory flush went
  unreported.
