# recipes/genesis_plus_gx_wide.cmake — libretro Genesis Plus GX Wide
# (a fork of Genesis Plus GX with the H40 widescreen patch integrated).
#
# Mirrors the genesisplusgx recipe — same source layout, same defines —
# pointed at the Wide fork. Useful when the user wants 16:9 fit on
# Genesis / Mega Drive titles that the Wide patch supports.

include(FetchContent)

FetchContent_Declare(libretro_gpgxw
    GIT_REPOSITORY https://github.com/libretro/Genesis-Plus-GX-Wide.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_gpgxw)

set(_GPGXW       ${libretro_gpgxw_SOURCE_DIR})
set(_GPGXW_LR    ${_GPGXW}/libretro)
set(_GPGXW_COMM  ${_GPGXW_LR}/libretro-common)

set(_GPGXW_DIRS
    ${_GPGXW}/core
    ${_GPGXW}/core/z80
    ${_GPGXW}/core/m68k
    ${_GPGXW}/core/ntsc
    ${_GPGXW}/core/sound
    ${_GPGXW}/core/sound/minimp3
    ${_GPGXW}/core/sound/tremor
    ${_GPGXW}/core/input_hw
    ${_GPGXW}/core/cd_hw
    ${_GPGXW}/core/cart_hw
    ${_GPGXW}/core/cart_hw/svp
)
set(_GPGXW_C "")
foreach(_d ${_GPGXW_DIRS})
    file(GLOB _src "${_d}/*.c")
    list(APPEND _GPGXW_C ${_src})
endforeach()

list(APPEND _GPGXW_C
    ${_GPGXW_LR}/libretro.c
    ${_GPGXW_COMM}/streams/file_stream.c
    ${_GPGXW_COMM}/streams/file_stream_transforms.c
    ${_GPGXW_COMM}/compat/fopen_utf8.c
    ${_GPGXW_COMM}/compat/compat_snprintf.c
    ${_GPGXW_COMM}/compat/compat_strl.c
    ${_GPGXW_COMM}/compat/compat_strcasestr.c
    ${_GPGXW_COMM}/compat/compat_posix_string.c
    ${_GPGXW_COMM}/encodings/encoding_utf.c
    ${_GPGXW_COMM}/file/file_path.c
    ${_GPGXW_COMM}/file/retro_dirent.c
    ${_GPGXW_COMM}/lists/string_list.c
    ${_GPGXW_COMM}/lists/dir_list.c
    ${_GPGXW_COMM}/memmap/memalign.c
    ${_GPGXW_COMM}/string/stdstring.c
    ${_GPGXW_COMM}/vfs/vfs_implementation.c
    ${_GPGXW_LR}/deps/zlib-1.2.11/adler32.c
    ${_GPGXW_LR}/deps/zlib-1.2.11/crc32.c
    ${_GPGXW_LR}/deps/zlib-1.2.11/inffast.c
    ${_GPGXW_LR}/deps/zlib-1.2.11/inflate.c
    ${_GPGXW_LR}/deps/zlib-1.2.11/inftrees.c
    ${_GPGXW_LR}/deps/zlib-1.2.11/zutil.c
)

add_library(core_genesis_plus_gx_wide STATIC ${_GPGXW_C})
target_include_directories(core_genesis_plus_gx_wide PUBLIC
    ${_GPGXW_DIRS}
    ${_GPGXW_LR}
    ${_GPGXW_COMM}/include
)
target_compile_definitions(core_genesis_plus_gx_wide PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    HAVE_LIBNX=1
    LSB_FIRST=1
    BYTE_ORDER=LITTLE_ENDIAN
    ALIGN_LONG=1
    ALIGN_WORD=1
    M68K_OVERCLOCK_SHIFT=20
    HAVE_ZLIB=1
    "INLINE=static inline"
    USE_LIBTREMOR=1
    USE_PER_SOUND_CHANNELS_CONFIG=1
    USE_16BPP_RENDERING=1
    FRONTEND_SUPPORTS_RGB565=1
)
target_compile_options(core_genesis_plus_gx_wide PRIVATE -w)
set_target_properties(core_genesis_plus_gx_wide PROPERTIES
    C_STANDARD                99
    C_STANDARD_REQUIRED       ON
    POSITION_INDEPENDENT_CODE ON)
