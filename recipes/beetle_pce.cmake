# cores/beetle_pce.cmake — libretro Beetle PCE (Mednafen PC Engine /
# TG16, including CD support).
#
# HAVE_GRIFFIN=0 (one TU per file). Source list mirrors upstream
# Makefile.common's libnx target with the Makefile-provided defaults:
#   HAVE_CHD=1, HAVE_HES=0, NEED_BPP=16, NEED_TREMOR=1, NEED_BLIP=1,
#   FRONTEND_SUPPORTS_RGB565=1, WANT_PCE_EMU + WANT_STEREO_SOUND.
#
# CHD support comes via the bundled libchdr + lzma + zstd in deps/.

include(FetchContent)

FetchContent_Declare(libretro_beetle_pce
    GIT_REPOSITORY https://github.com/libretro/beetle-pce-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_beetle_pce)

set(_PCE      ${libretro_beetle_pce_SOURCE_DIR})
set(_PCE_M    ${_PCE}/mednafen)
set(_PCE_E    ${_PCE_M}/pce)
set(_PCE_CD   ${_PCE_M}/cdrom)
set(_PCE_LR   ${_PCE}/libretro-common)
set(_PCE_DP   ${_PCE}/deps)

set(_PCE_CXX
    ${_PCE}/libretro.cpp
    # PCE core
    ${_PCE_E}/huc6280.cpp
    ${_PCE_E}/huc.cpp
    ${_PCE_E}/input.cpp
    ${_PCE_E}/mcgenjin.cpp
    ${_PCE_E}/pce.cpp
    ${_PCE_E}/pcecd.cpp
    ${_PCE_E}/tsushin.cpp
    ${_PCE_E}/vce.cpp
    ${_PCE_E}/input/gamepad.cpp
    ${_PCE_E}/input/mouse.cpp
    ${_PCE_E}/input/tsushinkb.cpp
    # Mednafen support
    ${_PCE_M}/hw_misc/arcade_card/arcade_card.cpp
    ${_PCE_M}/hw_sound/pce_psg/pce_psg.cpp
    ${_PCE_M}/hw_video/huc6270/vdc.cpp
    ${_PCE_M}/settings.cpp
    ${_PCE_M}/general.cpp
    ${_PCE_M}/FileStream.cpp
    ${_PCE_M}/MemoryStream.cpp
    ${_PCE_M}/Stream.cpp
    ${_PCE_M}/state.cpp
    ${_PCE_M}/mempatcher.cpp
    ${_PCE_M}/sound/okiadpcm.cpp
    ${_PCE_M}/sound/OwlResampler.cpp
    # CD-ROM
    ${_PCE_CD}/CDAccess.cpp
    ${_PCE_CD}/CDAccess_Image.cpp
    ${_PCE_CD}/CDAccess_CCD.cpp
    ${_PCE_CD}/CDAccess_CHD.cpp
    ${_PCE_CD}/CDAFReader.cpp
    ${_PCE_CD}/CDAFReader_Vorbis.cpp
    ${_PCE_CD}/cdromif.cpp
    ${_PCE_CD}/CDUtility.cpp
    ${_PCE_CD}/lec.cpp
    ${_PCE_CD}/galois.cpp
    ${_PCE_CD}/recover-raw.cpp
    ${_PCE_CD}/l-ec.cpp
    ${_PCE_CD}/edc_crc32.cpp
    ${_PCE_CD}/scsicd.cpp
)

set(_PCE_C
    ${_PCE_M}/file.c
    ${_PCE_M}/mednafen-endian.c
    ${_PCE_M}/cputest/cputest.c
    ${_PCE_M}/sound/Blip_Buffer.c
    # Tremor (vorbis decoder for CD-DA tracks)
    ${_PCE_M}/tremor/bitwise.c
    ${_PCE_M}/tremor/block.c
    ${_PCE_M}/tremor/codebook.c
    ${_PCE_M}/tremor/floor0.c
    ${_PCE_M}/tremor/floor1.c
    ${_PCE_M}/tremor/framing.c
    ${_PCE_M}/tremor/info.c
    ${_PCE_M}/tremor/mapping0.c
    ${_PCE_M}/tremor/mdct.c
    ${_PCE_M}/tremor/registry.c
    ${_PCE_M}/tremor/res012.c
    ${_PCE_M}/tremor/sharedbook.c
    ${_PCE_M}/tremor/synthesis.c
    ${_PCE_M}/tremor/vorbisfile.c
    ${_PCE_M}/tremor/window.c
    # libchdr + zlib + zstd + lzma (bundled in deps/)
    ${_PCE_DP}/lzma-19.00/src/Alloc.c
    ${_PCE_DP}/lzma-19.00/src/Bra86.c
    ${_PCE_DP}/lzma-19.00/src/BraIA64.c
    ${_PCE_DP}/lzma-19.00/src/CpuArch.c
    ${_PCE_DP}/lzma-19.00/src/Delta.c
    ${_PCE_DP}/lzma-19.00/src/LzFind.c
    ${_PCE_DP}/lzma-19.00/src/Lzma86Dec.c
    ${_PCE_DP}/lzma-19.00/src/LzmaDec.c
    ${_PCE_DP}/lzma-19.00/src/LzmaEnc.c
    ${_PCE_DP}/libchdr/src/libchdr_bitstream.c
    ${_PCE_DP}/libchdr/src/libchdr_cdrom.c
    ${_PCE_DP}/libchdr/src/libchdr_chd.c
    ${_PCE_DP}/libchdr/src/libchdr_flac.c
    ${_PCE_DP}/libchdr/src/libchdr_huffman.c
    ${_PCE_DP}/zstd/lib/common/entropy_common.c
    ${_PCE_DP}/zstd/lib/common/error_private.c
    ${_PCE_DP}/zstd/lib/common/fse_decompress.c
    ${_PCE_DP}/zstd/lib/common/zstd_common.c
    ${_PCE_DP}/zstd/lib/common/xxhash.c
    ${_PCE_DP}/zstd/lib/decompress/huf_decompress.c
    ${_PCE_DP}/zstd/lib/decompress/zstd_ddict.c
    ${_PCE_DP}/zstd/lib/decompress/zstd_decompress.c
    ${_PCE_DP}/zstd/lib/decompress/zstd_decompress_block.c
    ${_PCE_DP}/zlib-1.2.11/adler32.c
    ${_PCE_DP}/zlib-1.2.11/crc32.c
    ${_PCE_DP}/zlib-1.2.11/inffast.c
    ${_PCE_DP}/zlib-1.2.11/inflate.c
    ${_PCE_DP}/zlib-1.2.11/inftrees.c
    ${_PCE_DP}/zlib-1.2.11/zutil.c
    # libretro-common subset (upstream gates these on STATIC_LINKING != 1
    # — but our player binary doesn't supply them either, so include
    # them unconditionally).
    ${_PCE_LR}/streams/file_stream.c
    ${_PCE_LR}/streams/file_stream_transforms.c
    ${_PCE_LR}/file/file_path.c
    ${_PCE_LR}/file/retro_dirent.c
    ${_PCE_LR}/lists/string_list.c
    ${_PCE_LR}/lists/dir_list.c
    ${_PCE_LR}/compat/compat_strl.c
    ${_PCE_LR}/compat/compat_snprintf.c
    ${_PCE_LR}/compat/compat_posix_string.c
    ${_PCE_LR}/compat/compat_strcasestr.c
    ${_PCE_LR}/compat/fopen_utf8.c
    ${_PCE_LR}/encodings/encoding_utf.c
    ${_PCE_LR}/encodings/encoding_crc32.c
    ${_PCE_LR}/vfs/vfs_implementation.c
    ${_PCE_LR}/memmap/memalign.c
    ${_PCE_LR}/string/stdstring.c
    ${_PCE_LR}/time/rtime.c
)

add_library(core_beetle_pce STATIC ${_PCE_CXX} ${_PCE_C})

target_include_directories(core_beetle_pce PUBLIC
    ${_PCE}
    ${_PCE_M}
    ${_PCE_M}/include
    ${_PCE_M}/intl
    ${_PCE_M}/hw_sound
    ${_PCE_M}/hw_cpu
    ${_PCE_M}/hw_misc
    ${_PCE_LR}/include
    ${_PCE_DP}/lzma-19.00/include
    ${_PCE_DP}/libchdr/include
    ${_PCE_DP}/zstd/lib
    ${_PCE_DP}/zlib-1.2.11
)

target_compile_definitions(core_beetle_pce PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    LSB_FIRST=1
    HAVE_STDINT_H=1
    INLINE=inline
    FRONTEND_SUPPORTS_RGB565=1
    NEED_CD=1
    NEED_BPP=16
    WANT_16BPP=1
    NEED_TREMOR=1
    HAVE_CHD=1
    _7ZIP_ST=1
    ZSTD_DISABLE_ASM=1
    WANT_PCE_EMU=1
    WANT_STEREO_SOUND=1
    SIZEOF_DOUBLE=8
    MEDNAFEN_VERSION=\"foyer-0.3\"
    MEDNAFEN_VERSION_NUMERIC=0
    STATIC_LINKING=1
)

target_compile_options(core_beetle_pce PRIVATE
    -w
    -fno-strict-aliasing
    -U__linux__
    -U__linux
)

set_target_properties(core_beetle_pce PROPERTIES
    C_STANDARD              99
    C_STANDARD_REQUIRED     ON
    CXX_STANDARD            11
    CXX_STANDARD_REQUIRED   ON
    POSITION_INDEPENDENT_CODE ON)
