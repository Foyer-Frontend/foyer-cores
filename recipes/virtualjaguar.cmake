# cores/virtualjaguar.cmake — libretro Virtual Jaguar (Atari Jaguar).
# Uses the NEON SIMD blitter on aarch64 (auto-selected on Switch).

include(FetchContent)

FetchContent_Declare(libretro_virtualjaguar
    GIT_REPOSITORY https://github.com/libretro/virtualjaguar-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_virtualjaguar)

set(_VJ    ${libretro_virtualjaguar_SOURCE_DIR})
set(_VJ_S  ${_VJ}/src)
set(_VJ_LR ${_VJ}/libretro-common)

add_library(core_virtualjaguar STATIC
    ${_VJ}/libretro.c
    ${_VJ_S}/tom/blitter.c
    ${_VJ_S}/tom/blitter_compare.c
    ${_VJ_S}/tom/blitter_mmio.c
    ${_VJ_S}/tom/blitter_simd_neon.c
    ${_VJ_S}/jerry/dac.c
    ${_VJ_S}/jerry/dsp.c
    ${_VJ_S}/core/file.c
    ${_VJ_S}/tom/gpu.c
    ${_VJ_S}/core/jaguar.c
    ${_VJ_S}/jerry/jerry.c
    ${_VJ_S}/tom/op.c
    ${_VJ_S}/tom/tom.c
    ${_VJ_S}/cd/cdintf.c
    ${_VJ_S}/cd/cdrom.c
    ${_VJ_S}/core/cheat.c
    ${_VJ_S}/core/crc32.c
    ${_VJ_S}/core/event.c
    ${_VJ_S}/jerry/eeprom.c
    ${_VJ_S}/core/filedb.c
    ${_VJ_S}/m68000/cpustbl.c
    ${_VJ_S}/m68000/cpudefs.c
    ${_VJ_S}/m68000/cpuemu.c
    ${_VJ_S}/m68000/cpuextra.c
    ${_VJ_S}/m68000/m68kinterface.c
    ${_VJ_S}/m68000/readcpu.c
    ${_VJ_S}/bios/jagbios.c
    ${_VJ_S}/bios/jagcdbios.c
    ${_VJ_S}/bios/jagdevcdbios.c
    ${_VJ_S}/bios/jagstub1bios.c
    ${_VJ_S}/bios/jagstub2bios.c
    ${_VJ_S}/jerry/joystick.c
    ${_VJ_S}/core/settings.c
    ${_VJ_S}/core/memtrack.c
    ${_VJ_S}/core/vjag_memory.c
    ${_VJ_S}/core/universalhdr.c
    ${_VJ_S}/jerry/wavetable.c
    # libretro-common (upstream gates these on STATIC_LINKING != 1
    # but our player binary doesn't supply them either).
    ${_VJ_LR}/compat/compat_strcasestr.c
    ${_VJ_LR}/encodings/encoding_utf.c
    ${_VJ_LR}/compat/compat_snprintf.c
    ${_VJ_LR}/compat/compat_strl.c
    ${_VJ_LR}/compat/compat_posix_string.c
    ${_VJ_LR}/compat/fopen_utf8.c
    ${_VJ_LR}/streams/file_stream.c
    ${_VJ_LR}/streams/file_stream_transforms.c
    ${_VJ_LR}/string/stdstring.c
    ${_VJ_LR}/vfs/vfs_implementation.c
    ${_VJ_LR}/file/file_path.c
    ${_VJ_LR}/file/file_path_io.c
    ${_VJ_LR}/time/rtime.c
)

target_include_directories(core_virtualjaguar PUBLIC
    ${_VJ}
    ${_VJ_S}
    ${_VJ_S}/core
    ${_VJ_S}/tom
    ${_VJ_S}/jerry
    ${_VJ_S}/cd
    ${_VJ_S}/bios
    ${_VJ_S}/m68000
    ${_VJ_LR}/include
)

target_compile_definitions(core_virtualjaguar PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    INLINE=inline
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_virtualjaguar PRIVATE -w -fno-strict-aliasing -U__linux__ -U__linux)

set_target_properties(core_virtualjaguar PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
