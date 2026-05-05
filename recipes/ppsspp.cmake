# recipes/ppsspp.cmake — libretro PPSSPP (PSP) on Switch.
#
# Upstream hrydgard/ppsspp's libretro Makefile has no `platform=libnx`
# target. ticohq/tico-ppsspp does — it's a fork that added the libnx
# build path plus a Switch-specific FFmpeg in ticohq/tico-ppsspp-ffmpeg.
# Both are GPL-2.0+ licensed; foyer-cores is GPL-compatible.
#
# Strategy:
#   1. FetchContent the tico-ppsspp source + the prebuilt tico-ppsspp-ffmpeg
#      static archives (avcodec / avformat / avutil / swresample / swscale).
#   2. Drop the ffmpeg tree into tico-ppsspp/ffmpeg/ where the Makefile
#      expects it (FFMPEGDIR=$(CORE_DIR)/ffmpeg, switch_build/{include,lib}
#      under that).
#   3. Run `make platform=libnx -j` in tico-ppsspp/libretro/ via a custom
#      build rule. The Makefile produces `ppsspp_libretro_libnx.a` —
#      a STATIC archive on the libnx target (STATIC_LINKING=1 ⇒ ar rcs).
#   4. Compile dep/glad/src/glad.c as a small static lib so the libretro
#      .a's gladLoadGL / glClear / etc. resolve at link time. The libnx
#      Makefile target sets USE_GLAD=1.
#   5. Expose `core_ppsspp` as an INTERFACE library that links the
#      libretro .a + glad + the five FFmpeg .a's. switch-mesa
#      (libGLESv2.a / libEGL.a) and pthread come from libnx itself —
#      foyer's player nro already pulls those.

include(FetchContent)
include(ExternalProject)

# ---------------------------------------------------------------------------
# Sources: tico's PPSSPP fork (with platform=libnx) + the prebuilt
# Switch FFmpeg static libs.
# ---------------------------------------------------------------------------
FetchContent_Declare(libretro_ppsspp
    GIT_REPOSITORY https://github.com/ticohq/tico-ppsspp.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)

FetchContent_Declare(libretro_ppsspp_ffmpeg
    GIT_REPOSITORY https://github.com/ticohq/tico-ppsspp-ffmpeg.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)

FetchContent_GetProperties(libretro_ppsspp)
if (NOT libretro_ppsspp_POPULATED)
    FetchContent_Populate(libretro_ppsspp)
endif()

FetchContent_GetProperties(libretro_ppsspp_ffmpeg)
if (NOT libretro_ppsspp_ffmpeg_POPULATED)
    FetchContent_Populate(libretro_ppsspp_ffmpeg)
endif()

set(_PSP    ${libretro_ppsspp_SOURCE_DIR})
set(_PSP_FF ${libretro_ppsspp_ffmpeg_SOURCE_DIR})

# ---------------------------------------------------------------------------
# The Makefile expects ffmpeg/ at $(CORE_DIR)/ffmpeg with
# switch_build/{include,lib} populated. tico's ffmpeg repo IS that
# layout — symlink it into place. (Re-run safe; failures imply the
# symlink already exists.)
# ---------------------------------------------------------------------------
if (NOT EXISTS ${_PSP}/ffmpeg/switch_build/lib/libavcodec.a)
    file(REMOVE_RECURSE ${_PSP}/ffmpeg)
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E create_symlink ${_PSP_FF} ${_PSP}/ffmpeg
        RESULT_VARIABLE _ln_rc)
    if (NOT _ln_rc EQUAL 0)
        message(FATAL_ERROR
            "ppsspp: failed to symlink ${_PSP_FF} -> ${_PSP}/ffmpeg "
            "(rc=${_ln_rc}). Check that the FetchContent populate step "
            "produced a complete tico-ppsspp-ffmpeg checkout.")
    endif()
endif()

# ---------------------------------------------------------------------------
# Drive `make platform=libnx` to produce ppsspp_libretro_libnx.a.
# We use a custom command tied to a custom target rather than
# add_custom_command(OUTPUT ...) so the build always runs at least
# once; the Makefile is incremental on its own and skips re-link when
# nothing changed.
# ---------------------------------------------------------------------------
set(_PSP_LIBA ${_PSP}/libretro/ppsspp_libretro_libnx.a)

# Re-run the make every configure so changes in tico's master propagate
# (cheap when nothing's stale; STATIC_LINKING=1 avoids re-link work
# when objects haven't changed).
include(ProcessorCount)
ProcessorCount(_PSP_NPROC)
if (NOT _PSP_NPROC GREATER 0)
    set(_PSP_NPROC 4)
endif()
add_custom_command(
    OUTPUT  ${_PSP_LIBA}
    COMMAND ${CMAKE_COMMAND} -E env
                DEVKITPRO=$ENV{DEVKITPRO}
                DEVKITA64=$ENV{DEVKITA64}
                PORTLIBS=$ENV{PORTLIBS}
                ${CMAKE_MAKE_PROGRAM} -C ${_PSP}/libretro
                    platform=libnx -j${_PSP_NPROC}
    WORKING_DIRECTORY ${_PSP}/libretro
    COMMENT "Building ppsspp_libretro_libnx.a via tico-ppsspp Makefile"
    VERBATIM)

add_custom_target(ppsspp_libretro_a_target
    DEPENDS ${_PSP_LIBA})

# ---------------------------------------------------------------------------
# glad — GL function loader. The libretro .a calls into gladLoadGL etc.
# tico's libnx Makefile target sets USE_GLAD=1 and includes glad.h from
# tico/glad/, but the *implementation* lives in dep/glad/src/glad.c
# and has to be linked into the final binary.
# ---------------------------------------------------------------------------
add_library(ppsspp_glad STATIC
    ${_PSP}/dep/glad/src/glad.c
)
target_include_directories(ppsspp_glad PUBLIC
    ${_PSP}/dep/glad/include
    ${_PSP}/tico/glad
)
target_compile_definitions(ppsspp_glad PUBLIC
    GLAD_GLAPI_EXPORT
    __SWITCH__=1
)
set_target_properties(ppsspp_glad PROPERTIES POSITION_INDEPENDENT_CODE ON)

# ---------------------------------------------------------------------------
# FFmpeg — five prebuilt static archives the libretro .a links against.
# ---------------------------------------------------------------------------
foreach(_lib avcodec avformat avutil swresample swscale)
    add_library(ppsspp_ffmpeg_${_lib} STATIC IMPORTED GLOBAL)
    set_target_properties(ppsspp_ffmpeg_${_lib} PROPERTIES
        IMPORTED_LOCATION ${_PSP_FF}/switch_build/lib/lib${_lib}.a)
endforeach()

# ---------------------------------------------------------------------------
# core_ppsspp — INTERFACE wrapper. The foyer player binary's
# target_link_libraries(... core_ppsspp) drags in all of the above in
# the right order.
#
# The libretro .a is referenced via `-l:` to force GNU ld to take the
# archive verbatim (don't search) and resolve symbols across the
# adjacent FFmpeg archives. order matters: ppsspp first, then ffmpeg
# (avcodec depends on avutil etc.).
# ---------------------------------------------------------------------------
add_library(core_ppsspp INTERFACE)
add_dependencies(core_ppsspp ppsspp_libretro_a_target)
target_link_libraries(core_ppsspp INTERFACE
    ${_PSP_LIBA}
    ppsspp_ffmpeg_avformat
    ppsspp_ffmpeg_avcodec
    ppsspp_ffmpeg_swresample
    ppsspp_ffmpeg_swscale
    ppsspp_ffmpeg_avutil
    ppsspp_glad
)
target_compile_definitions(core_ppsspp INTERFACE
    HAVE_PPSSPP=1
)
