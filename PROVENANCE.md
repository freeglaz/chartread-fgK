# Provenance of the official source

| | |
|---|---|
| File | `Argyll_V3.5.0_src.zip`, 15 352 322 bytes, kept unmodified in `upstream/` |
| URL | https://www.argyllcms.com/Argyll_V3.5.0_src.zip (Last-Modified: Tue, 10 Feb 2026 01:24:41 GMT) |
| sha256 | `f8576ce5589fd15620abb73ff049ea31f55ddbd1bba6d1ffa87452658e7bc85f` |
| sha512 | `c0a995c090b44d3981cfed541140ae3422ea5ebaa8d5e3d4c3c71599b527b8808e17f037283b08b4c10ad6f48976b5f48e9c6802355a6940a52682020e820b17` |

ArgyllCMS publishes no checksum or signature. The sha256 is checked against independent
records:

| Source | Checked on | Result |
|---|---|---|
| download from argyllcms.com | 2026-11-23 | same sha256 as the copy used since the first lab |
| Homebrew `argyll-cms` formula (`Formula/a/argyll-cms.rb`) | 2026-11-23 | same sha256 |
| Arch Linux `argyllcms` 3.5.0-2 `PKGBUILD` | 2026-11-23 | same sha256 |

The licence texts in the zip:

| File | sha256 |
|---|---|
| `License.txt` (AGPL-3.0, copied as `COPYING`) | `432d251a78dbc966e6add13f9f3b40a53daca222208e50cb514cfc77e7d85af6` |
| `License2.txt` (GPL-2.0) | `b1a57182be3d861afec10c3541c213257cd3af7b9ef576be3641a689aa7bd7b7` |
| `License3.txt` (GPL-3.0) | `8ceb4b9ee5adedde47b31e975c1d90c73ad27b6b165a1dcd80c7c545eb65b903` |
| `cgats/License4.txt` (MIT) | `559b0f8a8db0378a4ddd559acfe5c28819536362971a18c179c5cf78d60de3af` |

## The patch

| Version | sha256 | |
|---|---|---|
| v3 | `f38d53cadb0b9bb49d5ae0a2d82e0f852f2033eb6cdca81dabf13246a2b68cd8` | validated with a ColorMunki (macOS) and a fake instrument (Linux, macOS) |
| v3.1 | `7c3dcdc6676f5ad1c7613cf1be9bb929845eaba39ff153f628aca748dba6b5c4` | v3 plus the dated notice of section 5a in the header comment |

v3.1 is the same program as v3. The two patched files have the same C tokens once the
comments are removed. With `build-chartread-fgK.sh`, the USB build and the fake-instrument
build of v3 and v3.1 are byte-identical:
- under GCC 16.2.1 and binutils 2.46.1 (Fedora 44, x86_64);
- under Apple clang 21.0.0 and ld-27106.1 (Command Line Tools 27.2, macOS 27.2, arm64).
