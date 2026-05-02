// Force-included into every TU of core_sameboy.
//
// SameBoy's Core/gb.c references getline() via its STDIN debugger
// callback. newlib (Switch's libc) doesn't ship getline, and there is
// no STDIN on Switch anyway — the callback path is unreachable in our
// build. Provide a tiny inline shim so the symbol resolves; calls from
// dead code paths return -1 (EOF) and the caller bails out.
#pragma once

#include <stddef.h>
#include <sys/types.h>

#ifndef HAVE_GETLINE
#define HAVE_GETLINE 1
static inline ssize_t getline(char **lineptr, size_t *n, void *stream) {
    (void)lineptr; (void)n; (void)stream;
    return -1;
}
#endif
