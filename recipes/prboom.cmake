# cores/prboom.cmake — libretro libretro-prboom (Doom engine) core build.
#
# Self-contained: source list mirrors upstream Makefile.common's libnx
# target. Music support is enabled (HAVE_LIBMAD + MUSIC_SUPPORT — pure
# C, no extra deps); fluidsynth / vorbis / ogg are NOT (gated upstream
# behind WANT_FLUIDSYNTH=1, kept off to keep the .nro lean).

include(FetchContent)

FetchContent_Declare(libretro_prboom
    GIT_REPOSITORY https://github.com/libretro/libretro-prboom.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_prboom)

set(_PRBOOM      ${libretro_prboom_SOURCE_DIR})

# devkitPro's newlib <string.h> declares strlwr() as a real symbol,
# and prboom's d_deh.c declares its own `static char* strlwr(char*)`
# with the same name → static-declaration-follows-non-static error.
# Rename the local helper in d_deh.c (definition + every call inside
# this single TU). Idempotent — the REPLACE pattern stops matching
# once it's already prboom_strlwr.
set(_PRBOOM_DEH ${_PRBOOM}/src/d_deh.c)
if (EXISTS ${_PRBOOM_DEH})
    file(READ ${_PRBOOM_DEH} _t)
    string(REPLACE "strlwr(" "prboom_strlwr(" _t "${_t}")
    file(WRITE ${_PRBOOM_DEH} "${_t}")
endif()
set(_PRBOOM_SRC  ${_PRBOOM}/src)
set(_PRBOOM_LR   ${_PRBOOM}/libretro)
set(_PRBOOM_COMM ${_PRBOOM_LR}/libretro-common)
set(_PRBOOM_MAD  ${_PRBOOM}/deps/libmad)

# Enumerate src/*.c — upstream's Makefile.common picks ~60 of the 76
# files, but the un-listed ones either compile clean as no-ops or
# only kick in via DEMO/network paths we don't exercise. Globbing is
# the simplest way to keep up with upstream additions; if a future
# update adds a file that breaks the link, we'll surface it on CI
# and pin to a specific subset.
file(GLOB _PRBOOM_CORE_C "${_PRBOOM_SRC}/*.c")

set(_PRBOOM_LR_C
    ${_PRBOOM_LR}/libretro.c
    ${_PRBOOM_LR}/libretro_sound.c
)

set(_PRBOOM_COMM_C
    ${_PRBOOM_COMM}/compat/compat_strcasestr.c
    ${_PRBOOM_COMM}/compat/compat_snprintf.c
    ${_PRBOOM_COMM}/compat/compat_strl.c
    ${_PRBOOM_COMM}/compat/compat_posix_string.c
    ${_PRBOOM_COMM}/compat/fopen_utf8.c
    ${_PRBOOM_COMM}/encodings/encoding_utf.c
    ${_PRBOOM_COMM}/streams/file_stream.c
    ${_PRBOOM_COMM}/streams/file_stream_transforms.c
    ${_PRBOOM_COMM}/string/stdstring.c
    ${_PRBOOM_COMM}/vfs/vfs_implementation.c
    ${_PRBOOM_COMM}/file/file_path.c
    ${_PRBOOM_COMM}/file/file_path_io.c
    ${_PRBOOM_COMM}/time/rtime.c
)

set(_PRBOOM_MAD_C
    ${_PRBOOM_MAD}/bit.c
    ${_PRBOOM_MAD}/decoder.c
    ${_PRBOOM_MAD}/fixed.c
    ${_PRBOOM_MAD}/frame.c
    ${_PRBOOM_MAD}/huffman.c
    ${_PRBOOM_MAD}/layer3.c
    ${_PRBOOM_MAD}/layer12.c
    ${_PRBOOM_MAD}/stream.c
    ${_PRBOOM_MAD}/synth.c
    ${_PRBOOM_MAD}/timer.c
)

add_library(core_prboom STATIC
    ${_PRBOOM_CORE_C}
    ${_PRBOOM_LR_C}
    ${_PRBOOM_COMM_C}
    ${_PRBOOM_MAD_C}
)

target_include_directories(core_prboom PUBLIC
    ${_PRBOOM}
    ${_PRBOOM_SRC}
    ${_PRBOOM_LR}
    ${_PRBOOM_COMM}/include
    ${_PRBOOM_MAD}
)

target_compile_definitions(core_prboom PRIVATE
    HAVE_LIBMAD
    MUSIC_SUPPORT
    FPM_DEFAULT
    INLINE=inline
    FRONTEND_SUPPORTS_RGB565=1
    HAVE_LIBNX=1
    __SWITCH__=1
    SWITCH=1
    NDEBUG=1
    RARCH_INTERNAL
)

# z_zone.h is force-included on every src TU per upstream's Makefile;
# without this the custom Doom memory allocators (Z_Malloc / Z_Free)
# don't get prototyped and the build emits implicit-declaration errors.
target_compile_options(core_prboom PRIVATE
    -w
    -fno-strict-aliasing
    -include "${_PRBOOM_SRC}/z_zone.h"
)

set_target_properties(core_prboom PROPERTIES
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
