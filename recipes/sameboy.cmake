# recipes/sameboy.cmake — libretro SameBoy (high-accuracy GB / GBC core).
#
# UNTESTED. Source list mirrors libretro/Makefile.common; the boot ROM
# files (agb_boot.c etc.) are checked-in pre-generated arrays in the
# libretro/ directory.

include(FetchContent)

FetchContent_Declare(libretro_sameboy
    GIT_REPOSITORY https://github.com/libretro/SameBoy.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_sameboy)

set(_SB ${libretro_sameboy_SOURCE_DIR})

foyer_core_static_library(
    NAME sameboy
    SOURCES
        ${_SB}/Core/gb.c
        ${_SB}/Core/sgb.c
        ${_SB}/Core/apu.c
        ${_SB}/Core/memory.c
        ${_SB}/Core/mbc.c
        ${_SB}/Core/timing.c
        ${_SB}/Core/display.c
        ${_SB}/Core/symbol_hash.c
        ${_SB}/Core/camera.c
        ${_SB}/Core/sm83_cpu.c
        ${_SB}/Core/joypad.c
        ${_SB}/Core/save_state.c
        ${_SB}/Core/random.c
        ${_SB}/Core/rumble.c
        ${_SB}/libretro/agb_boot.c
        ${_SB}/libretro/cgb_boot.c
        ${_SB}/libretro/dmg_boot.c
        ${_SB}/libretro/sgb_boot.c
        ${_SB}/libretro/sgb2_boot.c
        ${_SB}/libretro/libretro.c
    INCLUDE_DIRS
        ${_SB}
        ${_SB}/Core
        ${_SB}/libretro
    COMPILE_DEFS
        __LIBRETRO__=1
        SWITCH=1
        __SWITCH__=1
        HAVE_LIBNX=1
        GB_INTERNAL=1
        _GNU_SOURCE=1
        _USE_MATH_DEFINES=1
        SAMEBOY_CORE_VERSION=\"foyer-0.2\"
)
