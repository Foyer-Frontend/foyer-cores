# recipes/mednafen_psx_hw.cmake — libretro Beetle PSX HW
# (Mednafen PSX with HW renderer + 16:9 widescreen via OpenGL ES 3).
#
# Why ship this on top of pcsx_rearmed + swanstation: mednafen_psx_hw
# is the only PSX core that does true 3D widescreen rendering — it
# re-renders the scene at 16:9 FOV instead of stretching the 4:3
# framebuffer. swanstation has a basic widescreen hack but lacks the
# geometry-aware approach.
#
# We use HAVE_GRIFFIN=0 (one TU per file). Upstream's griffin unity
# TUs are out of sync — they reference 5 files that have been
# renamed or removed (settings.cpp -> .c, state.cpp -> .c,
# mednafen-endian.c -> .cpp, file.c removed, SimpleFIFO.cpp removed).
# The non-griffin path is what upstream itself maintains.
#
# Renderer: GLES3 via foyer's HW render callback
# (shared/libretro/video_hw.cpp). The core asks for a GLES3 context
# via SET_HW_RENDER and renders into the FBO that HwContext provides.
# CHD support is OFF (would need libchdr + lzma); .pbp/.cue/.bin/.iso
# work fine without it.

include(FetchContent)

FetchContent_Declare(libretro_psx_hw
    GIT_REPOSITORY https://github.com/libretro/beetle-psx-libretro.git
    # Pinned. Upstream HEAD on 2026-05-05 converted Stream /
    # FileStream / MemoryStream from C++ to C (file rename .cpp ->
    # .c plus reorganisation of the streams/ subdir) — our
    # explicit SOURCES_CXX block below still references the old
    # .cpp paths. Bump this SHA or re-enumerate the source list to
    # follow upstream when ready.
    GIT_TAG        ab72423afd429c1e96ca56fbd39094a71270842b
    GIT_SHALLOW    FALSE)
FetchContent_MakeAvailable(libretro_psx_hw)

set(_PSX     ${libretro_psx_hw_SOURCE_DIR})
set(_PSX_M   ${_PSX}/mednafen)
set(_PSX_E   ${_PSX_M}/psx)
set(_PSX_LR  ${_PSX}/libretro-common)
set(_PSX_DP  ${_PSX}/deps)

# Mirror Makefile.common's HAVE_GRIFFIN=0 source list. Keep this in
# sync with upstream when bumping FetchContent.
set(_PSX_CXX
    # PSX core
    ${_PSX_E}/irq.cpp
    ${_PSX_E}/timer.cpp
    ${_PSX_E}/dma.cpp
    ${_PSX_E}/frontio.cpp
    ${_PSX_E}/sio.cpp
    ${_PSX_E}/cpu.cpp
    ${_PSX_E}/gte.cpp
    ${_PSX_E}/cdc.cpp
    ${_PSX_E}/spu.cpp
    ${_PSX_E}/gpu.cpp
    ${_PSX_E}/gpu_polygon_sub.cpp
    ${_PSX_E}/mdec.cpp
    ${_PSX_E}/dis.cpp
    # PSX peripherals
    ${_PSX_E}/input/gamepad.cpp
    ${_PSX_E}/input/dualanalog.cpp
    ${_PSX_E}/input/dualshock.cpp
    ${_PSX_E}/input/justifier.cpp
    ${_PSX_E}/input/guncon.cpp
    ${_PSX_E}/input/negcon.cpp
    ${_PSX_E}/input/negconrumble.cpp
    ${_PSX_E}/input/memcard.cpp
    ${_PSX_E}/input/multitap.cpp
    ${_PSX_E}/input/mouse.cpp
    # Mednafen support
    ${_PSX_M}/error.cpp
    ${_PSX_M}/general.cpp
    ${_PSX_M}/FileStream.cpp
    ${_PSX_M}/MemoryStream.cpp
    ${_PSX_M}/Stream.cpp
    ${_PSX_M}/mempatcher.cpp
    ${_PSX_M}/mednafen-endian.cpp
    ${_PSX_M}/video/Deinterlacer.cpp
    ${_PSX_M}/video/surface.cpp
    # CD-ROM (sans CHD; see header comment)
    ${_PSX_M}/cdrom/CDAccess.cpp
    ${_PSX_M}/cdrom/CDAccess_Image.cpp
    ${_PSX_M}/cdrom/CDAccess_CCD.cpp
    ${_PSX_M}/cdrom/CDAccess_PBP.cpp
    ${_PSX_M}/cdrom/audioreader.cpp
    ${_PSX_M}/cdrom/misc.cpp
    ${_PSX_M}/cdrom/cdromif.cpp
    # Libretro frontend bridge
    ${_PSX}/libretro.cpp
    ${_PSX}/input.cpp
    ${_PSX}/rsx/rsx_intf.cpp
    ${_PSX}/rsx/rsx_lib_gl.cpp
)

set(_PSX_C
    # PSX core C bits (scrc32.c was removed upstream — header-only now).
    ${_PSX}/libretro_cbs.c
    ${_PSX}/beetle_psx_globals.c
    # Mednafen settings + state machine (renamed from .cpp upstream)
    ${_PSX_M}/settings.c
    ${_PSX_M}/state.c
    # CD-ROM C bits
    ${_PSX_M}/cdrom/CDUtility.c
    ${_PSX_M}/cdrom/galois.c
    ${_PSX_M}/cdrom/l-ec.c
    ${_PSX_M}/cdrom/lec.c
    ${_PSX_M}/cdrom/recover-raw.c
    ${_PSX_M}/cdrom/edc_crc32.c
    # Tremor (vorbis decoder for CD-DA tracks)
    ${_PSX_M}/tremor/bitwise.c
    ${_PSX_M}/tremor/block.c
    ${_PSX_M}/tremor/codebook.c
    ${_PSX_M}/tremor/floor0.c
    ${_PSX_M}/tremor/floor1.c
    ${_PSX_M}/tremor/framing.c
    ${_PSX_M}/tremor/info.c
    ${_PSX_M}/tremor/mapping0.c
    ${_PSX_M}/tremor/mdct.c
    ${_PSX_M}/tremor/registry.c
    ${_PSX_M}/tremor/res012.c
    ${_PSX_M}/tremor/sharedbook.c
    ${_PSX_M}/tremor/synthesis.c
    ${_PSX_M}/tremor/vorbisfile.c
    ${_PSX_M}/tremor/window.c
    # PGXP (precision geometry transform pipeline)
    ${_PSX}/pgxp/pgxp_cpu.c
    ${_PSX}/pgxp/pgxp_main.c
    ${_PSX}/pgxp/pgxp_mem.c
    ${_PSX}/pgxp/pgxp_gte.c
    ${_PSX}/pgxp/pgxp_gpu.c
    ${_PSX}/pgxp/pgxp_value.c
    ${_PSX}/pgxp/pgxp_debug.c
    # Libkirk (PSP/PBP cipher used by .pbp loader)
    ${_PSX_DP}/libkirk/aes.c
    ${_PSX_DP}/libkirk/amctrl.c
    ${_PSX_DP}/libkirk/bn.c
    ${_PSX_DP}/libkirk/des.c
    ${_PSX_DP}/libkirk/ec.c
    ${_PSX_DP}/libkirk/kirk_engine.c
    ${_PSX_DP}/libkirk/sha1.c
    # Shared glsm shim stubs (desktop-GL extension stand-ins).
    # Same file used by parallel_n64.cmake.
    ${CMAKE_CURRENT_LIST_DIR}/libretro_glsm_stubs.c
    # libretro-common (skip glsym_es3.c — our shim bypasses rglgen
    # and resolves directly against Switch Mesa's GLES3 symbols).
    ${_PSX_LR}/glsm/glsm.c
    ${_PSX_LR}/streams/file_stream.c
    ${_PSX_LR}/rthreads/rthreads.c
    ${_PSX_LR}/string/stdstring.c
    ${_PSX_LR}/encodings/encoding_utf.c
    ${_PSX_LR}/file/file_path.c
    ${_PSX_LR}/compat/compat_strl.c
    ${_PSX_LR}/compat/compat_posix_string.c
    ${_PSX_LR}/compat/compat_strcasestr.c
    ${_PSX_LR}/compat/fopen_utf8.c
    ${_PSX_LR}/compat/compat_snprintf.c
    ${_PSX_LR}/vfs/vfs_implementation.c
    ${_PSX_LR}/memmap/memalign.c
    # SHA-1 used by libretro.cpp for disc-id reporting.
    ${_PSX_LR}/hash/rhash.c
    # Bundled libretro-common is older than parallel-n64's — also
    # missing file_path_io / retro_dirent / time/rtime /
    # features_cpu / encoding_crc32. Add them only if a TU
    # references them at link time.
)

add_library(core_mednafen_psx_hw STATIC ${_PSX_CXX} ${_PSX_C})
target_include_directories(core_mednafen_psx_hw PUBLIC
    # Shared glsm shim FIRST so glsm.c's `#include <glsym/glsym.h>`
    # resolves to our pass-through shim (Switch GLES3 headers
    # directly) instead of the bundled rglgen-based dispatcher.
    # Same shim used by parallel_n64.cmake.
    ${CMAKE_CURRENT_LIST_DIR}/libretro_glsm_shims
    ${_PSX}
    ${_PSX_M}
    ${_PSX_M}/include
    ${_PSX_M}/intl
    ${_PSX_M}/hw_sound
    ${_PSX_M}/hw_cpu
    ${_PSX_M}/hw_misc
    ${_PSX_E}
    ${_PSX_LR}/include
    ${_PSX_DP}/libkirk
    $ENV{DEVKITPRO}/portlibs/switch/include
)
target_compile_definitions(core_mednafen_psx_hw PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    LSB_FIRST=1
    HAVE_STDINT_H=1
    INLINE=inline
    FRONTEND_SUPPORTS_RGB565=1
    HAVE_OPENGL=1
    HAVE_OPENGLES=1
    HAVE_OPENGLES3=1
    HAVE_PBP=1
    NEED_CD=1
    NEED_CRC32=1
    NEED_DEINTERLACER=1
    NEED_TREMOR=1
    NEED_BPP=32
    WANT_32BPP=1
    WANT_CRC32=1
    WANT_THREADING=1
    HAVE_THREADS=1
    PSS_STYLE=1
    SIZEOF_DOUBLE=8
    MEDNAFEN_VERSION=\"foyer-0.2\"
    MEDNAFEN_VERSION_NUMERIC=0
)
target_compile_options(core_mednafen_psx_hw PRIVATE -w -fno-strict-aliasing)
set_target_properties(core_mednafen_psx_hw PROPERTIES
    C_STANDARD 99 C_STANDARD_REQUIRED ON
    CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
