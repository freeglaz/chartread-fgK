#!/usr/bin/env bash
# build-chartread-fgK.sh - compile chartread-fgK: the chartread program of the OFFICIAL
# ArgyllCMS 3.5.0 source plus the freeglaz checkpoint patch, USB instruments only.
#
# Copyright 2026 the freeglaz contributors. SPDX-License-Identifier: AGPL-3.0-or-later
#
#   build-chartread-fgK.sh --zip Argyll_V3.5.0_src.zip --patch PATCH --out DIR
#   build-chartread-fgK.sh --tree ARGYLL_TREE          --patch PATCH --out DIR
#       USB build: DIR/chartread-fgK (the program freeglaz ships).
#   ... --fakeinst fg_fakeinst.c [--stock]
#       TEST build: DIR/chartread-fgK-fake, the same chartread linked against a fake
#       instrument instead of the drivers (no USB or serial code at all). Never shipped.
#       --stock: the OFFICIAL chartread.c, unpatched, for comparisons (DIR/chartread-stock-fake).
#
# The script never runs what it builds (the USB binary is left mode 644; the installer
# sets the mode). Only static checks: inputs by sha256, symbols, strings.
#
# Reproducible for ONE toolchain: fixed relative paths (__FILE__ is embedded by three
# drivers), no debug information, SOURCE_DATE_EPOCH, LC_ALL=C. A different compiler gives
# different bytes: the sha256 to trust is the one of the toolchain that builds the release.
# Linux (GCC) and macOS (clang, Command Line Tools); bash 3.2 compatible.
set -euo pipefail

ZIP_SHA256=f8576ce5589fd15620abb73ff049ea31f55ddbd1bba6d1ffa87452658e7bc85f   # Argyll_V3.5.0_src.zip
patch_version() {                       # accepted checkpoint patches, by sha256
  case "$1" in
    7c3dcdc6676f5ad1c7613cf1be9bb929845eaba39ff153f628aca748dba6b5c4) echo 3.1 ;;
    f38d53cadb0b9bb49d5ae0a2d82e0f852f2033eb6cdca81dabf13246a2b68cd8) echo 3 ;;
    *) echo "" ;;
  esac
}
sha256() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
           else shasum -a 256 "$1" | cut -d' ' -f1; fi; }
abspath() { (cd "$(dirname "$1")" && printf '%s/%s\n' "$(pwd -P)" "$(basename "$1")"); }
die() { echo "build-chartread-fgK: $*" >&2; exit 2; }

HERE="$(cd "$(dirname "$0")" && pwd -P)"
SRC="$(cd "$HERE/../src" && pwd -P)"
ZIP= TREE= PATCH= OUT= FAKE= STOCK=
while [ $# -gt 0 ]; do
  case "$1" in
    --zip) ZIP="$(abspath "$2")"; shift 2 ;;
    --tree) TREE="$(cd "$2" && pwd -P)"; shift 2 ;;
    --patch) PATCH="$(abspath "$2")"; shift 2 ;;
    --out) mkdir -p "$2"; OUT="$(cd "$2" && pwd -P)"; shift 2 ;;
    --fakeinst) FAKE="$(abspath "$2")"; shift 2 ;;
    --stock) STOCK=1; shift ;;
    *) die "unknown argument $1" ;;
  esac
done
[ -n "$PATCH" ] && [ -n "$OUT" ] && { [ -n "$ZIP" ] || [ -n "$TREE" ]; } \
  || die "usage: $0 (--zip ZIP | --tree DIR) --patch PATCH --out DIR [--fakeinst FILE]"

PSHA="$(sha256 "$PATCH")"; PVER="$(patch_version "$PSHA")"
[ -n "$PVER" ] || die "unknown checkpoint patch (sha256 $PSHA)"
if [ -n "$ZIP" ]; then [ "$(sha256 "$ZIP")" = "$ZIP_SHA256" ] || die "not the official 3.5.0 source zip"; fi

export SOURCE_DATE_EPOCH=1795392000 LC_ALL=C TZ=UTC
W="$OUT/work"; rm -rf "$W"; mkdir -p "$W/gen" "$W/fg"; cd "$W"
if [ -n "$ZIP" ]; then
  mkdir unz && (cd unz && unzip -q "$ZIP") && mv unz/Argyll_V3.5.0 argyll && rmdir unz
else
  ln -s "$TREE" argyll
fi
[ -f argyll/spectro/chartread.c ] && [ -f argyll/h/aconfig.h ] || die "not an ArgyllCMS source tree"
A=argyll
cp "$A/h/aconfig.h" gen/sa_config.h
cp "$A/spectro/chartread.c" gen/chartread.c
if [ -n "$STOCK" ]; then [ -n "$FAKE" ] || die "--stock is for fake-instrument test builds only"
else patch --no-backup-if-mismatch -s gen/chartread.c "$PATCH"; fi
cp "$SRC/fg_sa_compat.c" "$SRC/fg_sa_compat.h" fg/

OS="$(uname -s)"
CC="${CC:-cc}"
CFLAGS=(-O2 -std=gnu99 -DSALONEINSTLIB -DUNIX -ffile-prefix-map="$W"=.
        -Wno-sign-compare -Wno-implicit-function-declaration -Wno-incompatible-pointer-types
        -Wno-int-conversion -Wno-unused-result -Wno-format-overflow -Wno-stringop-truncation
        -Igen -I$A/spectro -I$A/numlib -I$A/cgats -I$A/rspl -I$A/xicc -I$A/h -I$A/target)
LIBS=(-lm -lpthread)
USBLIBS=()
if [ "$OS" = Darwin ]; then
  CC="${CC_DARWIN:-clang}"
  # freeglaz.app declares LSMinimumSystemVersion 14.0 and its build refuses a Mach-O that
  # needs a newer macOS: build for 14.0 unless told otherwise.
  export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-14.0}"
  CFLAGS+=(-Wno-unknown-warning-option)
  LIBS+=(-framework CoreFoundation -framework AudioToolbox -lobjc)
  USBLIBS=(-framework IOKit)
fi
CORE=($A/numlib/numsup.c $A/cgats/pars.c $A/cgats/cgats.c $A/xicc/xspect.c $A/rspl/rspl1.c
      $A/xicc/xcal.c $A/xicc/xcolorants.c $A/xicc/ccss.c $A/xicc/ccmx.c $A/spectro/conv.c
      $A/spectro/sa_conv.c $A/spectro/insttypes.c $A/spectro/instappsup.c $A/spectro/xdg_bds.c
      $A/spectro/aglob.c $A/spectro/disptechs.c $A/spectro/xrga.c $A/spectro/pollem.c
      $A/target/alphix.c)
# USB and HID drivers; the serial-only ones (dtp22 dtp41 dtp51 ss ss_imp specbos kleink10
# smcube) are left out and ENABLE_SERIAL / ENABLE_FAST_SERIAL are not defined.
USB=()
for d in inst icoms usbio hidio rspec dtp20 dtp92 i1disp i1d3 i1pro i1pro_imp i1pro3 \
         i1pro3_imp munki munki_imp hcfr huey colorhug spyd2 spydX spydX2 base64 oemarch \
         vinflate inflate LzmaDec; do USB+=("$A/spectro/$d.c"); done

MARKERS=("Save the .ti3 after each strip pass" "passes read so far are saved"
         "Checkpoint: %d patches saved to" "Checkpoint not saved" "Checkpoint not durable")
[ "$OS" = Darwin ] && MARKERS+=("Checkpoint durability reduced")

if [ -z "$FAKE" ]; then
  BIN=chartread-fgK
  UNITS=(gen/chartread.c "${CORE[@]}" "${USB[@]}" fg/fg_sa_compat.c)
  "$CC" "${CFLAGS[@]}" -DENABLE_USB -DALLINSTS -include fg/fg_sa_compat.h -o "$BIN" \
        "${UNITS[@]}" "${LIBS[@]}" ${USBLIBS[@]+"${USBLIBS[@]}"}
  chmod 644 "$BIN"                                  # built, never run by this script
  DEPFLAGS=(-DENABLE_USB -DALLINSTS -include fg/fg_sa_compat.h)
  # static checks: no serial driver, no serial device name. nm must work (an empty listing
  # would pass every "absent" check), and a known USB driver symbol must be seen in it.
  SYMS="$(nm "$BIN")" || die "nm failed on $BIN"
  grep -q -E ' T _?hid_close_port$' <<<"$SYMS" || die "nm listing unusable: no USB symbol in $BIN"
  if grep -E ' T _?new_(dtp22|dtp41|dtp51|ss|specbos|kleink10|smcube)$' <<<"$SYMS"; then
    die "serial driver symbol in $BIN"; fi
  for s in /dev/ttyS ttyUSB /dev/cu. /dev/tty.; do
    if grep -a -q -F "$s" "$BIN"; then die "serial device name '$s' in $BIN"; fi; done
else
  BIN=chartread-fgK-fake; [ -n "$STOCK" ] && BIN=chartread-stock-fake && MARKERS=()
  cp "$FAKE" fg/fg_fakeinst.c
  UNITS=(gen/chartread.c fg/fg_fakeinst.c "${CORE[@]}")
  "$CC" "${CFLAGS[@]}" -o "$BIN" "${UNITS[@]}" "${LIBS[@]}"
  DEPFLAGS=()
  # nm must work and list main; Mach-O symbols carry a leading underscore (_usb_…)
  SYMS="$(nm "$BIN")" || die "nm failed on $BIN"
  grep -q -E ' T _?main$' <<<"$SYMS" || die "nm listing unusable: no main in $BIN"
  if grep -i -E ' _?(usb_|icoms_|hid_|ser_|new_icompaths_usb|usbio)' <<<"$SYMS"; then
    die "USB/serial symbol in the fake build"; fi
  grep -a -q "only drives a fake instrument" "$BIN" || die "fake build without its banner"
fi
for m in ${MARKERS[@]+"${MARKERS[@]}"}; do grep -a -q -F "$m" "$BIN" || die "marker missing: $m"; done

# every source file and header compiled into the binary (corresponding source, licences)
for u in "${UNITS[@]}"; do "$CC" "${CFLAGS[@]}" ${DEPFLAGS[@]+"${DEPFLAGS[@]}"} -MM "$u"; done \
  | sed -e 's/^[^:]*://' -e 's/\\$//' | tr ' ' '\n' | grep -v '^$' | sort -u > ../$BIN.sources

mv "$BIN" ../
cd ..
{ echo "binary $BIN"; echo "sha256 $(sha256 "$BIN")"; echo "patch $([ -n "$STOCK" ] && echo "none (official chartread.c)" || echo "v$PVER $PSHA")"
  echo "argyll 3.5.0 $ZIP_SHA256"; echo "os $OS $(uname -m)"; echo "cc $("$CC" --version | head -1)"
  echo "ld $(ld -v 2>&1 | head -1)"
  [ "$OS" = Darwin ] && echo "macos_target $MACOSX_DEPLOYMENT_TARGET sdk $(xcrun --show-sdk-version 2>/dev/null)"
  true; } > "$BIN.buildinfo"
cat "$BIN.buildinfo"
