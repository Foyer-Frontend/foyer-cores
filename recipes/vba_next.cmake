# recipes/vba_next.cmake — libretro vba-next (fast GBA core).
#
# UNTESTED. First CI build will exercise it; the workflow's release job
# tolerates partial-matrix failures so a broken build here doesn't block
# the rest of the cores from publishing.

include(FetchContent)

FetchContent_Declare(libretro_vba_next
    GIT_REPOSITORY https://github.com/libretro/vba-next.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_vba_next)

set(_VN ${libretro_vba_next_SOURCE_DIR})

add_library(core_vba_next STATIC
    ${_VN}/src/gba.cpp
    ${_VN}/src/memory.cpp
    ${_VN}/src/sound.cpp
    ${_VN}/src/system.cpp
    ${_VN}/src/thread.c
    ${_VN}/libretro/libretro.cpp
)
target_include_directories(core_vba_next PUBLIC
    ${_VN}/src
    ${_VN}/libretro
    ${_VN}/libretro-common/include
)
target_compile_definitions(core_vba_next PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    USE_FRAME_SKIP=1
    HAVE_HLE_BIOS=1
    FRONTEND_SUPPORTS_RGB565=1
    # vba-next's sources use `INLINE` as a return-type prefix on already
    # `static`-marked functions. Define it as just `inline` so we get
    # `inline static foo()` (legal) instead of `static inline static`
    # (duplicate 'static' error from libretro-common headers).
    INLINE=inline
)
target_compile_options(core_vba_next PRIVATE -w)
set_target_properties(core_vba_next PROPERTIES
    C_STANDARD                99
    C_STANDARD_REQUIRED       ON
    CXX_STANDARD              11
    CXX_STANDARD_REQUIRED     ON
    POSITION_INDEPENDENT_CODE ON)
