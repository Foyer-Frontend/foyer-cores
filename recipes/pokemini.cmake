# cores/pokemini.cmake — libretro PokeMini (Pokemon Mini).

include(FetchContent)

FetchContent_Declare(libretro_pokemini
    GIT_REPOSITORY https://github.com/libretro/pokemini.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_pokemini)

set(_PM    ${libretro_pokemini_SOURCE_DIR})
set(_PM_LR ${_PM}/libretro/libretro-common)

add_library(core_pokemini STATIC
    ${_PM}/freebios/freebios.c
    ${_PM}/source/CommandLine.c
    ${_PM}/source/Hardware.c
    ${_PM}/source/Joystick.c
    ${_PM}/source/MinxAudio.c
    ${_PM}/source/MinxColorPRC.c
    ${_PM}/source/MinxCPU_CE.c
    ${_PM}/source/MinxCPU_CF.c
    ${_PM}/source/MinxCPU_SP.c
    ${_PM}/source/MinxCPU_XX.c
    ${_PM}/source/MinxCPU.c
    ${_PM}/source/MinxIO.c
    ${_PM}/source/MinxIRQ.c
    ${_PM}/source/MinxLCD.c
    ${_PM}/source/MinxPRC.c
    ${_PM}/source/MinxTimers.c
    ${_PM}/source/Multicart.c
    ${_PM}/source/PMCommon.c
    ${_PM}/source/PokeMini.c
    ${_PM}/source/Video_x1.c
    ${_PM}/source/Video_x2.c
    ${_PM}/source/Video_x3.c
    ${_PM}/source/Video_x4.c
    ${_PM}/source/Video_x5.c
    ${_PM}/source/Video_x6.c
    ${_PM}/source/Video_x7.c
    ${_PM}/source/Video.c
    ${_PM}/resource/PokeMini_ColorPal.c
    ${_PM}/libretro/libretro.c
    # libretro-common (upstream gates these on STATIC_LINKING != 1
    # but our player binary doesn't supply them either).
    ${_PM_LR}/compat/compat_posix_string.c
    ${_PM_LR}/compat/compat_snprintf.c
    ${_PM_LR}/compat/compat_strcasestr.c
    ${_PM_LR}/compat/compat_strl.c
    ${_PM_LR}/compat/fopen_utf8.c
    ${_PM_LR}/encodings/encoding_utf.c
    ${_PM_LR}/file/file_path.c
    ${_PM_LR}/file/file_path_io.c
    ${_PM_LR}/streams/file_stream.c
    ${_PM_LR}/streams/file_stream_transforms.c
    ${_PM_LR}/streams/memory_stream.c
    ${_PM_LR}/string/stdstring.c
    ${_PM_LR}/time/rtime.c
    ${_PM_LR}/vfs/vfs_implementation.c
)

target_include_directories(core_pokemini PUBLIC
    ${_PM}/libretro
    ${_PM_LR}/include
    ${_PM}/source
    ${_PM}/resource
    ${_PM}/freebios
)

target_compile_definitions(core_pokemini PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_pokemini PRIVATE -w -fno-strict-aliasing -U__linux__ -U__linux)

set_target_properties(core_pokemini PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
