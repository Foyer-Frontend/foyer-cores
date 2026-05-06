# cores/beetle_vb.cmake — libretro Beetle Virtual Boy (Mednafen).
#
# Tiny Mednafen core (no CD, no tremor). HAVE_GRIFFIN=0. Defaults from
# upstream Makefile: NEED_BPP=32, NEED_BLIP=1.

include(FetchContent)

FetchContent_Declare(libretro_beetle_vb
    GIT_REPOSITORY https://github.com/libretro/beetle-vb-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_beetle_vb)

set(_VB    ${libretro_beetle_vb_SOURCE_DIR})
set(_VB_M  ${_VB}/mednafen)
set(_VB_E  ${_VB_M}/vb)
set(_VB_LR ${_VB}/libretro-common)

set(_VB_C
    ${_VB_E}/vsu.c
    ${_VB_E}/input.c
    ${_VB_E}/timer.c
    ${_VB_E}/vip.c
    ${_VB_M}/hw_cpu/v810/fpu-new/softfloat.c
    ${_VB_M}/sound/Blip_Buffer.c
    ${_VB_M}/state.c
    ${_VB_M}/settings.c
    ${_VB_LR}/compat/compat_strl.c
    ${_VB_LR}/compat/compat_snprintf.c
)

set(_VB_CXX
    ${_VB_M}/hw_cpu/v810/v810_cpu.cpp
    ${_VB_M}/mempatcher.cpp
    ${_VB}/libretro.cpp
)

add_library(core_beetle_vb STATIC ${_VB_C} ${_VB_CXX})

target_include_directories(core_beetle_vb PUBLIC
    ${_VB}
    ${_VB_M}
    ${_VB_M}/include
    ${_VB_M}/hw_sound
    ${_VB_M}/hw_cpu
    ${_VB_M}/hw_misc
    ${_VB_LR}/include
)

target_compile_definitions(core_beetle_vb PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    LSB_FIRST=1
    HAVE_STDINT_H=1
    INLINE=inline
    FRONTEND_SUPPORTS_RGB565=1
    NEED_BPP=32
    WANT_32BPP=1
    SIZEOF_DOUBLE=8
    MEDNAFEN_VERSION=\"foyer-0.3\"
    MEDNAFEN_VERSION_NUMERIC=0
    STATIC_LINKING=1
)

target_compile_options(core_beetle_vb PRIVATE
    -w
    -fno-strict-aliasing
    -U__linux__
    -U__linux
)

set_target_properties(core_beetle_vb PROPERTIES
    C_STANDARD              99
    C_STANDARD_REQUIRED     ON
    CXX_STANDARD            11
    CXX_STANDARD_REQUIRED   ON
    POSITION_INDEPENDENT_CODE ON)
