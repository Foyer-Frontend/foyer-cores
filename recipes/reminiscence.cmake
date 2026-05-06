# cores/reminiscence.cmake — libretro REminiscence (Flashback engine
# reimplementation).

include(FetchContent)

FetchContent_Declare(libretro_reminiscence
    GIT_REPOSITORY https://github.com/libretro/reminiscence.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_reminiscence)

set(_RE    ${libretro_reminiscence_SOURCE_DIR})
set(_RE_S  ${_RE}/src)
set(_RE_LR ${_RE}/3rdparty/libretro-common)

add_library(core_reminiscence STATIC
    ${_RE}/3rdparty/libco/libco.c
    ${_RE_S}/unpack.c
    ${_RE_S}/collision.cpp
    ${_RE_S}/cutscene.cpp
    ${_RE_S}/file.cpp
    ${_RE_S}/fs.cpp
    ${_RE_S}/game.cpp
    ${_RE_S}/graphics.cpp
    ${_RE_S}/libretro.cpp
    ${_RE_S}/menu.cpp
    ${_RE_S}/mixer.cpp
    ${_RE_S}/mod_player.cpp
    ${_RE_S}/piege.cpp
    ${_RE_S}/resource.cpp
    ${_RE_S}/resource_aba.cpp
    ${_RE_S}/seq_player.cpp
    ${_RE_S}/sfx_player.cpp
    ${_RE_S}/staticres.cpp
    ${_RE_S}/video.cpp
    # libretro-common
    ${_RE_LR}/file/file_path.c
    ${_RE_LR}/string/stdstring.c
    ${_RE_LR}/compat/compat_strcasestr.c
    ${_RE_LR}/compat/compat_strl.c
    ${_RE_LR}/compat/fopen_utf8.c
    ${_RE_LR}/encodings/encoding_utf.c
    ${_RE_LR}/streams/file_stream.c
    ${_RE_LR}/streams/file_stream_transforms.c
    ${_RE_LR}/time/rtime.c
    ${_RE_LR}/vfs/vfs_implementation.c
)

target_include_directories(core_reminiscence PUBLIC
    ${_RE_S}
    ${_RE}/3rdparty
    ${_RE}/3rdparty/libco
    ${_RE_LR}/include
)

target_compile_definitions(core_reminiscence PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    HAVE_SETENV
    NDEBUG=1
)

target_compile_options(core_reminiscence PRIVATE -w -fno-strict-aliasing)

set_target_properties(core_reminiscence PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    CXX_STANDARD 11 CXX_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
