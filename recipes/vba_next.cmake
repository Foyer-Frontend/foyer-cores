# recipes/vba_next.cmake — libretro vba-next (fast GBA core).
#
# UNTESTED. First CI build will exercise it; the workflow's release job
# tolerates partial-matrix failures so a broken build here doesn't block
# the rest of the cores from publishing.

include(FetchContent)

FetchContent_Declare(libretro_vba_next
    GIT_REPOSITORY https://github.com/libretro/vba-next.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_vba_next)

set(_VN ${libretro_vba_next_SOURCE_DIR})

set(_VN_COMMON ${_VN}/libretro-common)

add_library(core_vba_next STATIC
    ${_VN}/src/gba.cpp
    ${_VN}/src/memory.cpp
    ${_VN}/src/sound.cpp
    ${_VN}/src/system.cpp
    ${_VN}/src/thread.c
    ${_VN}/libretro/libretro.cpp
    # libretro-common compat (filestream_* + friends — vba-next's
    # libretro.cpp calls these directly).
    ${_VN_COMMON}/compat/compat_posix_string.c
    ${_VN_COMMON}/compat/compat_strcasestr.c
    ${_VN_COMMON}/compat/compat_strl.c
    ${_VN_COMMON}/compat/fopen_utf8.c
    ${_VN_COMMON}/encodings/encoding_utf.c
    ${_VN_COMMON}/file/file_path.c
    ${_VN_COMMON}/file/file_path_io.c
    ${_VN_COMMON}/streams/file_stream.c
    ${_VN_COMMON}/streams/file_stream_transforms.c
    ${_VN_COMMON}/string/stdstring.c
    ${_VN_COMMON}/time/rtime.c
    ${_VN_COMMON}/vfs/vfs_implementation.c
)
target_include_directories(core_vba_next PUBLIC
    ${_VN}/src
    ${_VN}/libretro
    ${_VN}/libretro-common/include
)
target_compile_definitions(core_vba_next PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    USE_FRAME_SKIP=1
    HAVE_HLE_BIOS=1
    FRONTEND_SUPPORTS_RGB565=1
    # vba-next's sources use `INLINE` as a return-type prefix on already
    # `static`-marked functions. Define it as just `inline` so we get
    # `inline static foo()` (legal) instead of `static inline static`
    # (duplicate 'static' error from libretro-common headers).
    INLINE=inline
)
target_compile_options(core_vba_next PRIVATE -w)
set_target_properties(core_vba_next PROPERTIES
    C_STANDARD                99
    C_STANDARD_REQUIRED       ON
    CXX_STANDARD              11
    CXX_STANDARD_REQUIRED     ON
    POSITION_INDEPENDENT_CODE ON)
