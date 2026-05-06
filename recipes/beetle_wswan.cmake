# cores/beetle_wswan.cmake — libretro Beetle WonderSwan (Mednafen).
#
# Tiny Mednafen core (no CD, no tremor). HAVE_GRIFFIN=0. Defaults
# from upstream Makefile: NEED_BPP=16, NEED_BLIP=1, NEED_STEREO_SOUND=1.

include(FetchContent)

FetchContent_Declare(libretro_beetle_wswan
    GIT_REPOSITORY https://github.com/libretro/beetle-wswan-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_beetle_wswan)

set(_WS    ${libretro_beetle_wswan_SOURCE_DIR})
set(_WS_M  ${_WS}/mednafen)
set(_WS_E  ${_WS_M}/wswan)
set(_WS_LR ${_WS}/libretro-common)

set(_WS_C
    ${_WS_E}/sound.c
    ${_WS_E}/interrupt.c
    ${_WS_E}/rtc.c
    ${_WS_E}/tcache.c
    ${_WS_E}/gfx.c
    ${_WS_E}/wswan-memory.c
    ${_WS_E}/v30mz.c
    ${_WS_E}/eeprom.c
    ${_WS_M}/sound/Blip_Buffer.c
    ${_WS_M}/state.c
    ${_WS_M}/settings.c
    ${_WS}/libretro.c
    ${_WS_LR}/compat/compat_strl.c
    ${_WS_LR}/compat/compat_snprintf.c
)

set(_WS_CXX
    ${_WS_M}/mempatcher.cpp
)

add_library(core_beetle_wswan STATIC ${_WS_C} ${_WS_CXX})

target_include_directories(core_beetle_wswan PUBLIC
    ${_WS}
    ${_WS_M}
    ${_WS_M}/include
    ${_WS_M}/hw_sound
    ${_WS_M}/hw_cpu
    ${_WS_M}/hw_misc
    ${_WS_LR}/include
)

target_compile_definitions(core_beetle_wswan PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    LSB_FIRST=1
    HAVE_STDINT_H=1
    INLINE=inline
    FRONTEND_SUPPORTS_RGB565=1
    NEED_BPP=16
    WANT_16BPP=1
    WANT_STEREO_SOUND=1
    SIZEOF_DOUBLE=8
    MEDNAFEN_VERSION=\"foyer-0.3\"
    MEDNAFEN_VERSION_NUMERIC=0
    STATIC_LINKING=1
)

target_compile_options(core_beetle_wswan PRIVATE
    -w
    -fno-strict-aliasing
    -U__linux__
    -U__linux
)

set_target_properties(core_beetle_wswan PROPERTIES
    C_STANDARD              99
    C_STANDARD_REQUIRED     ON
    CXX_STANDARD            11
    CXX_STANDARD_REQUIRED   ON
    POSITION_INDEPENDENT_CODE ON)
