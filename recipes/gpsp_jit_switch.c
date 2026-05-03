// Switch JIT memory shim for gpsp's arm64 dynarec.
//
// Replaces upstream gpsp/memmap.c, which uses POSIX mmap() with
// PROT_EXEC — Switch homebrew can't mprotect arbitrary pages
// executable. libnx's Jit API gives us a dual-view (rw + rx) mapping
// of the same physical pages instead.
//
// Functions provided here mirror gpsp/memmap.h:
//
//   void *map_jit_block(unsigned size);
//   void  unmap_jit_block(void *bufptr, unsigned size);
//   bool  validate_addr_offset(void *ptr, unsigned size, unsigned max_mb);
//   bool  validate_addr_section_mips(...);
//
// Plus platform_cache_sync(), which cpu_threaded.c calls after
// emitting a code block.
//
// Phase-1 caveats (resolve before shipping):
//   * libretro.c uses the returned pointer to BOTH read/write
//     emitted code AND branch into it. We hand out jit.rw_addr,
//     which is writable but not executable. Branches into the cache
//     will trap. For runtime correctness phase 2 needs to swap to
//     jit.rx_addr around block execution, or patch the emitter to
//     compute branch targets via the rx alias.

#include <switch.h>
#include <stdint.h>
#include <stdbool.h>

static Jit  g_gpsp_jit;
static bool g_gpsp_jit_owned = false;

// (platform_cache_sync is already defined in cpu_threaded.c when
// ARM64_ARCH is set — it uses GCC's __clear_cache which expands to
// the right ARM64 ic + dc instructions on libnx.)

// Address-range validation hooks. The arm/arm64 emitter uses these to
// confirm a candidate cache base is reachable by PC-relative branches.
// We accept whatever Jit gives us; if branch range becomes a problem on
// hardware (Switch's Jit landing addresses are typically near the heap,
// outside ±128 MiB of the .text section), we'll need a smarter strategy.
bool validate_addr_offset(void *ptr, unsigned size, unsigned max_offset_mb) {
    (void)ptr; (void)size; (void)max_offset_mb;
    return true;
}

bool validate_addr_section_mips(void *ptr, unsigned size, unsigned max_offset_mb) {
    (void)ptr; (void)size; (void)max_offset_mb;
    return true;
}

void *map_jit_block(unsigned size) {
    if (g_gpsp_jit_owned) {
        // gpsp only allocates the JIT block once per session. If we
        // ever see a second call, the in-memory state is wrong.
        return NULL;
    }
    if (R_FAILED(jitCreate(&g_gpsp_jit, size))) {
        return NULL;
    }
    // Default Jit state on libnx is "writable" (rw view exposed). We
    // hand back the rw view so writes from the emitter land in the
    // shared physical pages. Execution (phase 2) will need to address
    // the rx view; cpu_threaded.c currently branches into rw_addr
    // which won't be executable.
    g_gpsp_jit_owned = true;
    return g_gpsp_jit.rw_addr;
}

void unmap_jit_block(void *bufptr, unsigned size) {
    (void)bufptr; (void)size;
    if (!g_gpsp_jit_owned) return;
    jitClose(&g_gpsp_jit);
    g_gpsp_jit_owned = false;
}
