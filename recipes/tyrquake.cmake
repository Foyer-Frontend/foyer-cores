# cores/tyrquake.cmake — libretro tyrquake (Quake 1) core build.
#
# Self-contained: source list mirrors upstream Makefile.common's libnx
# target, which sets STATIC_LINKING=1 (so the libretro-common subset is
# skipped — the surrounding foyer player binary already provides those
# helpers via the rest of the static link).
#
# Networking + audio codecs are stripped to keep the .nro lean:
#   - HAVE_NETWORKING off → net_none.c only (skip net_udp/net_dgrm/
#     net_bsd which would try to pull in BSD sockets from libnx)
#   - codec defines off    → no FLAC / Vorbis / MP3 / etc.; soundtrack
#                            files won't decode but in-game effects
#                            (the .wav-based mixer in snd_dma.c) still
#                            play.

include(FetchContent)

FetchContent_Declare(libretro_tyrquake
    GIT_REPOSITORY https://github.com/libretro/tyrquake.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_tyrquake)

set(_TQ      ${libretro_tyrquake_SOURCE_DIR})
set(_TQ_COM  ${_TQ}/common)
set(_TQ_LRC  ${_TQ}/libretro-common)

# Despite upstream setting STATIC_LINKING=1 for libnx (which skips the
# libretro-common helpers in their Makefile.common), our static link
# does NOT supply those symbols — the player binary links against
# libretro-common via the rcheevos target only, and that doesn't
# expose rfread/rfgetc/strlcpy_retro__ etc. Compile the subset
# tyrquake actually references directly.
set(_TQ_LRC_C
    ${_TQ_LRC}/file/retro_dirent.c
    ${_TQ_LRC}/encodings/encoding_utf.c
    ${_TQ_LRC}/string/stdstring.c
    ${_TQ_LRC}/streams/file_stream.c
    ${_TQ_LRC}/streams/file_stream_transforms.c
    ${_TQ_LRC}/vfs/vfs_implementation.c
    ${_TQ_LRC}/file/file_path.c
    ${_TQ_LRC}/file/file_path_io.c
    ${_TQ_LRC}/features/features_cpu.c
    ${_TQ_LRC}/compat/fopen_utf8.c
    ${_TQ_LRC}/compat/compat_strl.c
    ${_TQ_LRC}/compat/compat_posix_string.c
    ${_TQ_LRC}/compat/compat_strcasestr.c
    ${_TQ_LRC}/compat/compat_snprintf.c
    ${_TQ_LRC}/time/rtime.c
)

set(_TQ_C
    ${_TQ_COM}/cl_input.c
    ${_TQ_COM}/cd_common.c
    ${_TQ_COM}/alias_model.c
    ${_TQ_COM}/chase.c
    ${_TQ_COM}/cl_demo.c
    ${_TQ_COM}/cl_main.c
    ${_TQ_COM}/cl_parse.c
    ${_TQ_COM}/cl_tent.c
    ${_TQ_COM}/common.c
    ${_TQ_COM}/cmd.c
    ${_TQ_COM}/crc.c
    ${_TQ_COM}/console.c
    ${_TQ_COM}/cvar.c
    ${_TQ_COM}/d_edge.c
    ${_TQ_COM}/d_init.c
    ${_TQ_COM}/d_part.c
    ${_TQ_COM}/d_modech.c
    ${_TQ_COM}/d_polyse.c
    ${_TQ_COM}/d_scan.c
    ${_TQ_COM}/d_sky.c
    ${_TQ_COM}/d_sprite.c
    ${_TQ_COM}/d_surf.c
    ${_TQ_COM}/d_vars.c
    ${_TQ_COM}/draw.c
    ${_TQ_COM}/host.c
    ${_TQ_COM}/host_cmd.c
    ${_TQ_COM}/keys.c
    ${_TQ_COM}/mathlib.c
    ${_TQ_COM}/menu.c
    ${_TQ_COM}/model.c
    ${_TQ_COM}/net_common.c
    ${_TQ_COM}/net_loop.c
    ${_TQ_COM}/net_main.c
    ${_TQ_COM}/net_none.c
    ${_TQ_COM}/pr_cmds.c
    ${_TQ_COM}/pr_exec.c
    ${_TQ_COM}/pr_edict.c
    ${_TQ_COM}/r_aclip.c
    ${_TQ_COM}/r_alias.c
    ${_TQ_COM}/r_bsp.c
    ${_TQ_COM}/r_draw.c
    ${_TQ_COM}/r_edge.c
    ${_TQ_COM}/r_efrag.c
    ${_TQ_COM}/r_light.c
    ${_TQ_COM}/r_main.c
    ${_TQ_COM}/r_misc.c
    ${_TQ_COM}/r_model.c
    ${_TQ_COM}/r_part.c
    ${_TQ_COM}/r_sky.c
    ${_TQ_COM}/r_sprite.c
    ${_TQ_COM}/r_subdiv.c
    ${_TQ_COM}/r_vars.c
    ${_TQ_COM}/r_surf.c
    ${_TQ_COM}/rb_tree.c
    ${_TQ_COM}/sbar.c
    ${_TQ_COM}/screen.c
    ${_TQ_COM}/shell.c
    ${_TQ_COM}/bgmusic.c
    ${_TQ_COM}/snd_codec.c
    ${_TQ_COM}/snd_flac.c
    ${_TQ_COM}/snd_mikmod.c
    ${_TQ_COM}/snd_modplug.c
    ${_TQ_COM}/snd_mp3.c
    ${_TQ_COM}/snd_mpg123.c
    ${_TQ_COM}/snd_opus.c
    ${_TQ_COM}/snd_umx.c
    ${_TQ_COM}/snd_vorbis.c
    ${_TQ_COM}/snd_wave.c
    ${_TQ_COM}/snd_dma.c
    ${_TQ_COM}/snd_mem.c
    ${_TQ_COM}/snd_mix.c
    ${_TQ_COM}/sprite_model.c
    ${_TQ_COM}/sv_main.c
    ${_TQ_COM}/sv_move.c
    ${_TQ_COM}/sv_phys.c
    ${_TQ_COM}/sv_user.c
    ${_TQ_COM}/libretro.c
    ${_TQ_COM}/view.c
    ${_TQ_COM}/wad.c
    ${_TQ_COM}/zone.c
    ${_TQ_COM}/world.c
)

add_library(core_tyrquake STATIC ${_TQ_C} ${_TQ_LRC_C})

target_include_directories(core_tyrquake PUBLIC
    ${_TQ}
    ${_TQ}/include
    ${_TQ}/libretro-common/include
)

target_compile_definitions(core_tyrquake PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    FRONTEND_SUPPORTS_RGB565=1
    NDEBUG=1
    # Keep STATIC_LINKING semantics for libretro-common skipping —
    # the player binary supplies those helpers through the rest of
    # the static link.
    STATIC_LINKING=1
    # Don't pull __linux__ paths in; upstream Makefile -U's both for
    # libnx, since libnx's libc looks Linux-shaped to autoconf-style
    # checks but isn't actually Linux at runtime.
)

target_compile_options(core_tyrquake PRIVATE
    -w
    -fno-strict-aliasing
    -U__linux__
    -U__linux
)

set_target_properties(core_tyrquake PROPERTIES
    C_STANDARD 11
    C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
