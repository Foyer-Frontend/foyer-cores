# recipes/parallel_n64.cmake — libretro parallel-n64 (N64 with
# per-game widescreen / 16:9 patches). Alternative to mupen64plus.
#
# Why ship two N64 cores: mupen64plus (we already ship) covers
# general-purpose N64 emulation with GLideN64's widescreen mode;
# parallel-n64 carries a separate curated database of per-game
# widescreen hacks (different framebuffer aspect, FOV changes, HUD
# patches) that some titles need to look right on a 16:9 panel.
# paraLLEl-RDP — the headline Vulkan renderer — is unavailable on
# Switch (no Vulkan), so on this platform we use the Rice GLES
# backend (HAVE_RICE=1) against the HW render callback.
#
# DEFERRED (not in matrix): authoring the source list is a focused
# multi-hour job — Makefile.common pulls from mupen64plus-core/src
# (~67 .c files), gles2rice/src (~31 .cpp), mupen64plus-rsp-hle/src
# (~14 .c), libretro-common, plus the libretro frontend bridge and
# the aarch64 dynarec linkage stub. The HW callback infrastructure
# this core would consume is already shipping in foyer/v0.2.x — when
# someone takes a focused day on the recipe, the runtime side is
# ready.
#
# Defines + include dirs below are correct for a HAVE_RICE=1 +
# WITH_DYNAREC=aarch64 build; only the SOURCES list is the open
# work item.

include(FetchContent)

FetchContent_Declare(libretro_parallel_n64
    GIT_REPOSITORY https://github.com/libretro/parallel-n64.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_parallel_n64)

set(_PN64       ${libretro_parallel_n64_SOURCE_DIR})
set(_PN64_CORE  ${_PN64}/mupen64plus-core)
set(_PN64_RICE  ${_PN64}/gles2rice)
set(_PN64_HLE   ${_PN64}/mupen64plus-rsp-hle)
set(_PN64_LR    ${_PN64}/libretro-common)

# TODO: SOURCES list. See Makefile.common ifeq ($(HAVE_RICE),1) block
# + the unconditional mupen64plus-core / mupen64plus-rsp-hle /
# libretro-common / libretro/{libretro,brumme_crc,libretro_crc}.{c,cpp}
# entries, plus arm64 dynarec linkage at
#   $(CORE_DIR)/src/r4300/new_dynarec/arm64/linkage_aarch64.S
# Worth ~3-4 hours of careful Makefile mirroring.

# Defines mirror the libnx-style targets in upstream Makefile, with
# HAVE_RICE forcing the GLES Rice path (no Vulkan parallel-RDP on
# Switch — switch-mesa portlibs ship GLES3 only).
set(_PN64_DEFINES
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
    NEW_DYNAREC=4
    PIC=1
    USE_GLES=1
    GLES2=1
    OS_LINUX=1
    NO_ASM=1
    FRONTEND_SUPPORTS_RGB565=1
)

set(_PN64_INCLUDE_DIRS
    ${_PN64}
    ${_PN64}/libretro
    ${_PN64_CORE}/src
    ${_PN64_CORE}/src/api
    ${_PN64_CORE}/src/r4300
    ${_PN64_CORE}/src/r4300/new_dynarec
    ${_PN64_RICE}/src
    ${_PN64_HLE}/src
    ${_PN64_LR}/include
    $ENV{DEVKITPRO}/portlibs/switch/include
)

# Recipe stub — uncomment + populate when ready to commit to authoring.
# add_library(core_parallel_n64 STATIC ${_PN64_SOURCES})
# target_include_directories(core_parallel_n64 PUBLIC ${_PN64_INCLUDE_DIRS})
# target_compile_definitions(core_parallel_n64 PRIVATE ${_PN64_DEFINES})
# target_compile_options(core_parallel_n64 PRIVATE -w -fno-strict-aliasing)
# set_target_properties(core_parallel_n64 PROPERTIES
#     C_STANDARD 99 CXX_STANDARD 11 POSITION_INDEPENDENT_CODE ON)

message(WARNING "parallel_n64 recipe is a stub — see recipes/parallel_n64.cmake header")
