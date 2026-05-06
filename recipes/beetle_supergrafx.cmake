# cores/beetle_supergrafx.cmake — libretro Beetle SuperGrafx
# (Mednafen PC Engine SuperGrafx).
#
# HAVE_GRIFFIN=0. Mirrors upstream Makefile.common's libnx target.
# Source layout reuses pce_fast/ folder. Note: Blip_Buffer is the
# .cpp variant here (not .c like the other Mednafen cores).

include(FetchContent)

FetchContent_Declare(libretro_beetle_supergrafx
    GIT_REPOSITORY https://github.com/libretro/beetle-supergrafx-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_beetle_supergrafx)

set(_SG    ${libretro_beetle_supergrafx_SOURCE_DIR})
set(_SG_M  ${_SG}/mednafen)
set(_SG_E  ${_SG_M}/pce_fast)
set(_SG_CD ${_SG_M}/cdrom)
set(_SG_LR ${_SG}/libretro-common)
set(_SG_DP ${_SG}/deps)

set(_SG_CXX
    ${_SG}/libretro.cpp
    ${_SG_E}/pce.cpp
    ${_SG_E}/huc.cpp
    ${_SG_E}/huc6280.cpp
    ${_SG_E}/input.cpp
    ${_SG_E}/pcecd.cpp
    ${_SG_E}/pcecd_drive.cpp
    ${_SG_E}/psg.cpp
    ${_SG_E}/vdc.cpp
    ${_SG_M}/hw_misc/arcade_card/arcade_card.cpp
    ${_SG_M}/sound/Blip_Buffer.cpp
    ${_SG_M}/error.cpp
    ${_SG_M}/settings.cpp
    ${_SG_M}/general.cpp
    ${_SG_M}/FileWrapper.cpp
    ${_SG_M}/FileStream.cpp
    ${_SG_M}/MemoryStream.cpp
    ${_SG_M}/Stream.cpp
    ${_SG_M}/state.cpp
    ${_SG_M}/mempatcher.cpp
    ${_SG_M}/okiadpcm.cpp
    ${_SG_M}/endian.cpp
    ${_SG_M}/video/surface.cpp
    ${_SG_CD}/CDAccess.cpp
    ${_SG_CD}/CDAccess_Image.cpp
    ${_SG_CD}/CDAccess_CCD.cpp
    ${_SG_CD}/CDAccess_CHD.cpp
    ${_SG_CD}/audioreader.cpp
    ${_SG_CD}/cdromif.cpp
)

set(_SG_C
    ${_SG_M}/file.c
    ${_SG_CD}/CDUtility.c
    ${_SG_CD}/lec.c
    ${_SG_CD}/galois.c
    ${_SG_CD}/recover-raw.c
    ${_SG_CD}/l-ec.c
    ${_SG_CD}/edc_crc32.c
    # Tremor
    ${_SG_M}/tremor/bitwise.c
    ${_SG_M}/tremor/block.c
    ${_SG_M}/tremor/codebook.c
    ${_SG_M}/tremor/floor0.c
    ${_SG_M}/tremor/floor1.c
    ${_SG_M}/tremor/framing.c
    ${_SG_M}/tremor/info.c
    ${_SG_M}/tremor/mapping0.c
    ${_SG_M}/tremor/mdct.c
    ${_SG_M}/tremor/registry.c
    ${_SG_M}/tremor/res012.c
    ${_SG_M}/tremor/sharedbook.c
    ${_SG_M}/tremor/synthesis.c
    ${_SG_M}/tremor/vorbisfile.c
    ${_SG_M}/tremor/window.c
    # libchdr + zlib + lzma (no zstd in supergrafx deps)
    ${_SG_DP}/lzma-19.00/src/Alloc.c
    ${_SG_DP}/lzma-19.00/src/Bra86.c
    ${_SG_DP}/lzma-19.00/src/BraIA64.c
    ${_SG_DP}/lzma-19.00/src/CpuArch.c
    ${_SG_DP}/lzma-19.00/src/Delta.c
    ${_SG_DP}/lzma-19.00/src/LzFind.c
    ${_SG_DP}/lzma-19.00/src/Lzma86Dec.c
    ${_SG_DP}/lzma-19.00/src/LzmaDec.c
    ${_SG_DP}/lzma-19.00/src/LzmaEnc.c
    ${_SG_DP}/libchdr/src/libchdr_bitstream.c
    ${_SG_DP}/libchdr/src/libchdr_cdrom.c
    ${_SG_DP}/libchdr/src/libchdr_chd.c
    ${_SG_DP}/libchdr/src/libchdr_flac.c
    ${_SG_DP}/libchdr/src/libchdr_huffman.c
    ${_SG_DP}/zlib-1.2.11/adler32.c
    ${_SG_DP}/zlib-1.2.11/crc32.c
    ${_SG_DP}/zlib-1.2.11/inffast.c
    ${_SG_DP}/zlib-1.2.11/inflate.c
    ${_SG_DP}/zlib-1.2.11/inftrees.c
    ${_SG_DP}/zlib-1.2.11/zutil.c
    # libretro-common
    ${_SG_LR}/streams/file_stream.c
    ${_SG_LR}/streams/file_stream_transforms.c
    ${_SG_LR}/file/file_path.c
    ${_SG_LR}/file/retro_dirent.c
    ${_SG_LR}/lists/string_list.c
    ${_SG_LR}/lists/dir_list.c
    ${_SG_LR}/compat/compat_strl.c
    ${_SG_LR}/compat/compat_snprintf.c
    ${_SG_LR}/compat/compat_posix_string.c
    ${_SG_LR}/compat/compat_strcasestr.c
    ${_SG_LR}/compat/fopen_utf8.c
    ${_SG_LR}/encodings/encoding_utf.c
    ${_SG_LR}/vfs/vfs_implementation.c
    ${_SG_LR}/memmap/memalign.c
    ${_SG_LR}/string/stdstring.c
    ${_SG_LR}/time/rtime.c
)

add_library(core_beetle_supergrafx STATIC ${_SG_CXX} ${_SG_C})

target_include_directories(core_beetle_supergrafx PUBLIC
    ${_SG}
    ${_SG_M}
    ${_SG_M}/include
    ${_SG_M}/intl
    ${_SG_M}/hw_sound
    ${_SG_M}/hw_cpu
    ${_SG_M}/hw_misc
    ${_SG_LR}/include
    ${_SG_DP}/lzma-19.00/include
    ${_SG_DP}/libchdr/include
    ${_SG_DP}/zlib-1.2.11
)

target_compile_definitions(core_beetle_supergrafx PRIVATE
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
    WANT_STEREO_SOUND=1
    SIZEOF_DOUBLE=8
    MEDNAFEN_VERSION=\"foyer-0.3\"
    MEDNAFEN_VERSION_NUMERIC=0
    STATIC_LINKING=1
)

target_compile_options(core_beetle_supergrafx PRIVATE -w -fno-strict-aliasing -U__linux__ -U__linux)
set_target_properties(core_beetle_supergrafx PROPERTIES
    C_STANDARD 99 C_STANDARD_REQUIRED ON
    CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
