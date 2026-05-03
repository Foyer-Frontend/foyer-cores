# recipes/gpsp.cmake — libretro gpsp (fast GBA core with ARM64 dynarec).

include(FetchContent)

FetchContent_Declare(libretro_gpsp
    GIT_REPOSITORY https://github.com/libretro/gpsp.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_gpsp)

set(_GPSP    ${libretro_gpsp_SOURCE_DIR})
set(_GPSP_CC ${_GPSP}/libretro/libretro-common)

set(_GPSP_C
    ${_GPSP}/main.c
    ${_GPSP}/gba_memory.c
    ${_GPSP}/savestate.c
    ${_GPSP}/input.c
    ${_GPSP}/sound.c
    ${_GPSP}/cheats.c
    # memmap.c omitted — its map_jit_block / unmap_jit_block /
    # validate_addr_* implementations are POSIX-mmap-based.
    # gpsp_jit_switch.c (below) provides Switch versions on top of
    # libnx's Jit API.
    ${_GPSP}/serial.c
    ${_GPSP}/gbp.c
    ${_GPSP}/rfu.c
    ${_GPSP}/serial_proto.c
    ${_GPSP}/libretro/libretro.c
    ${_GPSP}/gba_cc_lut.c
    # arm64 dynarec — uses arm/arm64_{emit,codegen}.h + arm64_stub.S.
    # The translation caches are allocated at runtime in the Switch
    # JIT shim (gpsp_jit_switch.c) via libnx's Jit API since Switch
    # homebrew can't directly mmap PROT_EXEC pages.
    ${_GPSP}/cpu_threaded.c
    ${CMAKE_CURRENT_LIST_DIR}/gpsp_jit_switch.c
    ${_GPSP_CC}/compat/compat_posix_string.c
    ${_GPSP_CC}/compat/compat_strl.c
    ${_GPSP_CC}/compat/fopen_utf8.c
    ${_GPSP_CC}/encodings/encoding_utf.c
    ${_GPSP_CC}/file/file_path.c
    ${_GPSP_CC}/file/file_path_io.c
    ${_GPSP_CC}/streams/file_stream.c
    ${_GPSP_CC}/string/stdstring.c
    ${_GPSP_CC}/time/rtime.c
    ${_GPSP_CC}/vfs/vfs_implementation.c
)
set(_GPSP_CXX
    ${_GPSP}/video.cc
    ${_GPSP}/cpu.cc
)
# arm64 dynarec stub. CMake's ASM language picks up .S via the C compiler
# preprocessor, which is what gpsp's Makefile does.
set(_GPSP_ASM
    ${_GPSP}/bios_data.S
    ${_GPSP}/arm/arm64_stub.S    # dynarec hooks (a64_update_gba etc.)
)

# .S files want the C preprocessor + assembler. CMake's ASM language
# routes them through the toolchain's assembler driver which on
# devkitA64 is aarch64-none-elf-as via gcc -x assembler-with-cpp.
enable_language(ASM)
set_source_files_properties(${_GPSP_ASM} PROPERTIES LANGUAGE ASM)

add_library(core_gpsp STATIC ${_GPSP_C} ${_GPSP_CXX} ${_GPSP_ASM})
target_include_directories(core_gpsp PUBLIC
    ${_GPSP}
    ${_GPSP}/libretro
    ${_GPSP_CC}/include
)
target_compile_definitions(core_gpsp PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    HAVE_STRINGS_H=1
    HAVE_STDINT_H=1
    HAVE_INTTYPES_H=1
    INLINE=inline
    NDEBUG=1
    # ARM64 dynarec — emitter at arm/arm64_emit.h is selected via
    # ARM64_ARCH. MMAP_JIT_CACHE makes cpu.h declare the translation
    # caches as runtime-allocated pointers (set in gpsp_jit_switch.c
    # using libnx's Jit API) instead of fixed-size arrays.
    HAVE_DYNAREC=1
    ARM64_ARCH=1
    MMAP_JIT_CACHE=1
    FRONTEND_SUPPORTS_RGB565=1
)
target_compile_options(core_gpsp PRIVATE -w -fno-strict-aliasing)
set_target_properties(core_gpsp PROPERTIES
    C_STANDARD 99 C_STANDARD_REQUIRED ON
    CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
