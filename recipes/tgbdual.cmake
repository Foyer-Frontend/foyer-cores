# cores/tgbdual.cmake — libretro tgbdual (Game Boy with link-cable
# two-cart simulator).

include(FetchContent)

FetchContent_Declare(libretro_tgbdual
    GIT_REPOSITORY https://github.com/libretro/tgbdual-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_tgbdual)

set(_TG ${libretro_tgbdual_SOURCE_DIR})

add_library(core_tgbdual STATIC
    ${_TG}/gb_core/apu.cpp
    ${_TG}/gb_core/cheat.cpp
    ${_TG}/gb_core/cpu.cpp
    ${_TG}/gb_core/gb.cpp
    ${_TG}/gb_core/lcd.cpp
    ${_TG}/gb_core/mbc.cpp
    ${_TG}/gb_core/rom.cpp
    ${_TG}/libretro/dmy_renderer.cpp
    ${_TG}/libretro/libretro.cpp
)

target_include_directories(core_tgbdual PUBLIC
    ${_TG}
    ${_TG}/gb_core
    ${_TG}/libretro
    ${_TG}/libretro-common/include
)

target_compile_definitions(core_tgbdual PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_tgbdual PRIVATE
    -w
    -fno-strict-aliasing
    -U__linux__
    -U__linux
    $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>
)

set_target_properties(core_tgbdual PROPERTIES
    CXX_STANDARD 11
    CXX_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
