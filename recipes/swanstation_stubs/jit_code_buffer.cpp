// Switch (libnx) stub of JitCodeBuffer.
//
// libnx exposes RW+X memory only via svcSetProcessMemoryPermission on a
// dynamically-allocated ELF segment, which is significantly more involved
// than the POSIX mmap path the upstream uses. The recompiler is disabled in
// our build (CPU runs through the interpreter), so we just need the symbol
// resolution to succeed — Allocate() returning false is fine because the
// recompiler is never asked to use it.
//
// Upstream dropped the `u32` typedef from common/types.h — header signatures
// are spelled `uint32_t` now. Match exactly so the linker resolves the
// out-of-line definitions to declarations in jit_code_buffer.h. The previous
// stub also declared two extra ctors (`(size, far)` and `(buffer, size, far,
// guard)`) that don't exist in upstream's header anymore; drop them.

#include "common/jit_code_buffer.h"

#include <cstdint>
#include <cstdlib>

JitCodeBuffer::JitCodeBuffer() = default;

JitCodeBuffer::~JitCodeBuffer()
{
  Destroy();
}

bool JitCodeBuffer::Allocate(uint32_t /*size*/, uint32_t /*far_code_size*/)
{
  return false;
}

bool JitCodeBuffer::Initialize(void* /*buffer*/, uint32_t /*size*/, uint32_t /*far_code_size*/, uint32_t /*guard_size*/)
{
  return false;
}

void JitCodeBuffer::Destroy()
{
  if (m_owns_buffer && m_code_ptr)
    std::free(m_code_ptr);
  m_code_ptr = nullptr;
  m_free_code_ptr = nullptr;
  m_code_size = 0;
  m_total_size = 0;
  m_owns_buffer = false;
}

void JitCodeBuffer::Reset()
{
  m_free_code_ptr = m_code_ptr;
  m_code_used = 0;
  m_free_far_code_ptr = m_far_code_ptr;
  m_far_code_used = 0;
}

void JitCodeBuffer::ReserveCode(uint32_t size)
{
  m_code_reserve_size = size;
}

void JitCodeBuffer::CommitCode(uint32_t length)
{
  m_free_code_ptr += length;
  m_code_used += length;
}

void JitCodeBuffer::CommitFarCode(uint32_t length)
{
  m_free_far_code_ptr += length;
  m_far_code_used += length;
}

void JitCodeBuffer::Align(uint32_t /*alignment*/, uint8_t /*padding_value*/) {}

void JitCodeBuffer::FlushInstructionCache(void* /*address*/, uint32_t /*size*/) {}
