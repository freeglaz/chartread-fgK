# Notice of modification (GNU AGPL v3, section 5a)

`chartread-fgK` is a **modified version** of `spectro/chartread.c` from ArgyllCMS 3.5.0,
Copyright 1996-2013 Graeme W. Gill, licensed under the GNU Affero General Public License
version 3.

| What | Who | When |
|---|---|---|
| `spectro/chartread.c`: new `-K` option (checkpoint of the `.ti3` after each strip pass, through a temporary file that is flushed, renamed, and its directory flushed; refused, reduced and not-durable saves reported) | the freeglaz contributors | 2026-11-22 to 2026-11-23 (patch v1 to v3) |
| same file: this notice in its header comment, no code change (patch v3.1) | the freeglaz contributors | 2026-11-23 |
| `src/fg_sa_compat.[ch]`: new files, needed by the standalone USB build | the freeglaz contributors | 2026-11-23 |

The patched file carries the same notice in its header comment, and every changed place
says `freeglaz`. No other ArgyllCMS file is modified: the build compiles them as they are
in the official source zip.

This is not the official ArgyllCMS `chartread`. Problems with it go to freeglaz.

There is no warranty, as stated in sections 15 and 16 of `COPYING`.
