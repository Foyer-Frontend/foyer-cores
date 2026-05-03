// Foyer external-symbol provider for parallel-n64's safe_rdram.h
// inline helpers. Under C99 inline rules, the bare `inline` keyword
// in safe_rdram.h declares an inline definition: callers MAY emit
// inlined code, but the linker still expects exactly one TU to
// provide an externally-visible body. Upstream relies on GNU90
// inline behavior (every call site emits a strong symbol), which
// produces multiple-definition errors when devkitA64 honors C99
// strict-inline. Force the strong external symbols here by
// re-declaring with `extern inline`.

#include <stdint.h>
#include "ri/safe_rdram.h"

extern inline uint8_t  rdram_safe_read_byte(const void *rdram, uint32_t addr);
extern inline void     rdram_safe_write_byte(void *rdram, uint32_t addr, uint8_t value);
extern inline uint32_t rdram_safe_read_word(const void *rdram, uint32_t addr);
extern inline void     rdram_safe_write_word(void *rdram, uint32_t addr, uint32_t value);
extern inline void     rdram_safe_masked_write_word(void *rdram, uint32_t addr, uint32_t value, uint32_t mask);
