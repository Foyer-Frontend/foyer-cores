# recipes/ppsspp.cmake — libretro PPSSPP (PSP) on Switch.
#
# Note: the player binary's EGL context creation lives in foyer/shared/
# libretro/video_hw.cpp, not in this recipe. v0.3.1 picks up foyer's
# EGL_CONTEXT_CLIENT_VERSION 0 -> 2/3 coercion fix that finally lets
# PPSSPP boot past graphics init (Mesa was rejecting client version 0
# with EGL_BAD_MATCH).
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
# Auto-recurse off: tico-ppsspp has 30+ submodules pinned to specific
# SHAs — many of those SHAs aren't reachable through a shallow clone,
# so the default `git submodule update --init --recursive` fails on
# ffmpeg / libretro-common / etc. We init the subset we actually need
# manually below, with full-depth clones.
FetchContent_Declare(libretro_ppsspp
    GIT_REPOSITORY         https://github.com/ticohq/tico-ppsspp.git
    GIT_TAG                master
    GIT_SHALLOW            TRUE
    GIT_SUBMODULES_RECURSE FALSE
    GIT_SUBMODULES         ""
    # Once populated, don't re-run git's update step on subsequent
    # configures. The recipe replaces the auto-populated `ffmpeg/`
    # submodule reference with a symlink to tico-ppsspp-ffmpeg, and
    # git's submodule check rejects symlinks where it expects a real
    # checkout — so a re-update would fail with "expected submodule
    # path 'ffmpeg' not to be a symbolic link". Re-run cmake from
    # a clean build dir if you need to force a refresh.
    UPDATE_DISCONNECTED    TRUE)

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
# Init the submodules the libretro/libnx Makefile actually needs.
# Full-depth (no `--depth 1`) so the pinned SHAs are always reachable.
# A guard file keeps re-runs cheap once the initial clone is done.
# ---------------------------------------------------------------------------
set(_PSP_SUBMOD_GUARD ${_PSP}/.foyer-submodules-init)
if (NOT EXISTS ${_PSP_SUBMOD_GUARD})
    set(_PSP_SUBMODS
        ext/armips        ext/glslang       ext/SPIRV-Cross
        ext/cpu_features  ext/libchdr       ext/lua
        ext/zstd          ext/rcheevos      ext/freetype
        ext/naett         ext/nanosvg       ext/aemu_postoffice
        ext/miniupnp      ext/rapidjson
        libretro/libretro-common)
    message(STATUS "ppsspp: cloning required submodules (one-time, full depth)")
    execute_process(
        COMMAND git submodule update --init -- ${_PSP_SUBMODS}
        WORKING_DIRECTORY ${_PSP}
        RESULT_VARIABLE _sub_rc)
    if (NOT _sub_rc EQUAL 0)
        message(FATAL_ERROR
            "ppsspp: git submodule update failed (rc=${_sub_rc}). "
            "Run manually under ${_PSP} to inspect.")
    endif()
    file(WRITE ${_PSP_SUBMOD_GUARD} "ok\n")
endif()

# ---------------------------------------------------------------------------
# The Makefile expects ffmpeg/ at $(CORE_DIR)/ffmpeg with
# switch_build/{include,lib} populated. tico's ffmpeg repo IS that
# layout — symlink it into place. The auto-cloned submodule reference
# (if any) gets cleaned out first so we don't fight git over the
# directory.
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
# Source-list patches against Makefile.common.
#
# Idempotent — re-running cmake on an already patched tree is a no-op
# because the target string isn't present any more.
# ---------------------------------------------------------------------------

# 1) OpenXR. Common/VR/*.cpp pulls in <openxr/openxr.h> from the
#    ext/OpenXR-SDK submodule. We don't init that submodule (Switch
#    has no VR), but Makefile.common adds the VR .cpps to SOURCES_CXX
#    unconditionally and references them from the include path.
#    Wholesale-comment-out the VR block.
set(_PSP_MK_COMMON ${_PSP}/libretro/Makefile.common)
file(READ ${_PSP_MK_COMMON} _t)
string(REPLACE
    "SOURCES_CXX += \\\n\t$(COMMONDIR)/VR/OpenXRLoader.cpp \\\n\t$(COMMONDIR)/VR/PPSSPPVR.cpp \\\n\t$(COMMONDIR)/VR/VRBase.cpp \\\n\t$(COMMONDIR)/VR/VRMath.cpp \\\n\t$(COMMONDIR)/VR/VRFramebuffer.cpp \\\n\t$(COMMONDIR)/VR/VRInput.cpp \\\n\t$(COMMONDIR)/VR/VRRenderer.cpp"
    "# foyer: VR sources removed on libnx (ext/OpenXR-SDK not vendored)"
    _t "${_t}")
file(WRITE ${_PSP_MK_COMMON} "${_t}")

# 2) Lua's `-DLUA_C89_NUMBERS` in tico's PLATCFLAGS is set empty
#    AND luaconf.h unconditionally re-defines LUA_C89_NUMBERS based
#    on whether LUA_USE_C89 is defined. So passing LUA_C89_NUMBERS
#    on the command line (with any value) is a no-op — the file
#    overwrites it. Switch to defining LUA_USE_C89, which makes
#    luaconf.h pick the C89_NUMBERS=1 branch and route to the
#    INT_LONG type (long is 64-bit on aarch64 so this is fine).
set(_PSP_MK ${_PSP}/libretro/Makefile)
file(READ ${_PSP_MK} _t)
string(REPLACE
    "-DLUA_C89_NUMBERS"
    "-DLUA_USE_C89"
    _t "${_t}")
file(WRITE ${_PSP_MK} "${_t}")

# 2b) Force the GLES2 backend on libnx instead of the desktop-OpenGL
#     one tico's Makefile builds by default. The tail of Makefile has
#       ifeq ($(GLES), 1)
#         GLFLAGS += -DGLES -DUSING_GLES2
#       else
#         GLFLAGS += -DHAVE_OPENGL
#       endif
#     and the libnx block doesn't set GLES, so PPSSPP picks
#     `RETRO_HW_CONTEXT_OPENGL` and our HwContext (GLES3-only) rejects
#     it — pushing PPSSPP into SoftGPU which is unusably slow + has
#     game-specific bugs. Pin GLES=1 inside the libnx block so the
#     well-tested mobile GLES2 backend gets compiled instead. PPSSPP
#     then asks for `RETRO_HW_CONTEXT_OPENGLES2` which our existing
#     EGL/GLES3 context already accepts.
#
#     Gated on a marker so we only wipe stale .o files the FIRST time
#     this patch lands — re-running cmake afterwards is a no-op.
set(_PSP_GLES_MARKER ${_PSP}/.foyer-gles2-patched)
if (NOT EXISTS ${_PSP_GLES_MARKER})
    message(STATUS "ppsspp: switching libnx build to GLES2 (one-time rebuild)")
    file(READ ${_PSP_MK} _t)
    string(REPLACE
        "TARGET := $(TARGET_NAME)_libretro_$(platform).a"
        "TARGET := $(TARGET_NAME)_libretro_$(platform).a\n   GLES = 1"
        _t "${_t}")
    file(WRITE ${_PSP_MK} "${_t}")
    # Compiler flags can't drift between objects — purge anything stale
    # and let make re-build every TU under the new flags. .a too, so
    # the link step re-runs.
    file(GLOB_RECURSE _PSP_STALE_OBJS ${_PSP}/*.o)
    if (_PSP_STALE_OBJS)
        file(REMOVE ${_PSP_STALE_OBJS})
    endif()
    file(REMOVE ${_PSP}/libretro/ppsspp_libretro_libnx.a)
    file(WRITE ${_PSP_GLES_MARKER} "ok\n")
endif()

# 3) cpu_features/src/hwcaps.c: detects platform via per-OS branches
#    and #errors when none match. libnx isn't on the list, so the
#    file fails to compile. Drop it from SOURCES_C — the per-arch
#    impl_*_linux.c files compile to empty TUs on Switch (their
#    contents are gated behind CPU_FEATURES_OS_LINUX_OR_ANDROID),
#    so excluding hwcaps.c is enough on its own.
file(READ ${_PSP_MK_COMMON} _t)
string(REPLACE
    "ifneq ($(PLATFORM_EXT), win32)\nSOURCES_C += \\\n\t$(EXTDIR)/cpu_features/src/hwcaps.c\nendif"
    "# foyer: hwcaps.c excluded on libnx (no aarch64-libnx support upstream)"
    _t "${_t}")
file(WRITE ${_PSP_MK_COMMON} "${_t}")

# 3b-pre) Earlier iterations of this recipe excluded gl3stub.c from
#     SOURCES_C entirely. Now that we replace its body with a minimal
#     Switch-specific version (just below), it has to be back in the
#     compile list. Idempotent — on a fresh checkout the REPLACE
#     pattern doesn't match and this is a no-op.
file(READ ${_PSP_MK_COMMON} _t)
string(REPLACE
    "SOURCES_C +=\\\n\t$(COMMONDIR)/Math/fast/fast_matrix.c\n# foyer: gl3stub.c removed on libnx (collides with libGLESv2)"
    "SOURCES_C +=\\\n\t$(COMMONDIR)/GPU/OpenGL/gl3stub.c \\\n\t$(COMMONDIR)/Math/fast/fast_matrix.c"
    _t "${_t}")
file(WRITE ${_PSP_MK_COMMON} "${_t}")

# 3b) gl3stub.c: PPSSPP ships a stub file under
#     Common/GPU/OpenGL/gl3stub.c that defines GLES3 standard symbols
#     as function-pointer globals + a gl3stubInit() that fills them
#     via eglGetProcAddress. The whole file is gated on USING_GLES2
#     — designed for systems whose GLES2 system header doesn't expose
#     GLES3 entry points.
#
#     Switch's libGLESv2 from devkitPro portlibs already exports the
#     real GLES3 functions (glVertexAttribIPointer, glWaitSync, the
#     uniform/buffer/sampler/sync set, ...). Keeping gl3stub.c as-is
#     gives the linker two definitions of every standard symbol and
#     it errors out:
#         multiple definition of `glVertexAttribIPointer'
#         multiple definition of `glWaitSync'
#
#     Replace gl3stub.c with a Switch-specific minimal version: only
#     the EXT/OES extensions PPSSPP uses (glBindFragDataLocation-
#     IndexedEXT, glCopyImageSubDataOES) — which libGLESv2 does NOT
#     export — plus gl3stubInit() so callers like GLFeatures.cpp
#     still link. Standard GLES3 calls come straight from libGLESv2.
file(WRITE ${_PSP}/Common/GPU/OpenGL/gl3stub.c
"// Auto-generated by foyer-cores ppsspp recipe (libnx).
// Upstream gl3stub.c collides with devkitPro's libGLESv2, which
// already exports every standard GLES3 symbol. This Switch version
// drops those and only declares the six EXT/OES function pointers
// gl3stub.h promises — gl3stubInit() runtime-loads them via
// eglGetProcAddress. PPSSPP keeps calling them by their declared
// names; standard GLES3 calls fall through to libGLESv2 directly.

#include \"ppsspp_config.h\"
#include \"Common/GPU/OpenGL/GLCommon.h\"

#if defined(USING_GLES2)
#include <EGL/egl.h>

GL_APICALL void (* GL_APIENTRY glBindFragDataLocationIndexedEXT)(
    GLuint program, GLuint colorNumber, GLuint index, const GLchar *name) = 0;
GL_APICALL void (* GL_APIENTRY glBindFragDataLocationEXT)(
    GLuint program, GLuint color, const GLchar *name) = 0;
GL_APICALL GLint (* GL_APIENTRY glGetProgramResourceLocationIndexEXT)(
    GLuint program, GLenum programInterface, const GLchar *name) = 0;
GL_APICALL GLint (* GL_APIENTRY glGetFragDataIndexEXT)(
    GLuint program, const GLchar *name) = 0;
GL_APICALL void (* GL_APIENTRY glBufferStorageEXT)(
    GLenum target, GLsizeiptr size, const void *data, GLbitfield flags) = 0;
GL_APICALL void (* GL_APIENTRY glCopyImageSubDataOES)(
    GLuint srcName, GLenum srcTarget, GLint srcLevel,
    GLint srcX, GLint srcY, GLint srcZ,
    GLuint dstName, GLenum dstTarget, GLint dstLevel,
    GLint dstX, GLint dstY, GLint dstZ,
    GLsizei width, GLsizei height, GLsizei depth) = 0;

GLboolean gl3stubInit(void) {
#define FIND(s) s = (void *)eglGetProcAddress(#s)
    FIND(glBindFragDataLocationIndexedEXT);
    FIND(glBindFragDataLocationEXT);
    FIND(glGetProgramResourceLocationIndexEXT);
    FIND(glGetFragDataIndexEXT);
    FIND(glBufferStorageEXT);
    FIND(glCopyImageSubDataOES);
#undef FIND
    return GL_TRUE;
}
#endif
")

# 4) tico's Makefile.common compiles the rcheevos rc_client API but
#    *without* RC_CLIENT_SUPPORTS_HASH, which is the macro that gates
#    rc_client_begin_identify_and_load_game(). foyer's shared
#    cheevos.cpp uses that entry point (we let rcheevos hash the rom
#    for us instead of reimplementing per-system hashing). Define the
#    macro and pull in the rhash sources required to satisfy it.
#
#    The added rhash files only depend on rc_compat / standard headers
#    on Switch (they don't pull in libchdr or zlib at compile time),
#    so the existing include flags are sufficient.
file(READ ${_PSP_MK_COMMON} _t)
string(REPLACE
    "COREFLAGS += -DRC_DISABLE_LUA"
    "COREFLAGS += -DRC_DISABLE_LUA -DRC_CLIENT_SUPPORTS_HASH=1"
    _t "${_t}")
string(REPLACE
    "$(EXTDIR)/rcheevos/src/rhash/md5.c"
    "$(EXTDIR)/rcheevos/src/rhash/md5.c \\\n\t$(EXTDIR)/rcheevos/src/rhash/hash.c \\\n\t$(EXTDIR)/rcheevos/src/rhash/hash_disc.c \\\n\t$(EXTDIR)/rcheevos/src/rhash/hash_encrypted.c \\\n\t$(EXTDIR)/rcheevos/src/rhash/hash_rom.c \\\n\t$(EXTDIR)/rcheevos/src/rhash/hash_zip.c \\\n\t$(EXTDIR)/rcheevos/src/rhash/cdreader.c \\\n\t$(EXTDIR)/rcheevos/src/rhash/aes.c"
    _t "${_t}")
file(WRITE ${_PSP_MK_COMMON} "${_t}")

# 5) LibretroSoftwareContext::SwapBuffers immediately dereferences
#    PPSSPP's global `gpuDebug` pointer. On Switch, retro_run fires
#    its first frame (and therefore the first SwapBuffers) before
#    PSP_Init / GPU_Init have finished wiring up the SoftGPU
#    backend — gpuDebug is still nullptr, the call data-aborts at
#    address 0 and atmosphère writes a crash report
#    (foyer-ppsspp + 0x1161e8 = LibretroGraphicsContext.h:79).
#    Add a guard so early swaps fall through silently until the GPU
#    is ready. Once gpuDebug is non-null the original body runs as
#    written.
set(_PSP_LRGC ${_PSP}/libretro/LibretroGraphicsContext.h)
file(READ ${_PSP_LRGC} _t)
string(REPLACE
    "void SwapBuffers() override {\n\t\tGPUDebugBuffer buf;\n\t\tu16 w = NATIVEWIDTH;"
    "void SwapBuffers() override {\n\t\tif (!gpuDebug) return; // foyer: GPU not yet up\n\t\tGPUDebugBuffer buf;\n\t\tu16 w = NATIVEWIDTH;"
    _t "${_t}")
file(WRITE ${_PSP_LRGC} "${_t}")

# 6) aemu_postoffice/client/sock_impl.h gates <netinet/in.h> behind
#    `__unix || __APPLE__ || __PSP__`. Switch (`__SWITCH__`) isn't
#    on the list, so struct sockaddr_in / _in6 stay incomplete and
#    postoffice.c fails to compile its sizeof(...) sites. Add Switch
#    to the unix branch — devkitPro's newlib provides the headers.
set(_PSP_SOCK_IMPL ${_PSP}/ext/aemu_postoffice/client/sock_impl.h)
file(READ ${_PSP_SOCK_IMPL} _t)
string(REPLACE
    "#if defined(__unix) || defined(__APPLE__) || defined(__PSP__)"
    "#if defined(__unix) || defined(__APPLE__) || defined(__PSP__) || defined(__SWITCH__)"
    _t "${_t}")
file(WRITE ${_PSP_SOCK_IMPL} "${_t}")

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

# ---------------------------------------------------------------------------
# VR stubs — Common/VR/*.cpp is excluded from the libretro .a (their
# OpenXR dep doesn't ship on Switch), but other PPSSPP TUs still
# call into IsVREnabled() and friends. Compile a small stubs TU that
# returns false / no-op for every entry so the linker is happy and
# the runtime VR path is dead-code.
# ---------------------------------------------------------------------------
add_library(ppsspp_vr_stubs STATIC
    ${CMAKE_CURRENT_LIST_DIR}/ppsspp_vr_stubs.cpp
)
target_compile_features(ppsspp_vr_stubs PRIVATE cxx_std_17)
set_target_properties(ppsspp_vr_stubs PROPERTIES POSITION_INDEPENDENT_CODE ON)
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

# tico-ppsspp's libretro Makefile compiles ext/rcheevos into the
# libretro .a directly. Tell foyer's player CMakeLists to skip its own
# rcheevos static lib (which would collide on the rc_client_* symbols)
# and just propagate the headers via rcheevos_headers.
set(FOYER_CORE_EMBEDS_RCHEEVOS TRUE)

# ---------------------------------------------------------------------------
# PPSSPP needs its `assets/` tree at the libretro system directory at
# runtime — `ppge_atlas.zim`, the `flash0/` PSP fonts, every `lang/`
# .ini, `compat.ini`, `gamecontrollerdb.txt`, etc. tico's libretro
# init reads `<system_dir>/compat.ini` first and warns "Core system
# files missing, expect bugs" when it isn't found, then crashes
# downstream when the missing assets are actually accessed (see
# `[SCEGE] Failed to load ppge_atlas.zim`).
#
# Stage the assets into the player's romfs source dir so
# dkp_add_asset_target bakes them into foyer-ppsspp.nro. The player's
# main.cpp seeds them onto SD at /foyer/system/ppsspp/ on first boot
# and points the libretro system_directory there.
# ---------------------------------------------------------------------------
set(_PSP_ROMFS_DST ${CMAKE_CURRENT_BINARY_DIR}/romfs/ppsspp_assets)
file(MAKE_DIRECTORY ${_PSP_ROMFS_DST})
# Trailing `/.` copies the *contents* of assets/, not the assets/ dir
# itself, so the romfs layout is romfs:/ppsspp_assets/<file> rather
# than romfs:/ppsspp_assets/assets/<file>.
file(COPY ${_PSP}/assets/. DESTINATION ${_PSP_ROMFS_DST})

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
# Order matters for GNU ld: ppsspp.a / ffmpeg / vr-stubs / glad have
# circular cross-references (libpng calls into zlib's deflate, ffmpeg
# calls into zlib's uncompress, etc.). Wrap the lot in
# --start-group / --end-group so ld iterates until every symbol is
# resolved instead of giving up on the first pass.
# NOTE about zlib: foyer_shared already publicly links ZLIB::ZLIB, so by
# the time CMake builds the player binary's link line, libz.a has been
# emitted *before* --start-group. CMake then de-dupes any second
# occurrence (whether `ZLIB::ZLIB` or the absolute path), which means
# the group itself sees no libz.a — leaving libpng17/libzip/SymbolMap/
# id3v2 unresolved (deflate/gzopen/uncompress).
#
# Forcing `-lz` (a different *string token* from the absolute path
# CMake emitted earlier) sidesteps the dedupe and lands a second copy
# of libz.a *inside* the group, where it can satisfy the cross-archive
# references. The dedup pass compares strings, not search results.
target_link_libraries(core_ppsspp INTERFACE
    -Wl,--start-group
    ${_PSP_LIBA}
    ppsspp_vr_stubs
    ppsspp_ffmpeg_avformat
    ppsspp_ffmpeg_avcodec
    ppsspp_ffmpeg_swresample
    ppsspp_ffmpeg_swscale
    ppsspp_ffmpeg_avutil
    ppsspp_glad
    -lz
    -Wl,--end-group
)
target_compile_definitions(core_ppsspp INTERFACE
    HAVE_PPSSPP=1
)
