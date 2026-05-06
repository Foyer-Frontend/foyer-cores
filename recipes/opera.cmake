# cores/opera.cmake — libretro Opera (3DO Interactive Multiplayer).
# Includes libchdr + zlib for CHD support; HAVE_CHD always on.

include(FetchContent)

FetchContent_Declare(libretro_opera
    GIT_REPOSITORY https://github.com/libretro/opera-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_opera)

set(_OP    ${libretro_opera_SOURCE_DIR})
set(_OP_O  ${_OP}/libopera)
set(_OP_LR ${_OP}/libretro-common)
set(_OP_DP ${_OP}/deps)

add_library(core_opera STATIC
    ${_OP}/cuefile.c
    ${_OP}/libretro.c
    ${_OP}/libretro_core_options.c
    ${_OP}/opera_lr_nvram.c
    ${_OP}/opera_lr_callbacks.c
    ${_OP}/opera_lr_opts.c
    ${_OP}/opera_lr_dsp.c
    ${_OP}/lr_input.c
    ${_OP}/lr_input_crosshair.c
    ${_OP}/lr_input_descs.c
    ${_OP}/retro_cdimage.c
    ${_OP_O}/prng16.c
    ${_OP_O}/prng32.c
    ${_OP_O}/opera_3do.c
    ${_OP_O}/opera_arm.c
    ${_OP_O}/opera_bios.c
    ${_OP_O}/opera_bitop.c
    ${_OP_O}/opera_cdrom.c
    ${_OP_O}/opera_clio.c
    ${_OP_O}/opera_clock.c
    ${_OP_O}/opera_diag_port.c
    ${_OP_O}/opera_dsp.c
    ${_OP_O}/opera_fixedpoint_math.c
    ${_OP_O}/opera_log.c
    ${_OP_O}/opera_madam.c
    ${_OP_O}/opera_mem.c
    ${_OP_O}/opera_nvram.c
    ${_OP_O}/opera_pbus.c
    ${_OP_O}/opera_region.c
    ${_OP_O}/opera_sport.c
    ${_OP_O}/opera_state.c
    ${_OP_O}/opera_vdlp.c
    ${_OP_O}/opera_xbus.c
    ${_OP_O}/opera_xbus_cdrom_plugin.c
    # libnx-only paths from upstream (HAVE_LIBNX=1)
    ${_OP_LR}/streams/interface_stream.c
    ${_OP_LR}/streams/chd_stream.c
    # libretro-common (upstream gates these on STATIC_LINKING != 1
    # but our player binary doesn't supply them either).
    ${_OP_LR}/streams/file_stream.c
    ${_OP_LR}/streams/file_stream_transforms.c
    ${_OP_LR}/streams/memory_stream.c
    ${_OP_LR}/encodings/encoding_utf.c
    ${_OP_LR}/vfs/vfs_implementation.c
    ${_OP_LR}/compat/compat_strcasestr.c
    ${_OP_LR}/compat/compat_posix_string.c
    ${_OP_LR}/compat/compat_strl.c
    ${_OP_LR}/compat/compat_snprintf.c
    ${_OP_LR}/compat/fopen_utf8.c
    # memmap.c is a portable mmap shim that newlib's <stdlib.h>
    # transitively breaks on (implicit-decl warnings → -Werror with
    # devkitA64 15.x). Drop it; opera's CHD path doesn't use mmap on
    # libnx anyway.
    ${_OP_LR}/string/stdstring.c
    ${_OP_LR}/file/file_path.c
    ${_OP_LR}/file/retro_dirent.c
    ${_OP_LR}/lists/dir_list.c
    ${_OP_LR}/lists/string_list.c
    ${_OP_LR}/memmap/memalign.c
    # libchdr + zlib + lzma
    ${_OP_DP}/lzma-19.00/src/Alloc.c
    ${_OP_DP}/lzma-19.00/src/Bra86.c
    ${_OP_DP}/lzma-19.00/src/BraIA64.c
    ${_OP_DP}/lzma-19.00/src/CpuArch.c
    ${_OP_DP}/lzma-19.00/src/Delta.c
    ${_OP_DP}/lzma-19.00/src/LzFind.c
    ${_OP_DP}/lzma-19.00/src/Lzma86Dec.c
    ${_OP_DP}/lzma-19.00/src/Lzma86Enc.c
    ${_OP_DP}/lzma-19.00/src/LzmaDec.c
    ${_OP_DP}/lzma-19.00/src/LzmaEnc.c
    ${_OP_DP}/lzma-19.00/src/Sort.c
    ${_OP_DP}/libchdr/src/libchdr_bitstream.c
    ${_OP_DP}/libchdr/src/libchdr_cdrom.c
    ${_OP_DP}/libchdr/src/libchdr_chd.c
    ${_OP_DP}/libchdr/src/libchdr_flac.c
    ${_OP_DP}/libchdr/src/libchdr_huffman.c
    ${_OP_DP}/zlib-1.2.11/adler32.c
    ${_OP_DP}/zlib-1.2.11/crc32.c
    ${_OP_DP}/zlib-1.2.11/inffast.c
    ${_OP_DP}/zlib-1.2.11/inflate.c
    ${_OP_DP}/zlib-1.2.11/inftrees.c
    ${_OP_DP}/zlib-1.2.11/zutil.c
)

target_include_directories(core_opera PUBLIC
    ${_OP}
    ${_OP_O}
    ${_OP_LR}/include
    ${_OP_DP}
    ${_OP_DP}/lzma-19.00/include
    ${_OP_DP}/libchdr/include
    ${_OP_DP}/zlib-1.2.11
)

target_compile_definitions(core_opera PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    HAVE_STDINT_H=1
    HAVE_STDLIB_H=1
    HAVE_SYS_PARAM_H=1
    HAVE_CHD=1
    _7ZIP_ST=1
    DR_FLAC_NO_STDIO=1
    INLINE=inline
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_opera PRIVATE -w -fno-strict-aliasing)

set_target_properties(core_opera PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
