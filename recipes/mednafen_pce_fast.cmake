# cores/mednafen_pce_fast.cmake — libretro Beetle PCE Fast
# (older lighter PC Engine fork, companion to beetle_pce).
#
# HAVE_GRIFFIN=0. Mirrors upstream Makefile.common's libnx target.
# CORE_DEFINE = -DWANT_PCE_FAST_EMU -DWANT_STEREO_SOUND.

include(FetchContent)

FetchContent_Declare(libretro_mednafen_pce_fast
    GIT_REPOSITORY https://github.com/libretro/mednafen-pce-fast-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_mednafen_pce_fast)

set(_PF    ${libretro_mednafen_pce_fast_SOURCE_DIR})
set(_PF_M  ${_PF}/mednafen)
set(_PF_E  ${_PF_M}/pce_fast)
set(_PF_CD ${_PF_M}/cdrom)
set(_PF_LR ${_PF}/libretro-common)
set(_PF_DP ${_PF}/deps)

set(_PF_CXX
    ${_PF}/libretro.cpp
    ${_PF_E}/pcecd.cpp
    ${_PF_E}/pcecd_drive.cpp
    ${_PF_E}/psg.cpp
    ${_PF_M}/hw_misc/arcade_card/arcade_card.cpp
    ${_PF_M}/general.cpp
    ${_PF_M}/FileStream.cpp
    ${_PF_M}/MemoryStream.cpp
    ${_PF_M}/Stream.cpp
    ${_PF_M}/mempatcher.cpp
    ${_PF_M}/okiadpcm.cpp
    ${_PF_CD}/CDAccess.cpp
    ${_PF_CD}/CDAccess_Image.cpp
    ${_PF_CD}/CDAccess_CCD.cpp
    ${_PF_CD}/CDAccess_CHD.cpp
    ${_PF_CD}/CDAFReader.cpp
    ${_PF_CD}/CDAFReader_Vorbis.cpp
    ${_PF_CD}/cdromif.cpp
    ${_PF_CD}/CDUtility.cpp
    ${_PF_CD}/lec.cpp
    ${_PF_CD}/galois.cpp
    ${_PF_CD}/recover-raw.cpp
    ${_PF_CD}/l-ec.cpp
    ${_PF_CD}/edc_crc32.cpp
)

set(_PF_C
    ${_PF_E}/huc6280.c
    ${_PF_E}/input.c
    ${_PF_E}/vdc.c
    ${_PF_M}/sound/Blip_Buffer.c
    ${_PF_M}/file.c
    ${_PF_M}/settings.c
    ${_PF_M}/state.c
    ${_PF_M}/mednafen-endian.c
    # Tremor
    ${_PF_M}/tremor/bitwise.c
    ${_PF_M}/tremor/block.c
    ${_PF_M}/tremor/codebook.c
    ${_PF_M}/tremor/floor0.c
    ${_PF_M}/tremor/floor1.c
    ${_PF_M}/tremor/framing.c
    ${_PF_M}/tremor/info.c
    ${_PF_M}/tremor/mapping0.c
    ${_PF_M}/tremor/mdct.c
    ${_PF_M}/tremor/registry.c
    ${_PF_M}/tremor/res012.c
    ${_PF_M}/tremor/sharedbook.c
    ${_PF_M}/tremor/synthesis.c
    ${_PF_M}/tremor/vorbisfile.c
    ${_PF_M}/tremor/window.c
    # libchdr + zlib + zstd + lzma
    ${_PF_DP}/lzma-19.00/src/Alloc.c
    ${_PF_DP}/lzma-19.00/src/Bra86.c
    ${_PF_DP}/lzma-19.00/src/BraIA64.c
    ${_PF_DP}/lzma-19.00/src/CpuArch.c
    ${_PF_DP}/lzma-19.00/src/Delta.c
    ${_PF_DP}/lzma-19.00/src/LzFind.c
    ${_PF_DP}/lzma-19.00/src/Lzma86Dec.c
    ${_PF_DP}/lzma-19.00/src/LzmaDec.c
    ${_PF_DP}/lzma-19.00/src/LzmaEnc.c
    ${_PF_DP}/libchdr/src/libchdr_bitstream.c
    ${_PF_DP}/libchdr/src/libchdr_cdrom.c
    ${_PF_DP}/libchdr/src/libchdr_chd.c
    ${_PF_DP}/libchdr/src/libchdr_flac.c
    ${_PF_DP}/libchdr/src/libchdr_huffman.c
    ${_PF_DP}/zstd/lib/common/entropy_common.c
    ${_PF_DP}/zstd/lib/common/error_private.c
    ${_PF_DP}/zstd/lib/common/fse_decompress.c
    ${_PF_DP}/zstd/lib/common/zstd_common.c
    ${_PF_DP}/zstd/lib/common/xxhash.c
    ${_PF_DP}/zstd/lib/decompress/huf_decompress.c
    ${_PF_DP}/zstd/lib/decompress/zstd_ddict.c
    ${_PF_DP}/zstd/lib/decompress/zstd_decompress.c
    ${_PF_DP}/zstd/lib/decompress/zstd_decompress_block.c
    ${_PF_DP}/zlib-1.2.11/adler32.c
    ${_PF_DP}/zlib-1.2.11/crc32.c
    ${_PF_DP}/zlib-1.2.11/inffast.c
    ${_PF_DP}/zlib-1.2.11/inflate.c
    ${_PF_DP}/zlib-1.2.11/inftrees.c
    ${_PF_DP}/zlib-1.2.11/zutil.c
    # libretro-common
    ${_PF_LR}/streams/file_stream.c
    ${_PF_LR}/streams/file_stream_transforms.c
    ${_PF_LR}/file/file_path.c
    ${_PF_LR}/file/retro_dirent.c
    ${_PF_LR}/lists/string_list.c
    ${_PF_LR}/lists/dir_list.c
    ${_PF_LR}/compat/compat_strl.c
    ${_PF_LR}/compat/compat_snprintf.c
    ${_PF_LR}/compat/compat_posix_string.c
    ${_PF_LR}/compat/compat_strcasestr.c
    ${_PF_LR}/compat/fopen_utf8.c
    ${_PF_LR}/encodings/encoding_utf.c
    ${_PF_LR}/encodings/encoding_crc32.c
    ${_PF_LR}/vfs/vfs_implementation.c
    ${_PF_LR}/memmap/memalign.c
    ${_PF_LR}/string/stdstring.c
    ${_PF_LR}/time/rtime.c
)

add_library(core_mednafen_pce_fast STATIC ${_PF_CXX} ${_PF_C})

target_include_directories(core_mednafen_pce_fast PUBLIC
    ${_PF}
    ${_PF_M}
    ${_PF_M}/include
    ${_PF_M}/hw_sound
    ${_PF_M}/hw_cpu
    ${_PF_M}/hw_misc
    ${_PF_LR}/include
    ${_PF_DP}/lzma-19.00/include
    ${_PF_DP}/libchdr/include
    ${_PF_DP}/zstd/lib
    ${_PF_DP}/zlib-1.2.11
)

target_compile_definitions(core_mednafen_pce_fast PRIVATE
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
    NEED_BPP=32
    WANT_32BPP=1
    NEED_TREMOR=1
    HAVE_CHD=1
    _7ZIP_ST=1
    ZSTD_DISABLE_ASM=1
    WANT_PCE_FAST_EMU=1
    WANT_STEREO_SOUND=1
    SIZEOF_DOUBLE=8
    MEDNAFEN_VERSION=\"foyer-0.3\"
    MEDNAFEN_VERSION_NUMERIC=0
    STATIC_LINKING=1
)

target_compile_options(core_mednafen_pce_fast PRIVATE -w -fno-strict-aliasing -U__linux__ -U__linux)
set_target_properties(core_mednafen_pce_fast PROPERTIES
    C_STANDARD 99 C_STANDARD_REQUIRED ON
    CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
