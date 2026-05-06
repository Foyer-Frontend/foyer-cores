# cores/dosbox_pure.cmake — libretro DOSBox-pure (DOS-era games via
# DOSBox SVN with single-file zip ROM workflow + automatic config /
# OS install).
#
# Upstream Makefile globs `*.cpp src/*.cpp src/*/*.cpp src/*/*/*.cpp`
# for the source list — recreated here with GLOB_RECURSE rooted at
# repo top + src/. Plus libretro-common/features/features_cpu.c which
# the libnx target adds explicitly.
#
# STATIC_LINKING=1 is enabled (defines STATIC_LINKING). The libnx
# target keeps the dynarec on (no -DDISABLE_DYNAREC) so DOS games run
# via translated x86 → arm64 cache; this depends on libnx providing
# RWX JIT memory at runtime (svcMapJitMemory NACP capability — see
# the 0.2.x roadmap entry).

include(FetchContent)

FetchContent_Declare(libretro_dosbox_pure
    GIT_REPOSITORY https://github.com/libretro/dosbox-pure.git
    GIT_TAG        main
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_dosbox_pure)

set(_DBP ${libretro_dosbox_pure_SOURCE_DIR})

# Globs match the upstream Makefile's `*.cpp src/*.cpp src/*/*.cpp
# src/*/*/*.cpp` pattern — top-level + 1-3 levels under src/.
file(GLOB    _DBP_TOP "${_DBP}/*.cpp")
file(GLOB_RECURSE _DBP_SRC "${_DBP}/src/*.cpp")

set(_DBP_C
    ${_DBP}/libretro-common/features/features_cpu.c
)

# dosbox-pure's *.cpp files declare the helpers in features_cpu.c as
# `extern retro_time_t dbp_cpu_features_get_time_usec(void)` WITHOUT
# `extern "C"` — so the C++ TUs name-mangle the symbol but the C TU
# defines it unmangled, and the link fails with undefined references.
# Compile features_cpu.c as C++ so the definitions are mangled to
# match the call sites. Matches what upstream's libnx Makefile path
# does implicitly (CXX-only compile rules).
set_source_files_properties(${_DBP_C} PROPERTIES LANGUAGE CXX)

add_library(core_dosbox_pure STATIC ${_DBP_TOP} ${_DBP_SRC} ${_DBP_C})

target_include_directories(core_dosbox_pure PUBLIC
    ${_DBP}
    ${_DBP}/include
    ${_DBP}/libretro-common/include
)

target_compile_definitions(core_dosbox_pure PRIVATE
    __LIBRETRO__
    _FILE_OFFSET_BITS=64
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_dosbox_pure PRIVATE
    -w
    -fomit-frame-pointer
    -fexceptions
    -ffunction-sections
    -Wno-address-of-packed-member
    -Wno-format
    -Wno-switch
    -Wno-psabi
    # Upstream Makefile passes -fvisibility=hidden for shared-library
    # builds. We're producing a static archive that the player binary
    # links against, so hidden visibility would strip cross-TU symbols
    # like dbp_cpu_features_get_time_usec / get_core_amount that
    # voodoo.cpp/mixer.cpp pull in from features_cpu.inl.
)

set_target_properties(core_dosbox_pure PROPERTIES
    CXX_STANDARD              11
    CXX_EXTENSIONS            ON
    POSITION_INDEPENDENT_CODE ON)
