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
    # cpu_threaded.c, arm64_stub.S and gpsp_jit_switch.c removed —
    # the dynarec path is currently unsafe on Switch (the JIT shim
    # hands out the rw_addr alias which isn't executable, branches
    # into freshly-emitted blocks trap with a wild PC). Interpreter
    # path in cpu.cc covers correctness; revisit once the JIT shim
    # patches gpsp's emitter to use the rx_addr alias for branches.
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
    # arm64_stub.S removed alongside the dynarec — see SOURCES note.
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
    # Dynarec disabled. gpsp_jit_switch.c hands out the writable
    # alias of the libnx Jit dual-view (rw_addr) for both emit-time
    # writes AND runtime branches. Switch homebrew can't execute
    # writable pages, so the first branch into a freshly-emitted
    # block traps with a wild PC — atmosphère report 01778012016
    # caught exactly that. The proper fix is patching the gpsp
    # emitter to call gpsp_jit_translate_to_rx() before branching
    # (or swapping the cache to rx_addr at run-time); until that's
    # done, fall back to the interpreter so the core *runs*. GBA
    # interpreter on Switch is slower than dynarec but still well
    # above 60 fps for most titles.
    #
    # HAVE_DYNAREC + ARM64_ARCH + MMAP_JIT_CACHE intentionally
    # omitted; gpsp's cpu.c picks the C interpreter when none of
    # them are defined.
    FRONTEND_SUPPORTS_RGB565=1
)
target_compile_options(core_gpsp PRIVATE -w -fno-strict-aliasing)
set_target_properties(core_gpsp PROPERTIES
    C_STANDARD 99 C_STANDARD_REQUIRED ON
    CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
