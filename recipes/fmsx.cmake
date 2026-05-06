# cores/fmsx.cmake — libretro fMSX (MSX/MSX2/MSX2+).

include(FetchContent)

FetchContent_Declare(libretro_fmsx
    GIT_REPOSITORY https://github.com/libretro/fmsx-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_fmsx)

set(_FM     ${libretro_fmsx_SOURCE_DIR})
set(_FM_LR  ${_FM}/libretro-common)
set(_FM_E   ${_FM}/EMULib)
set(_FM_X   ${_FM}/fMSX)
set(_FM_Z   ${_FM}/Z80)
set(_FM_N   ${_FM}/NukeYKT)

add_library(core_fmsx STATIC
    ${_FM}/libretro.c
    ${_FM_E}/Sound.c
    ${_FM_X}/MSX.c
    ${_FM_X}/V9938.c
    ${_FM_E}/SHA1.c
    ${_FM_E}/Floppy.c
    ${_FM_E}/FDIDisk.c
    ${_FM_E}/MCF.c
    ${_FM_Z}/Z80.c
    ${_FM_E}/I8255.c
    ${_FM_E}/YM2413.c
    ${_FM_E}/AY8910.c
    ${_FM_E}/SCC.c
    ${_FM_E}/WD1793.c
    ${_FM_N}/opll.c
    ${_FM_N}/WrapNukeYKT.c
    # libretro-common (upstream gates these on STATIC_LINKING != 1
    # but our player binary doesn't supply them either).
    ${_FM_LR}/file/retro_dirent.c
    ${_FM_LR}/file/file_path.c
    ${_FM_LR}/file/file_path_io.c
    ${_FM_LR}/compat/compat_posix_string.c
    ${_FM_LR}/compat/compat_strl.c
    ${_FM_LR}/compat/compat_snprintf.c
    ${_FM_LR}/compat/fopen_utf8.c
    ${_FM_LR}/compat/compat_strcasestr.c
    ${_FM_LR}/encodings/encoding_utf.c
    ${_FM_LR}/streams/file_stream.c
    ${_FM_LR}/streams/file_stream_transforms.c
    ${_FM_LR}/time/rtime.c
    ${_FM_LR}/string/stdstring.c
    ${_FM_LR}/vfs/vfs_implementation.c
)

target_include_directories(core_fmsx PUBLIC
    ${_FM}
    ${_FM_LR}/include
    ${_FM_E}
    ${_FM_Z}
    ${_FM_X}
)

target_compile_definitions(core_fmsx PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    SKIP_STDIO_REDEFINES
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_fmsx PRIVATE -w -fno-strict-aliasing)

set_target_properties(core_fmsx PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
