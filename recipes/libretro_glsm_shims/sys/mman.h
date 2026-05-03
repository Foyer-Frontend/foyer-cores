// Foyer shim — Switch newlib doesn't ship <sys/mman.h>. parallel-n64's
// recomp.c uses mmap to allocate translation cache blocks. We don't run
// the dynarec on Switch (no W^X-flippable single-VA mapping is exposed
// by libnx Jit), so the executable-permission semantics don't matter:
// the cached_interp consumes these blocks for AST caching, not for
// executable code. Forward to malloc/free.

#ifndef FOYER_SYS_MMAN_H
#define FOYER_SYS_MMAN_H

#include <stdlib.h>
#include <stddef.h>
#include <sys/types.h>
#include <stdint.h>

#define PROT_NONE   0
#define PROT_READ   1
#define PROT_WRITE  2
#define PROT_EXEC   4

#define MAP_SHARED    1
#define MAP_PRIVATE   2
#define MAP_ANON      0x20
#define MAP_ANONYMOUS MAP_ANON
#define MAP_FIXED     0x10

#define MAP_FAILED ((void*)-1)

static inline void* mmap(void* addr, size_t length, int prot, int flags,
                         int fd, off_t offset) {
    (void)addr; (void)prot; (void)flags; (void)fd; (void)offset;
    void* p = malloc(length);
    return p ? p : MAP_FAILED;
}

static inline int munmap(void* addr, size_t length) {
    (void)length;
    free(addr);
    return 0;
}

static inline int mprotect(void* addr, size_t len, int prot) {
    (void)addr; (void)len; (void)prot;
    return 0;
}

#endif
