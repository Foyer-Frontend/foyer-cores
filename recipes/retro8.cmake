# cores/retro8.cmake — libretro retro8 (Pico-8 alternative interpreter).

include(FetchContent)

FetchContent_Declare(libretro_retro8
    GIT_REPOSITORY https://github.com/libretro/retro8.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
# Don't pull retro8's own CMakeLists.txt — it expects desktop SDL +
# standalone executable wiring. We just need the source tree.
FetchContent_GetProperties(libretro_retro8)
if (NOT libretro_retro8_POPULATED)
    FetchContent_Populate(libretro_retro8)
endif()

set(_R8 ${libretro_retro8_SOURCE_DIR})

file(GLOB _R8_CXX
    ${_R8}/src/io/*.cpp
    ${_R8}/src/libretro/*.cpp
    ${_R8}/src/vm/*.cpp
)
file(GLOB _R8_C ${_R8}/src/lua/*.c)

add_library(core_retro8 STATIC ${_R8_CXX} ${_R8_C})

target_include_directories(core_retro8 PUBLIC
    ${_R8}/src
    ${_R8}/src/io
    ${_R8}/src/lua
    ${_R8}/src/libretro
    ${_R8}/src/vm
)

target_compile_definitions(core_retro8 PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    NDEBUG=1
)

target_compile_options(core_retro8 PRIVATE -w -fno-strict-aliasing)

set_target_properties(core_retro8 PROPERTIES
    CXX_STANDARD 17
    CXX_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
