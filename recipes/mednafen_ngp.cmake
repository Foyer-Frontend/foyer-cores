# recipes/mednafen_ngp.cmake — libretro Beetle NGP
# (Mednafen NGP/NGPC module, alternative to RACE).
#
# UNTESTED. Source list mirrors libretro/beetle-ngp-libretro's
# Makefile.common.

include(FetchContent)

FetchContent_Declare(libretro_mednafen_ngp
    GIT_REPOSITORY https://github.com/libretro/beetle-ngp-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_mednafen_ngp)

set(_NGP ${libretro_mednafen_ngp_SOURCE_DIR})

set(_NGP_CXX
    ${_NGP}/mednafen/ngp/sound.cpp
    ${_NGP}/mednafen/ngp/T6W28_Apu.cpp
    ${_NGP}/mednafen/mempatcher.cpp
    ${_NGP}/mednafen/sound/Stereo_Buffer.cpp
    ${_NGP}/mednafen/sound/Blip_Buffer.cpp
)
set(_NGP_C
    ${_NGP}/mednafen/ngp/biosHLE.c
    ${_NGP}/mednafen/ngp/bios.c
    ${_NGP}/mednafen/ngp/flash.c
    ${_NGP}/mednafen/ngp/dma.c
    ${_NGP}/mednafen/ngp/gfx.c
    ${_NGP}/mednafen/ngp/interrupt.c
    ${_NGP}/mednafen/ngp/mem.c
    ${_NGP}/mednafen/ngp/rom.c
    ${_NGP}/mednafen/ngp/system.c
    ${_NGP}/mednafen/ngp/TLCS-900h/TLCS900h_interpret.c
    ${_NGP}/mednafen/ngp/TLCS-900h/TLCS900h_interpret_dst.c
    ${_NGP}/mednafen/ngp/TLCS-900h/TLCS900h_interpret_reg.c
    ${_NGP}/mednafen/ngp/TLCS-900h/TLCS900h_interpret_single.c
    ${_NGP}/mednafen/ngp/TLCS-900h/TLCS900h_interpret_src.c
    ${_NGP}/mednafen/ngp/TLCS-900h/TLCS900h_registers.c
    ${_NGP}/mednafen/hw_cpu/z80-fuse/z80_ops.c
    ${_NGP}/mednafen/hw_cpu/z80-fuse/z80.c
    ${_NGP}/mednafen/ngp/rtc.c
    ${_NGP}/mednafen/ngp/Z80_interface.c
    ${_NGP}/mednafen/state.c
    ${_NGP}/libretro.c
    ${_NGP}/libretro-common/streams/file_stream.c
    ${_NGP}/libretro-common/compat/fopen_utf8.c
    ${_NGP}/libretro-common/compat/compat_strl.c
    ${_NGP}/libretro-common/compat/compat_snprintf.c
    ${_NGP}/libretro-common/encodings/encoding_utf.c
    ${_NGP}/libretro-common/vfs/vfs_implementation.c
    ${_NGP}/libretro-common/file/file_path.c
    ${_NGP}/libretro-common/time/rtime.c
    ${_NGP}/libretro-common/string/stdstring.c
    ${_NGP}/libretro-common/compat/compat_posix_string.c
    ${_NGP}/mednafen/settings.c
)

add_library(core_mednafen_ngp STATIC ${_NGP_CXX} ${_NGP_C})
target_include_directories(core_mednafen_ngp PUBLIC
    ${_NGP}
    ${_NGP}/mednafen
    ${_NGP}/mednafen/include
    ${_NGP}/mednafen/intl
    ${_NGP}/mednafen/hw_sound
    ${_NGP}/mednafen/hw_cpu
    ${_NGP}/mednafen/hw_misc
    ${_NGP}/libretro-common/include
)
target_compile_definitions(core_mednafen_ngp PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    LSB_FIRST=1
    HAVE_STDINT_H=1
    # Don't override INLINE — mednafen's z80.h declares functions with
    # `static INLINE`, so expanding INLINE to `static inline` produces
    # `static static inline` (duplicate 'static' error).
    INLINE=inline
    FRONTEND_SUPPORTS_RGB565=1
    MEDNAFEN_VERSION=\"foyer-0.2\"
    MEDNAFEN_VERSION_NUMERIC=0
    PSS_STYLE=1
    SIZEOF_DOUBLE=8
)
target_compile_options(core_mednafen_ngp PRIVATE -w)
set_target_properties(core_mednafen_ngp PROPERTIES
    C_STANDARD                99
    C_STANDARD_REQUIRED       ON
    CXX_STANDARD              11
    CXX_STANDARD_REQUIRED     ON
    POSITION_INDEPENDENT_CODE ON)
