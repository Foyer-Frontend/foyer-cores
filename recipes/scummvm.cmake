# cores/scummvm.cmake — libretro ScummVM (point-and-click adventure
# engine).
#
# ScummVM's libretro port lives at backends/platform/libretro/ inside
# the main scummvm repo. The build:
#   1. Auto-clones libretro-deps + libretro-common into libretro/deps
#      via dependencies.mk's submodule_test machinery.
#   2. Runs configure_engines.sh to write engines.mk.
#   3. Compiles every engines/<eng>/*.cpp module.mk lists (~1500+ TUs).
#   4. Archives objects + libdeps.a + libdetect.a into
#      scummvm_libretro_libnx.a via the script.mri ar script.
#
# Way too big for a hand-rolled CMake source list — drive the upstream
# Makefile directly with `make platform=libnx`, same pattern as
# ppsspp.cmake / mame2003_plus.cmake.

include(FetchContent)

FetchContent_Declare(libretro_scummvm
    GIT_REPOSITORY https://github.com/scummvm/scummvm.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_GetProperties(libretro_scummvm)
if (NOT libretro_scummvm_POPULATED)
    FetchContent_Populate(libretro_scummvm)
endif()

set(_SCV     ${libretro_scummvm_SOURCE_DIR})
set(_SCV_LR  ${_SCV}/backends/platform/libretro)
# The ar script.mri produces libtemp/scummvm_libretro_libnx.a — but
# upstream's libnx target writes to that intermediate dir. Final
# output ends up at $(TARGET) = scummvm_libretro_libnx.a in the
# libretro/ dir per the Makefile.
set(_SCV_LIBA ${_SCV_LR}/scummvm_libretro_libnx.a)

include(ProcessorCount)
ProcessorCount(_SCV_NPROC)
if (NOT _SCV_NPROC GREATER 0)
    set(_SCV_NPROC 4)
endif()

# Re-run upstream's `make platform=libnx` every configure. The
# Makefile is incremental — it only re-archives when objects changed.
add_custom_command(
    OUTPUT  ${_SCV_LIBA}
    COMMAND ${CMAKE_COMMAND} -E env
                DEVKITPRO=$ENV{DEVKITPRO}
                DEVKITA64=$ENV{DEVKITA64}
                PORTLIBS=$ENV{PORTLIBS}
                ${CMAKE_MAKE_PROGRAM} -C ${_SCV_LR}
                    platform=libnx -j${_SCV_NPROC}
    WORKING_DIRECTORY ${_SCV_LR}
    COMMENT "Building scummvm_libretro_libnx.a via upstream Makefile (this is slow)"
    VERBATIM)

add_custom_target(scummvm_libretro_a_target
    DEPENDS ${_SCV_LIBA})

# core_scummvm — INTERFACE wrapper. ScummVM's .a is self-contained
# (libretro-deps + libretro-common get archived in via libdeps.a +
# libdetect.a + script.mri merge), but it still references zlib's
# `inflate`/`deflate` etc. — those resolve from devkitPro's libz
# (foyer_shared publicly links ZLIB::ZLIB).
add_library(core_scummvm INTERFACE)
add_dependencies(core_scummvm scummvm_libretro_a_target)
target_link_libraries(core_scummvm INTERFACE
    -Wl,--start-group
    ${_SCV_LIBA}
    -lz
    -Wl,--end-group
)
