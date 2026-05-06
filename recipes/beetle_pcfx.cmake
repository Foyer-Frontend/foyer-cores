# cores/beetle_pcfx.cmake — libretro Beetle PC-FX (Mednafen).
# HAVE_GRIFFIN=0. Mirrors upstream Makefile.common's libnx target.
# Uses V810 CPU, has CD + CHD + tremor.

include(FetchContent)

FetchContent_Declare(libretro_beetle_pcfx
    GIT_REPOSITORY https://github.com/libretro/beetle-pcfx-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_beetle_pcfx)

set(_FX    ${libretro_beetle_pcfx_SOURCE_DIR})
set(_FX_M  ${_FX}/mednafen)
set(_FX_E  ${_FX_M}/pcfx)
set(_FX_CD ${_FX_M}/cdrom)
set(_FX_LR ${_FX}/libretro-common)
set(_FX_DP ${_FX}/deps)

set(_FX_CXX
    ${_FX}/libretro.cpp
    ${_FX_E}/king.cpp
    ${_FX_E}/soundbox.cpp
    ${_FX_E}/interrupt.cpp
    ${_FX_E}/huc6273.cpp
    ${_FX_E}/input.cpp
    ${_FX_E}/timer.cpp
    ${_FX_E}/rainbow.cpp
    ${_FX_E}/input/gamepad.cpp
    ${_FX_E}/input/mouse.cpp
    ${_FX_M}/sound/OwlResampler.cpp
    ${_FX_M}/hw_cpu/v810/v810_cpu.cpp
    ${_FX_M}/hw_cpu/v810/v810_fp_ops.cpp
    ${_FX_M}/hw_sound/pce_psg/pce_psg.cpp
    ${_FX_M}/hw_video/huc6270/vdc_video.cpp
    ${_FX_M}/general.cpp
    ${_FX_M}/FileStream.cpp
    ${_FX_M}/MemoryStream.cpp
    ${_FX_M}/Stream.cpp
    ${_FX_M}/mempatcher.cpp
    ${_FX_CD}/CDAccess.cpp
    ${_FX_CD}/CDAccess_Image.cpp
    ${_FX_CD}/CDAccess_CCD.cpp
    ${_FX_CD}/CDAccess_CHD.cpp
    ${_FX_CD}/CDAFReader.cpp
    ${_FX_CD}/CDAFReader_Vorbis.cpp
    ${_FX_CD}/cdromif.cpp
    ${_FX_CD}/CDUtility.cpp
    ${_FX_CD}/lec.cpp
    ${_FX_CD}/galois.cpp
    ${_FX_CD}/recover-raw.cpp
    ${_FX_CD}/l-ec.cpp
    ${_FX_CD}/scsicd.cpp
    ${_FX_CD}/edc_crc32.cpp
)

set(_FX_C
    ${_FX_E}/jrevdct.c
    ${_FX_M}/file.c
    ${_FX_M}/settings.c
    ${_FX_M}/mednafen-endian.c
    ${_FX_M}/state.c
    ${_FX_M}/mednafen_md5.c
    ${_FX_LR}/rthreads/rthreads.c
    # Tremor
    ${_FX_M}/tremor/bitwise.c
    ${_FX_M}/tremor/block.c
    ${_FX_M}/tremor/codebook.c
    ${_FX_M}/tremor/floor0.c
    ${_FX_M}/tremor/floor1.c
    ${_FX_M}/tremor/framing.c
    ${_FX_M}/tremor/info.c
    ${_FX_M}/tremor/mapping0.c
    ${_FX_M}/tremor/mdct.c
    ${_FX_M}/tremor/registry.c
    ${_FX_M}/tremor/res012.c
    ${_FX_M}/tremor/sharedbook.c
    ${_FX_M}/tremor/synthesis.c
    ${_FX_M}/tremor/vorbisfile.c
    ${_FX_M}/tremor/window.c
    # libchdr + zlib + lzma
    ${_FX_DP}/lzma-19.00/src/Alloc.c
    ${_FX_DP}/lzma-19.00/src/Bra86.c
    ${_FX_DP}/lzma-19.00/src/BraIA64.c
    ${_FX_DP}/lzma-19.00/src/CpuArch.c
    ${_FX_DP}/lzma-19.00/src/Delta.c
    ${_FX_DP}/lzma-19.00/src/LzFind.c
    ${_FX_DP}/lzma-19.00/src/Lzma86Dec.c
    ${_FX_DP}/lzma-19.00/src/LzmaDec.c
    ${_FX_DP}/lzma-19.00/src/LzmaEnc.c
    ${_FX_DP}/libchdr/src/libchdr_bitstream.c
    ${_FX_DP}/libchdr/src/libchdr_cdrom.c
    ${_FX_DP}/libchdr/src/libchdr_chd.c
    ${_FX_DP}/libchdr/src/libchdr_flac.c
    ${_FX_DP}/libchdr/src/libchdr_huffman.c
    ${_FX_DP}/zlib-1.2.11/adler32.c
    ${_FX_DP}/zlib-1.2.11/crc32.c
    ${_FX_DP}/zlib-1.2.11/inffast.c
    ${_FX_DP}/zlib-1.2.11/inflate.c
    ${_FX_DP}/zlib-1.2.11/inftrees.c
    # libretro-common
    ${_FX_LR}/streams/file_stream.c
    ${_FX_LR}/streams/file_stream_transforms.c
    ${_FX_LR}/file/file_path.c
    ${_FX_LR}/file/retro_dirent.c
    ${_FX_LR}/lists/string_list.c
    ${_FX_LR}/lists/dir_list.c
    ${_FX_LR}/compat/compat_strl.c
    ${_FX_LR}/compat/compat_snprintf.c
    ${_FX_LR}/compat/compat_posix_string.c
    ${_FX_LR}/compat/compat_strcasestr.c
    ${_FX_LR}/compat/fopen_utf8.c
    ${_FX_LR}/encodings/encoding_utf.c
    ${_FX_LR}/encodings/encoding_crc32.c
    ${_FX_LR}/vfs/vfs_implementation.c
    ${_FX_LR}/memmap/memalign.c
    ${_FX_LR}/string/stdstring.c
    ${_FX_LR}/time/rtime.c
)

add_library(core_beetle_pcfx STATIC ${_FX_CXX} ${_FX_C})

target_include_directories(core_beetle_pcfx PUBLIC
    ${_FX}
    ${_FX_M}
    ${_FX_M}/include
    ${_FX_M}/intl
    ${_FX_M}/hw_sound
    ${_FX_M}/hw_cpu
    ${_FX_M}/hw_misc
    ${_FX_LR}/include
    ${_FX_DP}/lzma-19.00/include
    ${_FX_DP}/libchdr/include
    ${_FX_DP}/zlib-1.2.11
)

target_compile_definitions(core_beetle_pcfx PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    LSB_FIRST=1
    HAVE_STDINT_H=1
    HAVE_THREADS=1
    INLINE=inline
    FRONTEND_SUPPORTS_RGB565=1
    NEED_CD=1
    NEED_BPP=32
    WANT_32BPP=1
    NEED_TREMOR=1
    HAVE_CHD=1
    _7ZIP_ST=1
    WANT_STEREO_SOUND=1
    WANT_PCFX_EMU=1
    SIZEOF_DOUBLE=8
    MEDNAFEN_VERSION=\"foyer-0.3\"
    MEDNAFEN_VERSION_NUMERIC=0
    STATIC_LINKING=1
)

target_compile_options(core_beetle_pcfx PRIVATE -w -fno-strict-aliasing -U__linux__ -U__linux)
set_target_properties(core_beetle_pcfx PROPERTIES
    C_STANDARD 99 C_STANDARD_REQUIRED ON
    CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
