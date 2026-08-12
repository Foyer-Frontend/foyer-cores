# cores/mame2003_plus.cmake — libretro MAME 2003-Plus (arcade).
#
# 2700+ source files across drivers/* and dependencies — way too big
# for a hand-rolled CMake source list. Drive upstream's Makefile with
# `make platform=libnx` directly, same pattern as ppsspp.cmake.
#
# Output: mame2003_plus_libretro_libnx.a, wrapped as INTERFACE library
# core_mame2003_plus that the player binary links against.

include(FetchContent)

FetchContent_Declare(libretro_mame2003_plus
    GIT_REPOSITORY https://github.com/libretro/mame2003-plus-libretro.git
    GIT_TAG        80a84d2df0f84e028c752a765796722d6e9bd49d
    GIT_SHALLOW    FALSE
    GIT_CONFIG     "core.autocrlf=false" "core.eol=lf"
    UPDATE_DISCONNECTED FALSE)
FetchContent_GetProperties(libretro_mame2003_plus)
if (NOT libretro_mame2003_plus_POPULATED)
    FetchContent_Populate(libretro_mame2003_plus)
    # CRLF fix: upstream gng.c has CRLF; container global core.autocrlf
    # (true) leaves the working copy dirty → FetchContent's
    # git fetch + rebase aborts with "Your local changes to
    # src/drivers/gng.c would be overwritten". Force the checkout to
    # LF and clean any stash leftover from the failed rebase.
    execute_process(COMMAND git -C ${libretro_mame2003_plus_SOURCE_DIR} config core.autocrlf false
                    RESULT_VARIABLE _mame_git_cfg1 OUTPUT_QUIET ERROR_QUIET)
    execute_process(COMMAND git -C ${libretro_mame2003_plus_SOURCE_DIR} config core.eol lf
                    RESULT_VARIABLE _mame_git_cfg2 OUTPUT_QUIET ERROR_QUIET)
    execute_process(COMMAND git -C ${libretro_mame2003_plus_SOURCE_DIR} reset --hard HEAD
                    RESULT_VARIABLE _mame_reset OUTPUT_QUIET ERROR_QUIET)
    execute_process(COMMAND git -C ${libretro_mame2003_plus_SOURCE_DIR} clean -fd
                    RESULT_VARIABLE _mame_clean OUTPUT_QUIET ERROR_QUIET)
    # Normalize gng.c to LF (the file is ~2 MB, cheap to sed)
    execute_process(COMMAND bash -c "sed -i 's/\\r$//' src/drivers/gng.c || true"
                    WORKING_DIRECTORY ${libretro_mame2003_plus_SOURCE_DIR}
                    RESULT_VARIABLE _mame_sed OUTPUT_QUIET ERROR_QUIET)
endif()

set(_MAME ${libretro_mame2003_plus_SOURCE_DIR})
set(_MAME_LIBA ${_MAME}/${PROJECT_NAME}_unused_placeholder)
set(_MAME_LIBA ${_MAME}/mame2003_plus_libretro_libnx.a)

include(ProcessorCount)
ProcessorCount(_MAME_NPROC)
if (NOT _MAME_NPROC GREATER 0)
    set(_MAME_NPROC 4)
endif()

# `make platform=libnx` produces the .a in the repo root. Re-run on
# every configure — the Makefile is incremental and skips re-link
# when no objects changed (STATIC_LINKING=1 still re-archives but
# that's cheap).
add_custom_command(
    OUTPUT  ${_MAME_LIBA}
    COMMAND ${CMAKE_COMMAND} -E env
                DEVKITPRO=$ENV{DEVKITPRO}
                DEVKITA64=$ENV{DEVKITA64}
                PORTLIBS=$ENV{PORTLIBS}
                ${CMAKE_MAKE_PROGRAM} -C ${_MAME}
                    platform=libnx -j${_MAME_NPROC}
    WORKING_DIRECTORY ${_MAME}
    COMMENT "Building mame2003_plus_libretro_libnx.a via upstream Makefile"
    VERBATIM)

add_custom_target(mame2003_plus_libretro_a_target
    DEPENDS ${_MAME_LIBA})

# Upstream's libnx target sets STATIC_LINKING=1, which excludes the
# libretro-common file/path/streams helpers from the .a — the
# Makefile assumes the frontend supplies them. Compile the subset
# fileio.c / png.c reference directly so we link clean.
set(_MAME_LRC ${_MAME}/src/libretro-common)
add_library(mame2003_plus_lrc STATIC
    ${_MAME_LRC}/file/file_path.c
    ${_MAME_LRC}/file/file_path_io.c
    ${_MAME_LRC}/file/retro_dirent.c
    ${_MAME_LRC}/streams/file_stream.c
    ${_MAME_LRC}/streams/file_stream_transforms.c
    ${_MAME_LRC}/streams/interface_stream.c
    ${_MAME_LRC}/streams/memory_stream.c
    ${_MAME_LRC}/string/stdstring.c
    ${_MAME_LRC}/encodings/encoding_utf.c
    ${_MAME_LRC}/compat/compat_strl.c
    ${_MAME_LRC}/compat/compat_snprintf.c
    ${_MAME_LRC}/compat/compat_posix_string.c
    ${_MAME_LRC}/compat/compat_strcasestr.c
    ${_MAME_LRC}/compat/fopen_utf8.c
    ${_MAME_LRC}/time/rtime.c
    ${_MAME_LRC}/vfs/vfs_implementation.c
)
target_include_directories(mame2003_plus_lrc PUBLIC ${_MAME_LRC}/include)
target_compile_options(mame2003_plus_lrc PRIVATE -w -fno-strict-aliasing)
set_target_properties(mame2003_plus_lrc PROPERTIES
    C_STANDARD 99 POSITION_INDEPENDENT_CODE ON)

# core_mame2003_plus — INTERFACE wrapper. zlib comes from devkitPro
# portlibs (foyer_shared already publicly links ZLIB::ZLIB; pass `-lz`
# inside the group too so it's available to png.c's uncompress() call,
# bypassing CMake's link-line de-dupe — same trick as ppsspp.cmake).
add_library(core_mame2003_plus INTERFACE)
add_dependencies(core_mame2003_plus mame2003_plus_libretro_a_target)
target_link_libraries(core_mame2003_plus INTERFACE
    -Wl,--start-group
    ${_MAME_LIBA}
    mame2003_plus_lrc
    -lz
    -Wl,--end-group
)
