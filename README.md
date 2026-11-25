# chartread-fgK

`chartread-fgK` is the `chartread` program of [ArgyllCMS](https://www.argyllcms.com/) 3.5.0
with one change: a `-K` option that saves the `.ti3` after each strip pass, so that an
interrupted reading session can be resumed (`-r`) without losing the strips already read.

It is the measurement engine of [freeglaz](https://github.com/freeglaz/freeglaz) for strip
reading with a spectrophotometer. It is **not the official ArgyllCMS `chartread`**, and it
is not endorsed by the author of ArgyllCMS: report problems with it to freeglaz, never
upstream.

- Built for **USB instruments only**: the serial-port drivers are not compiled in.
- Same behaviour as the official `chartread` without `-K`.
- With `-K`, every save goes through a temporary file that is flushed, renamed, and its
  directory flushed. A refused or not-durable save is reported on the terminal, and the
  reading continues.

## Contents

| Path | What |
|---|---|
| `upstream/Argyll_V3.5.0_src.zip` | the official ArgyllCMS 3.5.0 source, **unmodified** (see `PROVENANCE.md`) |
| `upstream.sha256`, `upstream.sha512` | its checksums |
| `patches/fg-chartread-checkpoint.v3.1.patch` | the change to `spectro/chartread.c` |
| `src/fg_sa_compat.[ch]` | two symbols the USB drivers need in Argyll's standalone instrument-library build |
| `build/build-chartread-fgK.sh` | the build (Linux with GCC, macOS with clang) |
| `build/flatpak/chartread-fgK.yaml` | the same build as a Flatpak module |
| `tools/make_manifest.py` | the manifest freeglaz reads next to the binary |
| `tools/licence-inventory.py` | the licence of every file compiled in (`LICENCES.md`) |
| `tools/make-source-tarball.sh` | the Corresponding Source tarball shipped with every binary |

## Build

```sh
(cd upstream && sha256sum -c ../upstream.sha256)
build/build-chartread-fgK.sh --zip upstream/Argyll_V3.5.0_src.zip \
    --patch patches/fg-chartread-checkpoint.v3.1.patch --out out
tools/make_manifest.py out/chartread-fgK --patch patches/fg-chartread-checkpoint.v3.1.patch \
    --platform linux --arch x86_64 --usb-only --source-zip upstream/Argyll_V3.5.0_src.zip
tools/make-source-tarball.sh upstream/Argyll_V3.5.0_src.zip out    # GNU tar
```

The build is reproducible for one toolchain: two builds with the same compiler and linker
give the same bytes. A different compiler gives a different sha256.

The script never runs what it builds. Running `chartread-fgK` opens the USB instrument it
finds: on Linux the user needs access to it (udev rules, as for ArgyllCMS).

## How freeglaz ships it

freeglaz builds this repository **at a fixed commit**, in its release workflow on GitHub
Actions, never from a branch:

- **Linux (Flatpak)**: the build of `build/flatpak/chartread-fgK.yaml`, in the freeglaz
  manifest, with the GNOME SDK at a fixed commit; installed in `/app/chartread-fgK/`.
- **macOS (Apple Silicon)**: `build/build-chartread-fgK.sh` with a fixed Xcode, then signed
  ad hoc on its own (`codesign -s - --force`, never `-i`), then `tools/make_manifest.py`,
  before it is bundled in `freeglaz.app/Contents/Frameworks/chartread-fgK/`. Bundling and the
  application's signature leave its bytes unchanged.

freeglaz trusts an engine only by the sha256 of its bytes, listed in its own code, for the
toolchain of its release; the manifest proves integrity, not trust. Each package carries,
next to the binary, the Corresponding Source tarball made by `tools/make-source-tarball.sh`.

## Licence

GNU Affero General Public License version 3 (`COPYING`), as ArgyllCMS's `chartread`. Some
files compiled in are under GPL-2.0-or-later, MIT or the public domain; `LICENCES.md`
lists them all. `NOTICE.md` says what was modified, by whom and when.
