# recipes/mednafen_psx_hw.cmake — libretro Beetle PSX HW
# (Mednafen PSX with HW renderer + widescreen via OpenGL ES 3).
#
# Uses the upstream "griffin" unity build pattern: most of the core's
# .cpp / .c files are #included from beetle_psx_griffin{,_c}, so we
# only have to compile a handful of TUs.
#
# Requires foyer's HW render callback (shared/libretro/video_hw.cpp) —
# the core asks for an OpenGL ES 3 context via SET_HW_RENDER and
# renders into the FBO that HwContext provides.
#
# DEFERRED (not in matrix): upstream master's beetle_psx_griffin{,_c}
# unity TUs reference at least 5 files that have been renamed or
# removed without the unity files being updated:
#
#   * mednafen/settings.cpp  (now mednafen/settings.c)
#   * mednafen/state.cpp     (now mednafen/state.c)
#   * mednafen/mednafen-endian.c (now mednafen/mednafen-endian.cpp)
#   * mednafen/file.c        (removed entirely)
#   * mednafen/cdrom/SimpleFIFO.cpp (removed; only the header remains)
#
# A working build either needs (a) an older commit of beetle-psx
# pinned via GIT_TAG, (b) HAVE_GRIFFIN=0 with explicit per-source
# listing of ~100+ files, or (c) maintaining a foyer-cores fork that
# patches the unity TUs. The recipe below is the shape the build
# needs once one of those options is chosen — defines + include dirs
# are correct; only the source list needs work.

include(FetchContent)

FetchContent_Declare(libretro_psx_hw
    GIT_REPOSITORY https://github.com/libretro/beetle-psx-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_psx_hw)

set(_PSX     ${libretro_psx_hw_SOURCE_DIR})
set(_PSX_M   ${_PSX}/mednafen)
set(_PSX_E   ${_PSX_M}/psx)
set(_PSX_LR  ${_PSX}/libretro-common)
set(_PSX_DP  ${_PSX}/deps)

# Sources outside the griffin unity TUs.
set(_PSX_CXX
    # Unity C++ TU — pulls in mednafen/psx/{cpu,gpu,gte,spu,...},
    # mednafen/{error,settings,FileStream,...}, libretro.cpp,
    # rsx/rsx_intf.cpp.
    ${_PSX}/beetle_psx_griffin.cpp
    # HAVE_GRIFFIN-listed extras.
    ${_PSX_E}/dma.cpp
    ${_PSX_E}/sio.cpp
    # Root-level input mapping — libretro pad → PSX controllers.
    ${_PSX}/input.cpp
    # HW renderer backend.
    ${_PSX}/rsx/rsx_lib_gl.cpp
)

set(_PSX_C
    # Unity C TU — pulls in mednafen/tremor/*, libretro-common/*,
    # libkirk/*, mednafen/cdrom/*.
    ${_PSX}/beetle_psx_griffin_c.c
    # GLES3 sym loader (HAVE_OPENGL=1 + GLES3=1 path).
    ${_PSX_LR}/glsym/glsym_es3.c
    # Globals outside griffin (scrc32.c is pulled in via griffin_c.c).
    ${_PSX}/beetle_psx_globals.c
)

add_library(core_mednafen_psx_hw STATIC ${_PSX_CXX} ${_PSX_C})
target_include_directories(core_mednafen_psx_hw PUBLIC
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
    # Switch portlibs ship the GLES3 headers but the path isn't on
    # the default search list when we don't link against the libs
    # directly from this target. Add it so #include <GLES3/gl3.h>
    # from libretro-common's glsym path resolves.
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
    # Unity build + HW renderer + GLES3.
    HAVE_GRIFFIN=1
    HAVE_OPENGL=1
    HAVE_OPENGLES=1
    HAVE_OPENGLES3=1
    # Mednafen feature flags pulled from Makefile.common defaults.
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
