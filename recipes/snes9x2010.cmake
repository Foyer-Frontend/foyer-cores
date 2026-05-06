# cores/snes9x2010.cmake — libretro snes9x2010 (older lighter SNES
# fork). Lower CPU/thermals than the modern snes9x; uses the legacy
# Snes9x 1.43 codebase frozen circa 2010.

include(FetchContent)

FetchContent_Declare(libretro_snes9x2010
    GIT_REPOSITORY https://github.com/libretro/snes9x2010.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_snes9x2010)

set(_S10    ${libretro_snes9x2010_SOURCE_DIR})
set(_S10_LR ${_S10}/libretro/libretro-common)

add_library(core_snes9x2010 STATIC
    ${_S10}/src/apu.c
    ${_S10}/src/bsx.c
    ${_S10}/src/c4emu.c
    ${_S10}/src/cheats.c
    ${_S10}/src/controls.c
    ${_S10}/src/cpu.c
    ${_S10}/src/cpuexec.c
    ${_S10}/src/dsp.c
    ${_S10}/src/fxemu.c
    ${_S10}/src/globals.c
    ${_S10}/src/memmap.c
    ${_S10}/src/obc1.c
    ${_S10}/src/ppu.c
    ${_S10}/src/sa1.c
    ${_S10}/src/sdd1.c
    ${_S10}/src/seta.c
    ${_S10}/src/snapshot.c
    ${_S10}/src/spc7110.c
    ${_S10}/src/srtc.c
    ${_S10}/src/tile.c
    ${_S10}/src/hwregisters.c
    ${_S10}/filter/snes_ntsc.c
    ${_S10}/libretro/libretro.c
    # libretro-common (upstream gates these on STATIC_LINKING != 1
    # but our player binary doesn't supply them either).
    ${_S10_LR}/streams/memory_stream.c
    ${_S10_LR}/compat/compat_posix_string.c
    ${_S10_LR}/compat/compat_strcasestr.c
    ${_S10_LR}/compat/compat_snprintf.c
    ${_S10_LR}/compat/compat_strl.c
    ${_S10_LR}/compat/fopen_utf8.c
    ${_S10_LR}/encodings/encoding_utf.c
    ${_S10_LR}/file/file_path.c
    ${_S10_LR}/file/file_path_io.c
    ${_S10_LR}/streams/file_stream.c
    ${_S10_LR}/streams/file_stream_transforms.c
    ${_S10_LR}/string/stdstring.c
    ${_S10_LR}/time/rtime.c
    ${_S10_LR}/vfs/vfs_implementation.c
)

target_include_directories(core_snes9x2010 PUBLIC
    ${_S10}/libretro
    ${_S10}/src
    ${_S10_LR}/include
)

target_compile_definitions(core_snes9x2010 PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    INLINE=inline
    RIGHTSHIFT_IS_SAR
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_snes9x2010 PRIVATE -w -fno-strict-aliasing -U__linux__ -U__linux)

set_target_properties(core_snes9x2010 PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
