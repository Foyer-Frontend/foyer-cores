# recipes/mesen.cmake — libretro Mesen (cycle-accurate NES core).
#
# UNTESTED. Mesen is C++17 with a large, fairly flat source tree. We
# glob the .cpp files at the top of Core/ and Utilities/ (avoiding the
# Lua / SevenZip subdirs that aren't part of the libretro build) plus
# the libretro frontend.

include(FetchContent)

FetchContent_Declare(libretro_mesen
    GIT_REPOSITORY https://github.com/libretro/Mesen.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_mesen)

set(_M ${libretro_mesen_SOURCE_DIR})

# Top-level Core/ and Utilities/ .cpp files only — sub-directories like
# Utilities/SevenZip and Utilities/Lua are excluded from libretro builds.
file(GLOB _MESEN_CORE  "${_M}/Core/*.cpp")
file(GLOB _MESEN_UTIL  "${_M}/Utilities/*.cpp")
list(APPEND _MESEN_SRC ${_MESEN_CORE} ${_MESEN_UTIL}
    ${_M}/Libretro/libretro.cpp
)

add_library(core_mesen STATIC ${_MESEN_SRC})
target_include_directories(core_mesen PUBLIC
    ${_M}
    ${_M}/Core
    ${_M}/Utilities
    ${_M}/Libretro
)
target_compile_definitions(core_mesen PRIVATE
    LIBRETRO=1
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    NDEBUG=1
)
target_compile_options(core_mesen PRIVATE -w -fno-strict-aliasing)
set_target_properties(core_mesen PROPERTIES
    CXX_STANDARD              17
    CXX_STANDARD_REQUIRED     ON
    POSITION_INDEPENDENT_CODE ON)
