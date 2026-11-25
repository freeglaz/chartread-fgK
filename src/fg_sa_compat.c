/* fg_sa_compat.c - part of chartread-fgK (not part of the official ArgyllCMS).
 *
 * Copyright 2026 the freeglaz contributors.
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * See fg_sa_compat.h: a UTF-16 to UTF-8 conversion for the USB string descriptors, and a
 * stub for the EX1 driver, whose source does not compile in 3.5.0's standalone mode (a
 * spot-only instrument, irrelevant to strip reading): no EX1 can be opened. */
#include "fg_sa_compat.h"
#include <stdlib.h>

size_t icmUTF16toUTF8(void *pillegal, unsigned char *out, icmUTF16 *in) {
	size_t n = 0;
	(void)pillegal;
	for (; *in != 0; in++) {
		unsigned int c = *in;
		unsigned char b[3];
		int k;
		if (c < 0x80) { b[0] = (unsigned char)c; k = 1; }
		else if (c < 0x800) { b[0] = 0xC0 | (c >> 6); b[1] = 0x80 | (c & 0x3F); k = 2; }
		else { b[0] = 0xE0 | (c >> 12); b[1] = 0x80 | ((c >> 6) & 0x3F); b[2] = 0x80 | (c & 0x3F); k = 3; }
		if (out != NULL) { int i; for (i = 0; i < k; i++) out[n + i] = b[i]; }
		n += k;
	}
	if (out != NULL)
		out[n] = 0;
	return n;
}

void *new_ex1(void *icom, int dtype) { (void)icom; (void)dtype; return NULL; }
