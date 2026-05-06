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

# Pre-clone libretro-common into deps/ ourselves. ScummVM's Makefile
# only initialises this submodule on its first `make` run via
# dependencies.mk's submodule_test, but our scummvm_lrc shim lib
# below references compat/compat_strl.c at *configure* time — so on a
# fresh checkout (e.g. CI), the file isn't there yet and the configure
# fails with `Cannot find source file ... compat_strl.c`. Pinning to
# the same SHA dependencies.mk uses (DEPS_COMMIT_libretro-common)
# means scummvm's configure_submodules.sh sees a matching tree and
# leaves it alone. Bump this when upstream bumps theirs.
FetchContent_Declare(scummvm_libretro_common
    GIT_REPOSITORY https://github.com/libretro/libretro-common.git
    GIT_TAG        70ed90c42ddea828f53dd1b984c6443ddb39dbd6
    SOURCE_DIR     ${_SCV_LR}/deps/libretro-common)
FetchContent_GetProperties(scummvm_libretro_common)
if (NOT scummvm_libretro_common_POPULATED)
    FetchContent_Populate(scummvm_libretro_common)
endif()
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
# Some TUs (notably graphics/tinygl/ztriangle.cpp + the Director Lingo
# generated parsers) need >1 GiB of RAM each at -O2/-O3. Capping
# parallelism avoids the OOM killer on standard CI runners (8 GiB)
# while still keeping the bulk of the ~8800 small TUs going at full
# tilt. 4-wide is the sweet spot we measured.
if (_SCV_NPROC GREATER 4)
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

# Upstream's libretro Makefile only archives the libretro-common
# helpers scummvm itself directly references (file_path, hash,
# stdstring, …) into the .a. file_path.o calls strlcpy_retro__ /
# strlcat_retro__ via the compat/strl.h macro, but compat_strl.o
# isn't in the archive. Same shape as what we did for mame: build a
# tiny shim from the *same* libretro-common tree the .a was compiled
# against (fetched as a submodule into deps/libretro-common) so the
# struct layouts and inline declarations match exactly.
set(_SCV_LRC ${_SCV_LR}/deps/libretro-common)
add_library(scummvm_lrc STATIC
    ${_SCV_LRC}/compat/compat_strl.c
)
target_include_directories(scummvm_lrc PUBLIC ${_SCV_LRC}/include)
target_compile_options(scummvm_lrc PRIVATE -w -fno-strict-aliasing)
set_target_properties(scummvm_lrc PROPERTIES
    C_STANDARD 99 POSITION_INDEPENDENT_CODE ON)
# scummvm's libretro Makefile only initialises the deps/libretro-common
# submodule on the first `make` run. Hard-depend on the .a target so
# the submodule is guaranteed to exist before scummvm_lrc tries to
# compile compat_strl.c.
add_dependencies(scummvm_lrc scummvm_libretro_a_target)

# core_scummvm — INTERFACE wrapper. ScummVM's .a is self-contained
# for the bulk of its internals; we only need to add the compat
# shim above + zlib (foyer_shared already links ZLIB::ZLIB but its
# symbols may get de-duped out of the link group; pass `-lz` inside
# the group as a different string token to keep the second copy).
add_library(core_scummvm INTERFACE)
add_dependencies(core_scummvm scummvm_libretro_a_target)
target_link_libraries(core_scummvm INTERFACE
    -Wl,--start-group
    ${_SCV_LIBA}
    scummvm_lrc
    -lz
    -Wl,--end-group
)
