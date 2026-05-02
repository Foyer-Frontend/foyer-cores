# recipes/sameboy.cmake — libretro SameBoy (high-accuracy GB / GBC core).
#
# UNTESTED. Source list mirrors libretro/Makefile.common; the boot ROM
# files (agb_boot.c etc.) are checked-in pre-generated arrays in the
# libretro/ directory.

include(FetchContent)

FetchContent_Declare(libretro_sameboy
    GIT_REPOSITORY https://github.com/libretro/SameBoy.git
    # Track buildbot — that's where libretro's CI keeps the prebuilt
    # boot ROM .bin files in BootROMs/prebuilt/. master ships only the
    # .asm sources which we have no rgbds toolchain for.
    GIT_TAG        buildbot
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_sameboy)

set(_SB ${libretro_sameboy_SOURCE_DIR})

# The libretro target expects {agb,cgb,dmg,sgb,sgb2}_boot.c containing
# the boot ROM byte arrays. Upstream generates them from
# BootROMs/prebuilt/<name>_boot.bin via `xxd -i -n <name>_boot`. We do
# the same here at configure-time-as-build-step so the .c files land in
# our build dir without modifying upstream sources.
set(_SB_BOOT_GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/sameboy_boots)
file(MAKE_DIRECTORY ${_SB_BOOT_GEN_DIR})
set(_SB_BOOT_GEN)
foreach(_rom IN ITEMS agb cgb dmg sgb sgb2)
    set(_bin ${_SB}/BootROMs/prebuilt/${_rom}_boot.bin)
    set(_c   ${_SB_BOOT_GEN_DIR}/${_rom}_boot.c)
    add_custom_command(
        OUTPUT  ${_c}
        # xxd -n NAME emits `NAME[]` + `NAME_len`; libretro.c expects
        # `NAME_length`. Pipe through sed to rename the size symbol.
        COMMAND sh -c "xxd -i -n ${_rom}_boot ${_bin} | sed 's/${_rom}_boot_len/${_rom}_boot_length/g' > ${_c}"
        DEPENDS ${_bin}
        COMMENT "Generating ${_rom}_boot.c from ${_rom}_boot.bin"
        VERBATIM)
    list(APPEND _SB_BOOT_GEN ${_c})
endforeach()

# Force-include sameboy_compat.h into every TU so the getline shim is
# visible before SameBoy's gb.c declares its debugger STDIN callback.
set(_SB_COMPAT_HDR ${CMAKE_CURRENT_LIST_DIR}/sameboy_compat.h)

set(_SB_COMM ${_SB}/libretro/libretro-common)

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
        ${_SB_BOOT_GEN}
        ${_SB}/libretro/libretro.c
        # libretro-common (mirrors Makefile.common's STATIC_LINKING != 1 branch).
        ${_SB_COMM}/compat/compat_posix_string.c
        ${_SB_COMM}/compat/compat_snprintf.c
        ${_SB_COMM}/compat/compat_strcasestr.c
        ${_SB_COMM}/compat/compat_strl.c
        ${_SB_COMM}/compat/fopen_utf8.c
        ${_SB_COMM}/encodings/encoding_utf.c
        ${_SB_COMM}/file/file_path.c
        ${_SB_COMM}/file/file_path_io.c
        ${_SB_COMM}/streams/file_stream.c
        ${_SB_COMM}/streams/file_stream_transforms.c
        ${_SB_COMM}/string/stdstring.c
        ${_SB_COMM}/time/rtime.c
        ${_SB_COMM}/vfs/vfs_implementation.c
    INCLUDE_DIRS
        ${_SB}
        ${_SB}/Core
        ${_SB}/libretro
        ${_SB_COMM}/include
    COMPILE_DEFS
        __LIBRETRO__=1
        SWITCH=1
        __SWITCH__=1
        HAVE_LIBNX=1
        GB_INTERNAL=1
        # Disable the optional GB subsystems whose .c files we don't
        # build — gb.c #ifdefs the calls into no-ops with these set.
        GB_DISABLE_TIMEKEEPING=1
        GB_DISABLE_REWIND=1
        GB_DISABLE_DEBUGGER=1
        GB_DISABLE_CHEATS=1
        _GNU_SOURCE=1
        _USE_MATH_DEFINES=1
        SAMEBOY_CORE_VERSION=\"foyer-0.2\"
        GB_VERSION=\"foyer-0.2\"
    COMPILE_OPTS
        "SHELL:-include ${_SB_COMPAT_HDR}"
)
