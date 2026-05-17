// Switch (libnx) stub of Common::PageFaultHandler.
//
// The upstream PSX recompiler installs a host page-fault handler so the
// fastmem path can recover from speculative loads/stores that miss. We don't
// build the recompiler on Switch (interpreter only), so nobody calls into
// these from the hot path. Provide trivial no-op stubs that satisfy the
// linker.
//
// Upstream dropped the `u32` typedef from common/types.h — header signatures
// are spelled `uint32_t` now. Match exactly so the linker resolves.

#include "common/page_fault_handler.h"

#include <cstdint>

namespace Common::PageFaultHandler {

uint32_t GetHandlerCodeSize()
{
  return 0;
}

bool InstallHandler(const void* /*owner*/, void* /*start_pc*/, uint32_t /*code_size*/, Callback /*callback*/)
{
  return false;
}

bool RemoveHandler(const void* /*owner*/)
{
  return false;
}

} // namespace Common::PageFaultHandler
