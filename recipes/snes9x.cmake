# cores/snes9x.cmake — libretro snes9x (modern SNES core).

include(FetchContent)

FetchContent_Declare(libretro_snes9x
    GIT_REPOSITORY https://github.com/libretro/snes9x.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_snes9x)

set(_S9X      ${libretro_snes9x_SOURCE_DIR})
set(_S9X_LR   ${_S9X}/libretro)

set(_S9X_COMM_C
    ${_S9X_LR}/libretro-common/compat/compat_posix_string.c
    ${_S9X_LR}/libretro-common/compat/compat_strcasestr.c
    ${_S9X_LR}/libretro-common/compat/compat_snprintf.c
    ${_S9X_LR}/libretro-common/compat/compat_strl.c
    ${_S9X_LR}/libretro-common/compat/fopen_utf8.c
    ${_S9X_LR}/libretro-common/encodings/encoding_utf.c
    ${_S9X_LR}/libretro-common/encodings/encoding_deflate.c
    ${_S9X_LR}/libretro-common/file/file_path.c
    ${_S9X_LR}/libretro-common/file/file_path_io.c
    ${_S9X_LR}/libretro-common/file/retro_dirent.c
    ${_S9X_LR}/libretro-common/streams/file_stream.c
    ${_S9X_LR}/libretro-common/streams/file_stream_transforms.c
    ${_S9X_LR}/libretro-common/string/stdstring.c
    ${_S9X_LR}/libretro-common/time/rtime.c
    ${_S9X_LR}/libretro-common/vfs/vfs_implementation.c
    ${_S9X_LR}/libretro-common/vfs/vfs_hybrid.c
)

set(_S9X_CXX
    ${_S9X}/apu/apu.cpp
    ${_S9X}/apu/bapu/dsp/sdsp.cpp
    ${_S9X}/apu/bapu/smp/smp.cpp
    ${_S9X}/apu/bapu/smp/smp_state.cpp
    ${_S9X}/bsx.c
    ${_S9X}/bsflash.c
    ${_S9X}/zipfile.c
    ${_S9X}/c4.cpp
    ${_S9X}/c4emu.cpp
    ${_S9X}/cheats.cpp
    ${_S9X}/cheats2.cpp
    ${_S9X}/clip.cpp
    ${_S9X}/conffile.cpp
    ${_S9X}/controls.cpp
    ${_S9X}/cpu.cpp
    ${_S9X}/cpuexec.cpp
    ${_S9X}/cpuops.cpp
    ${_S9X}/crosshairs.cpp
    ${_S9X}/dma.cpp
    ${_S9X}/dsp.cpp
    ${_S9X}/dsp1.cpp
    ${_S9X}/dsp2.cpp
    ${_S9X}/dsp3.cpp
    ${_S9X}/dsp4.cpp
    ${_S9X}/fxinst.cpp
    ${_S9X}/fxemu.cpp
    ${_S9X}/gfx.cpp
    ${_S9X}/globals.cpp
    ${_S9X}/loadzip.cpp
    ${_S9X}/memmap.cpp
    ${_S9X}/obc1.cpp
    ${_S9X}/msu1.cpp
    ${_S9X}/ppu.cpp
    ${_S9X}/stream.cpp
    ${_S9X}/sa1.cpp
    ${_S9X}/sa1cpu.cpp
    ${_S9X}/screenshot.cpp
    ${_S9X}/sdd1.cpp
    ${_S9X}/sdd1emu.cpp
    ${_S9X}/seta.cpp
    ${_S9X}/seta010.cpp
    ${_S9X}/seta011.cpp
    ${_S9X}/seta018.cpp
    ${_S9X}/snapshot.cpp
    ${_S9X}/snes9x.cpp
    ${_S9X}/spc7110.cpp
    ${_S9X}/srtc.cpp
    ${_S9X}/tile.cpp
    ${_S9X}/tileimpl-n1x1.cpp
    ${_S9X}/tileimpl-n2x1.cpp
    ${_S9X}/tileimpl-h2x1.cpp
    ${_S9X}/sha256.cpp
    ${_S9X}/bml.cpp
    ${_S9X}/movie.cpp
    ${_S9X}/fscompat.cpp
    ${_S9X}/sa1hw.c
    ${_S9X_LR}/libretro.cpp
)
set(_S9X_C
    ${_S9X}/filter/snes_ntsc.c
    ${_S9X}/tile.c
)

# Filter to existing files so upstream renames don't hard-fail configure
set(_S9X_ALL_SRC ${_S9X_CXX} ${_S9X_C} ${_S9X_COMM_C})
foyer_filter_existing_sources(_S9X_FILTERED ${_S9X_ALL_SRC})
add_library(core_snes9x STATIC ${_S9X_FILTERED})
target_include_directories(core_snes9x PUBLIC
    ${_S9X}
    ${_S9X}/apu
    ${_S9X}/apu/bapu
    ${_S9X_LR}
    ${_S9X_LR}/libretro-common/include
)
target_compile_definitions(core_snes9x PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    HAVE_STDINT_H=1
    RIGHTSHIFT_IS_SAR=1
    ALLOW_CPU_OVERCLOCK=1
)
target_compile_options(core_snes9x PRIVATE -w)
set_target_properties(core_snes9x PROPERTIES
    C_STANDARD                99
    C_STANDARD_REQUIRED       ON
    CXX_STANDARD              17
    CXX_STANDARD_REQUIRED     ON
    POSITION_INDEPENDENT_CODE ON)
