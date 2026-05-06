# cores/caprice32.cmake — libretro caprice32 (Amstrad CPC).
#
# Source list mirrors upstream Makefile.common's libnx target
# (STATIC_LINKING=1). The libretro-common subset upstream skips under
# STATIC_LINKING=1 is added back unconditionally — same pattern as
# tyrquake — because our player binary doesn't supply those symbols.

include(FetchContent)

FetchContent_Declare(libretro_caprice32
    GIT_REPOSITORY https://github.com/libretro/libretro-cap32.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_caprice32)

set(_C32     ${libretro_caprice32_SOURCE_DIR})
set(_C32_LRC ${_C32}/libretro-common)

set(_C32_C
    ${_C32}/libretro/libretro-core.c
    ${_C32}/cap32/cap32.c
    ${_C32}/cap32/slots.c
    ${_C32}/cap32/crtc.c
    ${_C32}/cap32/fdc.c
    ${_C32}/cap32/psg.c
    ${_C32}/cap32/tape.c
    ${_C32}/cap32/cart.c
    ${_C32}/cap32/asic.c
    ${_C32}/cap32/z80.c
    ${_C32}/cap32/kbdauto.c
    ${_C32}/cap32/lightgun/gunstick.c
    ${_C32}/cap32/lightgun/phaser.c
    ${_C32}/libretro/microui/microui.c
    ${_C32}/libretro/db/database.c
    ${_C32}/libretro/dsk/loader.c
    ${_C32}/libretro/dsk/format.c
    ${_C32}/libretro/dsk/amsdos_catalog.c
    ${_C32}/libretro/gfx/software.c
    ${_C32}/libretro/gfx/video.c
    ${_C32}/libretro/gfx/video8bpp.c
    ${_C32}/libretro/gfx/video16bpp.c
    ${_C32}/libretro/gfx/video24bpp.c
    ${_C32}/libretro/assets/ui_keyboard_bg_crop.c
    ${_C32}/libretro/assets/ui_keyboard_bg.c
    ${_C32}/libretro/assets/ui_keyboard_en.c
    ${_C32}/libretro/assets/ui_keyboard_es.c
    ${_C32}/libretro/assets/ui_keyboard_fr.c
    ${_C32}/libretro/assets/font.c
    ${_C32}/libretro/retro_strings.c
    ${_C32}/libretro/retro_utils.c
    ${_C32}/libretro/retro_disk_control.c
    ${_C32}/libretro/retro_events.c
    ${_C32}/libretro/retro_snd.c
    ${_C32}/libretro/retro_render.c
    ${_C32}/libretro/retro_ui.c
    ${_C32}/libretro/retro_gun.c
    ${_C32}/libretro/retro_keyboard.c
    # libretro-common subset (upstream gates these on STATIC_LINKING != 1
    # but our player binary doesn't supply them either).
    ${_C32_LRC}/file/file_path.c
    ${_C32_LRC}/string/stdstring.c
    ${_C32_LRC}/compat/compat_strl.c
    ${_C32_LRC}/encodings/encoding_utf.c
    ${_C32_LRC}/time/rtime.c
    ${_C32_LRC}/memmap/memalign.c
)

add_library(core_caprice32 STATIC ${_C32_C})

target_include_directories(core_caprice32 PUBLIC
    ${_C32}
    ${_C32}/cap32
    ${_C32}/libretro
    ${_C32}/libretro/microui
    ${_C32_LRC}/include
)

target_compile_definitions(core_caprice32 PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    FRONTEND_SUPPORTS_RGB565=1
    HAVE_GETPWUID=0
    HAVE_GETCWD=1
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_caprice32 PRIVATE
    -w
    -fomit-frame-pointer
    -ffast-math
    -ffunction-sections
    -ftree-vectorize
)

set_target_properties(core_caprice32 PROPERTIES
    C_STANDARD 99
    C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
