# cores/atari800.cmake — libretro Atari 800 / 5200 (Atari 8-bit
# family).

include(FetchContent)

FetchContent_Declare(libretro_atari800
    GIT_REPOSITORY https://github.com/libretro/libretro-atari800.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_atari800)

set(_AT     ${libretro_atari800_SOURCE_DIR})
set(_AT_S   ${_AT}/atari800/src)
set(_AT_LR  ${_AT}/libretro/libretro-common)
set(_AT_DP  ${_AT}/deps)

add_library(core_atari800 STATIC
    # libretro-common
    ${_AT_LR}/libco/libco.c
    ${_AT_LR}/compat/compat_strl.c
    ${_AT_LR}/compat/compat_strcasestr.c
    ${_AT_LR}/compat/fopen_utf8.c
    ${_AT_LR}/encodings/encoding_utf.c
    ${_AT_LR}/file/file_path.c
    ${_AT_LR}/file/file_path_io.c
    ${_AT_LR}/streams/memory_stream.c
    ${_AT_LR}/string/stdstring.c
    ${_AT_LR}/time/rtime.c
    ${_AT_LR}/vfs/vfs_implementation.c
    # Libretro frontend
    ${_AT}/libretro/carts_hash.c
    ${_AT}/libretro/libretro-core.c
    ${_AT}/libretro/core-mapper.c
    ${_AT}/libretro/graph.c
    ${_AT}/libretro/vkbd.c
    ${_AT}/libretro/retro_strings.c
    ${_AT}/libretro/retro_utils.c
    ${_AT}/libretro/retro_disk_control.c
    ${_AT}/libretro/platform.c
    # Atari800 emulator core
    ${_AT_S}/afile.c
    ${_AT_S}/antic.c
    ${_AT_S}/atari.c
    ${_AT_S}/binload.c
    ${_AT_S}/cartridge.c
    ${_AT_S}/cassette.c
    ${_AT_S}/compfile.c
    ${_AT_S}/cfg.c
    ${_AT_S}/cpu.c
    ${_AT_S}/crc32.c
    ${_AT_S}/devices.c
    ${_AT_S}/emuos.c
    ${_AT_S}/esc.c
    ${_AT_S}/gtia.c
    ${_AT_S}/img_tape.c
    ${_AT_S}/log.c
    ${_AT_S}/memory.c
    ${_AT_S}/monitor.c
    ${_AT_S}/pbi.c
    ${_AT_S}/pia.c
    ${_AT_S}/pokey.c
    ${_AT_S}/pokeysnd.c
    ${_AT_S}/mzpokeysnd.c
    ${_AT_S}/remez.c
    ${_AT_S}/sndsave.c
    ${_AT_S}/rtime.c
    ${_AT_S}/sio.c
    ${_AT_S}/sysrom.c
    ${_AT_S}/util.c
    ${_AT_S}/sound.c
    ${_AT_S}/pbi_proto80.c
    ${_AT_S}/af80.c
    ${_AT_S}/input.c
    ${_AT_S}/statesav.c
    ${_AT_S}/ui_basic.c
    ${_AT_S}/ui.c
    ${_AT_S}/artifact.c
    ${_AT_S}/colours.c
    ${_AT_S}/colours_ntsc.c
    ${_AT_S}/colours_pal.c
    ${_AT_S}/colours_external.c
    ${_AT_S}/screen.c
    ${_AT_S}/cycle_map.c
    ${_AT_S}/pbi_mio.c
    ${_AT_S}/pbi_bb.c
    ${_AT_S}/pbi_scsi.c
    ${_AT_S}/ide.c
    ${_AT_S}/xep80.c
    ${_AT_S}/xep80_fonts.c
    ${_AT_S}/filter_ntsc.c
    ${_AT_S}/atari_ntsc/atari_ntsc.c
    # Bundled Altirra OS roms (free replacements)
    ${_AT_S}/roms/altirraos_xl.c
    ${_AT_S}/roms/altirraos_800.c
    ${_AT_S}/roms/altirra_basic.c
    ${_AT_S}/roms/altirra_5200_os.c
    # zlib
    ${_AT_DP}/zlib/adler32.c
    ${_AT_DP}/zlib/crc32.c
    ${_AT_DP}/zlib/deflate.c
    ${_AT_DP}/zlib/gzclose.c
    ${_AT_DP}/zlib/gzlib.c
    ${_AT_DP}/zlib/gzread.c
    ${_AT_DP}/zlib/gzwrite.c
    ${_AT_DP}/zlib/inffast.c
    ${_AT_DP}/zlib/inflate.c
    ${_AT_DP}/zlib/inftrees.c
    ${_AT_DP}/zlib/trees.c
    ${_AT_DP}/zlib/zutil.c
)

target_include_directories(core_atari800 PUBLIC
    ${_AT}
    ${_AT_S}
    ${_AT}/libretro
    ${_AT}/libretro/include
    ${_AT_LR}/include
    ${_AT_LR}/include/compat/zlib
    ${_AT_DP}/zlib
)

target_compile_definitions(core_atari800 PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_atari800 PRIVATE -w -fno-strict-aliasing)

set_target_properties(core_atari800 PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
