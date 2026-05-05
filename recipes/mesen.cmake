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

# HD-packs default-to-disabled. atmosphère report 01778012390 caught
# Mesen data-aborting at HdPackLoader::ProcessPatchTag:297 — `_data`
# was nullptr when the patch tag tried to write into PatchesByHash
# (offset 0xc0 from null). Mesen's libretro core options set
# `mesen_hdpacks` to "enabled" by default (libretro_core_options.h:330);
# without an HD pack on disk for the rom the loader still walks the
# init path and dies. Flipping the default to "disabled" stops the
# crash for every user who never opted into HD packs in the first place.
# Users who DO want them can override via /foyer/config/cores/mesen.jsonc.
set(_MESEN_OPTS ${_M}/Libretro/libretro_core_options.h)
if (EXISTS ${_MESEN_OPTS})
    file(READ ${_MESEN_OPTS} _t)
    string(REPLACE
        "{ \"enabled\",  NULL },\n         { NULL, NULL },\n      },\n      \"enabled\"\n   },\n   {\n      \"mesen_screenrotation\""
        "{ \"enabled\",  NULL },\n         { NULL, NULL },\n      },\n      \"disabled\"\n   },\n   {\n      \"mesen_screenrotation\""
        _t "${_t}")
    file(WRITE ${_MESEN_OPTS} "${_t}")
endif()

# Top-level Core/ + Utilities/ .cpp files PLUS the scaler sub-dirs
# (HQX, xBRZ, Scale2x, KreedSaiEagle) and the LZMA SDK at SevenZip/
# (which lives at the repo root, not under Utilities/). Lua is the only
# Utilities/ subdir we deliberately skip.
file(GLOB _MESEN_CORE       "${_M}/Core/*.cpp")
file(GLOB _MESEN_UTIL       "${_M}/Utilities/*.cpp")
file(GLOB _MESEN_HQX        "${_M}/Utilities/HQX/*.cpp")
file(GLOB _MESEN_XBRZ       "${_M}/Utilities/xBRZ/*.cpp")
file(GLOB _MESEN_SCALE2X    "${_M}/Utilities/Scale2x/*.cpp")
file(GLOB _MESEN_KREEDSAI   "${_M}/Utilities/KreedSaiEagle/*.cpp")
file(GLOB _MESEN_SEVENZIP_C "${_M}/SevenZip/*.c")

list(APPEND _MESEN_SRC
    ${_MESEN_CORE} ${_MESEN_UTIL}
    ${_MESEN_HQX} ${_MESEN_XBRZ} ${_MESEN_SCALE2X} ${_MESEN_KREEDSAI}
    ${_MESEN_SEVENZIP_C}
    ${_M}/Libretro/libretro.cpp
)

add_library(core_mesen STATIC ${_MESEN_SRC})
target_include_directories(core_mesen PUBLIC
    ${_M}
    ${_M}/Core
    ${_M}/Utilities
    ${_M}/Utilities/HQX
    ${_M}/Utilities/xBRZ
    ${_M}/SevenZip
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
