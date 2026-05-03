# recipes/parallel_n64.cmake — libretro parallel-n64 (N64 with
# per-game widescreen / 16:9 patches). Alternative to mupen64plus.
#
# Why ship two N64 cores: parallel-n64 carries a separate curated
# database of per-game widescreen hacks (different framebuffer
# aspect, FOV changes, HUD patches) that some titles need to look
# right on a 16:9 panel — distinct from GLideN64's generic mode
# in mupen64plus.
#
# paraLLEl-RDP (the headline Vulkan renderer) is unavailable on
# Switch (no Vulkan), so this build uses the Rice GLES backend
# (HAVE_RICE=1) against foyer's HW render callback. RSP-HLE for
# the RSP.
#
# r4300 runs in pure-interpreter mode on Switch. parallel-n64's
# new_dynarec mmap()s a single VA expecting to flip W/X protections
# in place, but Horizon's libnx Jit only exposes a dual-mapped
# (rw_addr ≠ rx_addr) JIT region — the dynarec's stored function
# pointers would still point at the writable mapping. Patching that
# is a multi-day systems job, so we ship the interpreter and skip
# new_dynarec entirely. Slower but correct.
#
# libretro-common: parallel-n64 bundles an old vendored copy that
# lacks glsym_es3.h and the time/ helpers. We FetchContent a fresh
# upstream libretro-common and use IT for the .c files we compile,
# while still letting parallel-n64's own headers reference the
# bundled copy for ABI stability.

include(FetchContent)

FetchContent_Declare(libretro_parallel_n64
    GIT_REPOSITORY https://github.com/libretro/parallel-n64.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_parallel_n64)

# Fresh upstream libretro-common — supplies glsym_es3.h and the
# newer time/file/stream helpers that parallel-n64's bundled copy
# is missing. Used for the .c TUs we compile + as the higher-priority
# include dir.
FetchContent_Declare(libretro_common_pn64
    GIT_REPOSITORY https://github.com/libretro/libretro-common.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_common_pn64)

set(_PN64       ${libretro_parallel_n64_SOURCE_DIR})
set(_PN64_CORE  ${_PN64}/mupen64plus-core/src)
set(_PN64_RICE  ${_PN64}/gles2rice/src)
set(_PN64_HLE   ${_PN64}/mupen64plus-rsp-hle/src)
set(_PN64_AUDIO ${_PN64_CORE}/plugin/audio_libretro)
set(_PN64_LR    ${_PN64}/libretro)
set(_PN64_CC_OLD ${_PN64}/libretro-common)
set(_PN64_CC     ${libretro_common_pn64_SOURCE_DIR})

# Bulk-glob the source dirs whose contents are stable per-platform.
# Anything that needs gating (NEW_DYNAREC=4 vs empty stub, NO_ASM,
# specific NEON paths) is excluded after the glob.
file(GLOB _PN64_CORE_API   "${_PN64_CORE}/api/*.c")
file(GLOB _PN64_CORE_DD    "${_PN64_CORE}/dd/*.c")
file(GLOB _PN64_CORE_MAIN  "${_PN64_CORE}/main/*.c")
file(GLOB _PN64_CORE_MEM   "${_PN64_CORE}/memory/*.c")
file(GLOB _PN64_CORE_OSAL  "${_PN64_CORE}/osal/*.c")
file(GLOB _PN64_CORE_PI    "${_PN64_CORE}/pi/*.c")
file(GLOB _PN64_CORE_PIF   "${_PN64_CORE}/pifbootrom/*.c")
file(GLOB _PN64_CORE_PLUG  "${_PN64_CORE}/plugin/*.c")
file(GLOB _PN64_CORE_AI    "${_PN64_CORE}/ai/*.c")
file(GLOB _PN64_CORE_RDP   "${_PN64_CORE}/rdp/*.c")
file(GLOB _PN64_CORE_RI    "${_PN64_CORE}/ri/*.c")
file(GLOB _PN64_CORE_RSP   "${_PN64_CORE}/rsp/*.c")
file(GLOB _PN64_CORE_R4300 "${_PN64_CORE}/r4300/*.c")
file(GLOB _PN64_CORE_SI    "${_PN64_CORE}/si/*.c")
file(GLOB _PN64_CORE_VI    "${_PN64_CORE}/vi/*.c")
file(GLOB _PN64_CORE_GB    "${_PN64_CORE}/gb/*.c")
file(GLOB _PN64_AUDIO_C    "${_PN64_AUDIO}/*.c")
file(GLOB _PN64_HLE_C      "${_PN64_HLE}/*.c")
file(GLOB _PN64_RICE_CXX   "${_PN64_RICE}/*.cpp")
file(GLOB _PN64_RICE_C     "${_PN64_RICE}/*.c")
# parallel-n64's Graphics state machine (gSP/gDP/__RSP globals + GBI
# dispatchers). Required by Rice's RSP_Parser / FrameBuffer / etc.
file(GLOB _PN64_GFX_C      "${_PN64}/Graphics/RSP/*.c"
                           "${_PN64}/Graphics/RDP/*.c"
                           "${_PN64}/Graphics/HLE/*.c"
                           "${_PN64}/Graphics/3dmaths.c")
file(GLOB _PN64_GFX_CXX    "${_PN64}/Graphics/RSP/*.cpp"
                           "${_PN64}/Graphics/RDP/*.cpp"
                           "${_PN64}/Graphics/HLE/*.cpp")

# r4300: pure-interpreter on Switch. Keep both empty_dynarec.c and
# recomp.c — the latter provides init_block / free_block /
# recompile_block / no_compiled_jump used by cached_interp.c for AST
# caching (NOT for JIT execution; mmap-allocated blocks are written
# to as plain memory, never executed). recomp.c's <sys/mman.h>
# include resolves to the foyer shim in parallel_n64_shims/sys/.
# new_dynarec dir is fully out of scope (Switch can't host its
# mmap-with-W^X-flip scheme; see file header).
# Drop the api/debugger.c TU — references `struct device` /
# `breakpoint` types from debugger headers we don't compile.
list(FILTER _PN64_CORE_API   EXCLUDE REGEX ".*/debugger\\.c$")
# Patch plugin.c at configure time: drop the GFX_GLN64 / GFX_GLIDE64
# / GFX_PARALLEL cases and the unconditional DEFINE_GFX(angrylion) /
# DEFINE_GFX(parallel) so we only carry the Rice path. Upstream's
# selector references symbols from plugins (GLideN64, glide2gl, the
# Vulkan paraLLEl-RDP) that aren't compilable on Switch.
set(_PN64_PLUGIN_PATCHED ${CMAKE_CURRENT_BINARY_DIR}/parallel_n64_plugin_patched.c)
file(READ ${_PN64_CORE}/plugin/plugin.c _PN64_PLUGIN_SRC)
# Gate the angrylion + parallel DEFINE_GFX so they don't pull in
# unbuilt symbols. Rice's DEFINE_GFX is already gated on HAVE_RICE.
string(REPLACE "DEFINE_GFX(angrylion);" "/* DEFINE_GFX(angrylion); — disabled, foyer */" _PN64_PLUGIN_SRC "${_PN64_PLUGIN_SRC}")
# Drop the cases that reference unbuilt plugins. The default falls
# through to gfx_rice via our local edit below.
string(REGEX REPLACE "gfx = gfx_gln64;"     "gfx = gfx_rice; /* foyer */"      _PN64_PLUGIN_SRC "${_PN64_PLUGIN_SRC}")
string(REGEX REPLACE "gfx = gfx_glide64;"   "gfx = gfx_rice; /* foyer */"      _PN64_PLUGIN_SRC "${_PN64_PLUGIN_SRC}")
string(REGEX REPLACE "gfx = gfx_angrylion;" "gfx = gfx_rice; /* foyer */"      _PN64_PLUGIN_SRC "${_PN64_PLUGIN_SRC}")
string(REGEX REPLACE "gfx = gfx_parallel;"  "gfx = gfx_rice; /* foyer */"      _PN64_PLUGIN_SRC "${_PN64_PLUGIN_SRC}")
# RSP plugins we don't build either — only RSP-HLE is compiled.
string(REGEX REPLACE "rsp = rsp_cxd4;"        "rsp = rsp_hle; /* foyer */"     _PN64_PLUGIN_SRC "${_PN64_PLUGIN_SRC}")
string(REGEX REPLACE "rsp = rsp_parallelRSP;" "rsp = rsp_hle; /* foyer */"     _PN64_PLUGIN_SRC "${_PN64_PLUGIN_SRC}")
file(WRITE ${_PN64_PLUGIN_PATCHED} "${_PN64_PLUGIN_SRC}")
list(FILTER _PN64_CORE_PLUG  EXCLUDE REGEX ".*/plugin\\.c$")
list(APPEND _PN64_CORE_PLUG  ${_PN64_PLUGIN_PATCHED})

# Patch libretro.c the same way: remove call sites for plugins we
# don't ship (glide2gl ChangeSize/vbo_disable; rsp_cxd4 rsp_conf).
# These are dead code at runtime (gfx_plugin = GFX_RICE always) but
# the linker still needs the symbols. Easiest correct fix is to
# delete the call sites in the generated source.
set(_PN64_LIBRETRO_PATCHED ${CMAKE_CURRENT_BINARY_DIR}/parallel_n64_libretro_patched.c)
file(READ ${_PN64_LR}/libretro.c _PN64_LIBRETRO_SRC)
# Match calls only (not extern declarations) by anchoring to leading
# whitespace. Declarations all start at column 0 with `extern`.
string(REGEX REPLACE "(\n[ \t]+)ChangeSize\\(\\);"  "\\1(void)0; /* foyer: glide2gl unbuilt */" _PN64_LIBRETRO_SRC "${_PN64_LIBRETRO_SRC}")
string(REGEX REPLACE "(\n[ \t]+)vbo_disable\\(\\);" "\\1(void)0; /* foyer: glide2gl unbuilt */" _PN64_LIBRETRO_SRC "${_PN64_LIBRETRO_SRC}")
string(REGEX REPLACE "rsp_conf\\[[0-9]+\\][^;]*;"   "/* foyer: cxd4 unbuilt */;"                 _PN64_LIBRETRO_SRC "${_PN64_LIBRETRO_SRC}")
file(WRITE ${_PN64_LIBRETRO_PATCHED} "${_PN64_LIBRETRO_SRC}")

set(_PN64_CXX
    ${_PN64_RICE_CXX}
    ${_PN64_GFX_CXX}
)
set(_PN64_C
    ${_PN64_CORE_API} ${_PN64_CORE_DD} ${_PN64_CORE_MAIN}
    ${_PN64_CORE_MEM} ${_PN64_CORE_OSAL} ${_PN64_CORE_PI}
    ${_PN64_CORE_PIF} ${_PN64_CORE_PLUG} ${_PN64_CORE_AI}
    ${_PN64_CORE_RDP} ${_PN64_CORE_RI}  ${_PN64_CORE_RSP}
    ${_PN64_CORE_R4300} ${_PN64_CORE_SI} ${_PN64_CORE_VI}
    ${_PN64_CORE_GB}
    ${_PN64_AUDIO_C} ${_PN64_HLE_C}
    ${_PN64_RICE_C}
    ${_PN64_GFX_C}
    # Graphics-layer enum global (gfx_plugin) — set by libretro.c
    # rom-database lookup, read by plugin.c selector.
    ${_PN64}/Graphics/plugins.c
    # Libretro frontend bridge — patched copy strips call sites for
    # graphics/RSP plugins we don't ship (glide2gl, rsp-cxd4).
    ${_PN64_LIBRETRO_PATCHED}
    ${_PN64_LR}/libretro_crc.c
    ${_PN64_LR}/brumme_crc.c
    # libretro-common essentials. parallel-n64's bundled glsm.c needs
    # to win because the rest of parallel-n64 calls into THIS version's
    # API surface; everything else can come from upstream which has
    # the additional time/file helpers the bundled copy lacks.
    ${_PN64_CC_OLD}/glsm/glsm.c
    ${_PN64_CC}/libco/libco.c
    ${_PN64_CC}/streams/file_stream.c
    ${_PN64_CC}/string/stdstring.c
    ${_PN64_CC}/encodings/encoding_utf.c
    ${_PN64_CC}/file/file_path.c
    ${_PN64_CC}/file/file_path_io.c
    ${_PN64_CC}/file/retro_dirent.c
    ${_PN64_CC}/time/rtime.c
    ${_PN64_CC}/compat/compat_strl.c
    ${_PN64_CC}/compat/compat_posix_string.c
    ${_PN64_CC}/compat/compat_strcasestr.c
    ${_PN64_CC}/compat/fopen_utf8.c
    ${_PN64_CC}/compat/compat_snprintf.c
    ${_PN64_CC}/vfs/vfs_implementation.c
    # Audio resampler + s16/float conversion (audio_backend_libretro
    # in mupen64plus-core uses these directly).
    ${_PN64_CC}/audio/resampler/audio_resampler.c
    ${_PN64_CC}/audio/resampler/drivers/nearest_resampler.c
    ${_PN64_CC}/audio/resampler/drivers/sinc_resampler.c
    ${_PN64_CC}/audio/conversion/s16_to_float.c
    ${_PN64_CC}/audio/conversion/float_to_s16.c
    # Plugin-list registrar that the resampler uses to enumerate
    # available drivers (sinc/nearest).
    ${_PN64_CC}/lists/string_list.c
    # cpu feature detection (NEON / etc) used by resampler driver pick.
    ${_PN64_CC}/features/features_cpu.c
    # Aligned alloc — sinc resampler taps need 16/32-byte alignment.
    ${_PN64_CC}/memmap/memalign.c
    # CRC32 helper used by r4300 TLBWrite for translation cache keys.
    ${_PN64_CC}/encodings/encoding_crc32.c
    # Config-file userdata — resampler driver_class hook.
    ${_PN64_CC}/file/config_file.c
    ${_PN64_CC}/file/config_file_userdata.c
    # Stubs for desktop-GL extensions that glsm.c references but
    # Switch Mesa doesn't expose — calls are gated by extension
    # detection so they never fire at runtime. Shared with the
    # mednafen_psx_hw recipe.
    ${CMAKE_CURRENT_LIST_DIR}/libretro_glsm_stubs.c
    # extern-inline definitions for safe_rdram.h's helpers (C99
    # inline doesn't auto-emit external bodies — see file header).
    ${CMAKE_CURRENT_LIST_DIR}/parallel_n64_safe_rdram.c
)

add_library(core_parallel_n64 STATIC ${_PN64_CXX} ${_PN64_C})
target_include_directories(core_parallel_n64 PUBLIC
    # Foyer's shared glsm shim wins over both libretro-common copies
    # — it forwards `glsym/glsym.h` directly to Switch Mesa's GLES3
    # headers rather than going through rglgen's function-pointer
    # indirection. Also supplies a malloc-backed sys/mman.h.
    ${CMAKE_CURRENT_LIST_DIR}/libretro_glsm_shims
    # Fresh upstream libretro-common second — supplies the newer
    # time/file/stream prototypes the bundled copy is missing.
    ${_PN64_CC}/include
    ${_PN64}
    ${_PN64}/libretro
    ${_PN64}/include
    ${_PN64_CORE}
    ${_PN64_CORE}/api
    ${_PN64_CORE}/r4300
    ${_PN64_CORE}/plugin
    ${_PN64}/Graphics
    ${_PN64}/Graphics/RSP
    ${_PN64}/Graphics/RDP
    ${_PN64}/Graphics/HLE
    ${_PN64_RICE}
    ${_PN64_HLE}
    ${_PN64_AUDIO}
    # Bundled libretro-common last (parallel-n64's own glsm.c +
    # internal headers expect this layout for ABI continuity).
    ${_PN64_CC_OLD}/include
    $ENV{DEVKITPRO}/portlibs/switch/include
)
target_compile_definitions(core_parallel_n64 PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    LSB_FIRST=1
    INLINE=inline
    HAVE_RICE=1
    HAVE_OPENGL=1
    HAVE_OPENGLES=1
    HAVE_OPENGLES3=1
    M64P_PLUGIN_API=1
    M64P_CORE_PROTOTYPES=1
    PIC=1
    USE_GLES=1
    GLES3=1
    OS_LINUX=1
    NO_ASM=1
    FRONTEND_SUPPORTS_RGB565=1
)
target_compile_options(core_parallel_n64 PRIVATE
    -w -fno-strict-aliasing
    # Force-include the GLclampd shim so glsmsym.h compiles under
    # Switch's GLES headers. SHELL: keeps the two flags paired —
    # CMake otherwise dedups consecutive -include occurrences.
    "SHELL:-include ${CMAKE_CURRENT_LIST_DIR}/parallel_n64_compat.h"
)
set_target_properties(core_parallel_n64 PROPERTIES
    C_STANDARD 99 C_STANDARD_REQUIRED ON
    CXX_STANDARD 11 CXX_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON)
