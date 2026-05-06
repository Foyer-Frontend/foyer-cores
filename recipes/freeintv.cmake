# cores/freeintv.cmake — libretro FreeIntv (Mattel Intellivision).

include(FetchContent)

FetchContent_Declare(libretro_freeintv
    GIT_REPOSITORY https://github.com/libretro/freeintv.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_freeintv)

set(_FI    ${libretro_freeintv_SOURCE_DIR})
set(_FI_S  ${_FI}/src)
# libretro-common lives under src/deps in this repo (not at repo root).
set(_FI_LR ${_FI_S}/deps/libretro-common)

add_library(core_freeintv STATIC
    ${_FI_S}/libretro.c
    ${_FI_S}/intv.c
    ${_FI_S}/memory.c
    ${_FI_S}/cp1610.c
    ${_FI_S}/cart.c
    ${_FI_S}/controller.c
    ${_FI_S}/osd.c
    ${_FI_S}/ivoice.c
    ${_FI_S}/psg.c
    ${_FI_S}/stic.c
    ${_FI_S}/stb_image_impl.c
    # libretro-common (upstream gates these on STATIC_LINKING != 1
    # but our player binary doesn't supply them either).
    ${_FI_LR}/file/file_path.c
    ${_FI_LR}/compat/compat_posix_string.c
    ${_FI_LR}/compat/compat_snprintf.c
    ${_FI_LR}/compat/compat_strl.c
    ${_FI_LR}/compat/compat_strcasestr.c
    ${_FI_LR}/compat/fopen_utf8.c
    ${_FI_LR}/encodings/encoding_utf.c
    ${_FI_LR}/string/stdstring.c
    ${_FI_LR}/time/rtime.c
)

target_include_directories(core_freeintv PUBLIC
    ${_FI_S}
    ${_FI_LR}/include
)

target_compile_definitions(core_freeintv PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_freeintv PRIVATE -w -fno-strict-aliasing -U__linux__ -U__linux)

set_target_properties(core_freeintv PROPERTIES
    C_STANDARD 99
    C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
