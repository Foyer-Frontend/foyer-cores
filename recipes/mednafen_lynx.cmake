# recipes/mednafen_lynx.cmake — libretro Beetle Lynx
# (Mednafen Atari Lynx module, alternative to handy).

include(FetchContent)

FetchContent_Declare(libretro_mednafen_lynx
    GIT_REPOSITORY https://github.com/libretro/beetle-lynx-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_mednafen_lynx)

set(_LYNX     ${libretro_mednafen_lynx_SOURCE_DIR})
set(_LYNX_M   ${_LYNX}/mednafen)
set(_LYNX_E   ${_LYNX_M}/lynx)
set(_LYNX_CC  ${_LYNX}/libretro-common)

set(_LYNX_CXX
    ${_LYNX_E}/cart.cpp
    ${_LYNX_E}/c65c02.cpp
    ${_LYNX_E}/memmap.cpp
    ${_LYNX_E}/mikie.cpp
    ${_LYNX_E}/ram.cpp
    ${_LYNX_E}/rom.cpp
    ${_LYNX_E}/susie.cpp
    ${_LYNX_E}/system.cpp
    ${_LYNX_M}/sound/Blip_Buffer.cpp
    ${_LYNX_M}/sound/Stereo_Buffer.cpp
    ${_LYNX_M}/settings.cpp
    ${_LYNX_M}/state.cpp
    ${_LYNX_M}/mempatcher.cpp
    ${_LYNX_M}/md5.cpp
    ${_LYNX_M}/endian.cpp
    ${_LYNX}/libretro.cpp
)

set(_LYNX_C
    ${_LYNX_CC}/streams/file_stream.c
    ${_LYNX_CC}/compat/fopen_utf8.c
    ${_LYNX_CC}/compat/compat_posix_string.c
    ${_LYNX_CC}/compat/compat_snprintf.c
    ${_LYNX_CC}/compat/compat_strl.c
    ${_LYNX_CC}/compat/compat_strcasestr.c
    ${_LYNX_CC}/encodings/encoding_utf.c
    ${_LYNX_CC}/file/file_path.c
    ${_LYNX_CC}/vfs/vfs_implementation.c
    ${_LYNX_CC}/time/rtime.c
    ${_LYNX_CC}/string/stdstring.c
    ${_LYNX_M}/file.c
    ${_LYNX}/scrc32.c
)

add_library(core_mednafen_lynx STATIC ${_LYNX_CXX} ${_LYNX_C})
target_include_directories(core_mednafen_lynx PUBLIC
    ${_LYNX}
    ${_LYNX_M}
    ${_LYNX_M}/include
    ${_LYNX_M}/intl
    ${_LYNX_M}/hw_sound
    ${_LYNX_M}/hw_cpu
    ${_LYNX_M}/hw_misc
    ${_LYNX_CC}/include
)
target_compile_definitions(core_mednafen_lynx PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    LSB_FIRST=1
    HAVE_STDINT_H=1
    INLINE=inline
    FRONTEND_SUPPORTS_RGB565=1
    NEED_BLIP=1
    NEED_CRC32=1
    MEDNAFEN_VERSION=\"foyer-0.2\"
    MEDNAFEN_VERSION_NUMERIC=0
    PSS_STYLE=1
    SIZEOF_DOUBLE=8
)
target_compile_options(core_mednafen_lynx PRIVATE -w)
set_target_properties(core_mednafen_lynx PROPERTIES
    C_STANDARD 99 C_STANDARD_REQUIRED ON
    CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
