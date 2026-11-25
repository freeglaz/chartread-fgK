/* fg_sa_compat.h - part of chartread-fgK (not part of the official ArgyllCMS).
 *
 * Copyright 2026 the freeglaz contributors.
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * Force-included (-include) when chartread is built with the real USB drivers in
 * ArgyllCMS 3.5.0's standalone instrument-library mode (SALONEINSTLIB): the USB/HID back
 * ends use two symbols of Argyll's ICC library that the standalone file list does not
 * carry. See fg_sa_compat.c. */
#ifndef FG_SA_COMPAT_H
#define FG_SA_COMPAT_H
#include <stddef.h>
#include <stdint.h>
typedef uint16_t icmUTF16;
size_t icmUTF16toUTF8(void *pillegal, unsigned char *out, icmUTF16 *in);
#endif
