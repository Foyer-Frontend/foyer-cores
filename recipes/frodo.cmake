# cores/frodo.cmake — libretro Frodo (Commodore 64). Lighter
# alternative to vice; ships only the C64 base machine, no peripheral
# variants.
#
# Default EMUTYPE=frodo (not frodosc — single-cycle is heavier).

include(FetchContent)

FetchContent_Declare(libretro_frodo
    GIT_REPOSITORY https://github.com/libretro/frodo-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_frodo)

set(_FR     ${libretro_frodo_SOURCE_DIR})
set(_FR_E   ${_FR}/Src)
set(_FR_LR  ${_FR_E}/libretro-common)
set(_FR_GUI ${_FR}/libretro/gui)

add_library(core_frodo STATIC
    # libretro-common
    ${_FR_LR}/string/stdstring.c
    ${_FR_LR}/encodings/encoding_crc32.c
    ${_FR_LR}/encodings/encoding_utf.c
    ${_FR_LR}/compat/compat_strcasestr.c
    ${_FR_LR}/compat/compat_strl.c
    ${_FR_LR}/vfs/vfs_implementation.c
    ${_FR_LR}/streams/trans_stream_zlib.c
    ${_FR_LR}/streams/file_stream.c
    ${_FR_LR}/streams/file_stream_transforms.c
    ${_FR_LR}/file/file_path_io.c
    ${_FR_LR}/file/file_path.c
    ${_FR_LR}/time/rtime.c
    ${_FR_LR}/compat/fopen_utf8.c
    ${_FR_LR}/libco/libco.c
    ${_FR}/libretro/scandir.c
    # zlib
    ${_FR_E}/zlib/adler32.c
    ${_FR_E}/zlib/crc32.c
    ${_FR_E}/zlib/deflate.c
    ${_FR_E}/zlib/gzclose.c
    ${_FR_E}/zlib/gzlib.c
    ${_FR_E}/zlib/gzread.c
    ${_FR_E}/zlib/gzwrite.c
    ${_FR_E}/zlib/inffast.c
    ${_FR_E}/zlib/inflate.c
    ${_FR_E}/zlib/inftrees.c
    ${_FR_E}/zlib/trees.c
    ${_FR_E}/zlib/zutil.c
    # Frodo emu (non-SC variant)
    ${_FR_E}/main.cpp
    ${_FR_E}/Display.cpp
    ${_FR_E}/Prefs.cpp
    ${_FR_E}/SID.cpp
    ${_FR_E}/REU.cpp
    ${_FR_E}/IEC.cpp
    ${_FR_E}/1541fs.cpp
    ${_FR_E}/1541d64.cpp
    ${_FR_E}/1541t64.cpp
    ${_FR_E}/1541job.cpp
    ${_FR_E}/C64.cpp
    ${_FR_E}/CPUC64.cpp
    ${_FR_E}/VIC.cpp
    ${_FR_E}/CIA.cpp
    ${_FR_E}/CPU1541.cpp
    # Libretro frontend
    ${_FR}/libretro/core/libretro.cpp
    ${_FR}/libretro/core/core-mapper.cpp
    ${_FR}/libretro/core/graph.cpp
    ${_FR_GUI}/dialog.cpp
    ${_FR_GUI}/paths.cpp
    ${_FR_GUI}/file.cpp
    ${_FR_GUI}/unzip.cpp
    ${_FR_GUI}/thumb.cpp
    ${_FR_GUI}/zip.cpp
    ${_FR_GUI}/dlgFloppy.cpp
    ${_FR_GUI}/dlgFileSelect.cpp
    ${_FR_GUI}/dlgJoystick.cpp
    ${_FR_GUI}/dlgAbout.cpp
    ${_FR_GUI}/dlgSound.cpp
    ${_FR_GUI}/dlgAlert.cpp
    ${_FR_GUI}/dlgMisc.cpp
    ${_FR_GUI}/dlgVideo.cpp
    ${_FR_GUI}/dlgMain.cpp
    ${_FR_GUI}/dlgSnapshot.cpp
    ${_FR_GUI}/sdlgui.cpp
)

target_include_directories(core_frodo PUBLIC
    ${_FR}
    ${_FR}/libretro/core
    ${_FR}/libretro/include
    ${_FR}/libretro/emu
    ${_FR}/libretro
    ${_FR_E}
    ${_FR_E}/zlib
    ${_FR_LR}/include
)

target_compile_definitions(core_frodo PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    PRECISE_CPU_CYCLES=1
    PRECISE_CIA_CYCLES=1
    PC_IS_POINTER=0
    FRODO_HPUX_REV=0
    KBD_LANG=0
    NDEBUG=1
)

target_compile_options(core_frodo PRIVATE -w -fno-strict-aliasing $<$<COMPILE_LANGUAGE:CXX>:-fpermissive>)

set_target_properties(core_frodo PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    CXX_STANDARD 11 CXX_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
