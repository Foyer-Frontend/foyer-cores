# cores/nxengine.cmake — libretro NXEngine (Cave Story).

include(FetchContent)

FetchContent_Declare(libretro_nxengine
    GIT_REPOSITORY https://github.com/libretro/nxengine-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_nxengine)

set(_NX     ${libretro_nxengine_SOURCE_DIR}/nxengine)
set(_NX_LR  ${_NX}/libretro/libretro-common)
set(_NX_X   ${_NX}/extract-auto)

add_library(core_nxengine STATIC
    # Bundled SDL shim
    ${_NX}/sdl/SDL_error.c
    ${_NX}/sdl/file/SDL_rwops.c
    ${_NX}/sdl/video/SDL_blit.c
    ${_NX}/sdl/video/SDL_blit_0.c
    ${_NX}/sdl/video/SDL_blit_1.c
    ${_NX}/sdl/video/SDL_blit_A.c
    ${_NX}/sdl/video/SDL_blit_N.c
    ${_NX}/sdl/video/SDL_bmp.c
    ${_NX}/sdl/video/SDL_pixels.c
    ${_NX}/sdl/video/SDL_surface.c
    # libretro-common
    ${_NX_LR}/streams/file_stream.c
    ${_NX_LR}/streams/file_stream_transforms.c
    ${_NX_LR}/compat/fopen_utf8.c
    ${_NX_LR}/file/file_path.c
    ${_NX_LR}/file/file_path_io.c
    ${_NX_LR}/encodings/encoding_utf.c
    ${_NX_LR}/compat/compat_strl.c
    ${_NX_LR}/compat/compat_snprintf.c
    ${_NX_LR}/compat/compat_posix_string.c
    ${_NX_LR}/string/stdstring.c
    ${_NX_LR}/time/rtime.c
    ${_NX_LR}/vfs/vfs_implementation.c
    # AI scripts
    ${_NX}/ai/ai.cpp
    ${_NX}/ai/balrog_common.cpp
    ${_NX}/ai/IrregularBBox.cpp
    ${_NX}/ai/almond/almond.cpp
    ${_NX}/ai/boss/balfrog.cpp
    ${_NX}/ai/boss/ballos.cpp
    ${_NX}/ai/boss/core.cpp
    ${_NX}/ai/boss/heavypress.cpp
    ${_NX}/ai/boss/ironhead.cpp
    ${_NX}/ai/boss/omega.cpp
    ${_NX}/ai/boss/sisters.cpp
    ${_NX}/ai/boss/undead_core.cpp
    ${_NX}/ai/boss/x.cpp
    ${_NX}/ai/egg/egg.cpp
    ${_NX}/ai/egg/egg2.cpp
    ${_NX}/ai/egg/igor.cpp
    ${_NX}/ai/final_battle/balcony.cpp
    ${_NX}/ai/final_battle/doctor.cpp
    ${_NX}/ai/final_battle/doctor_common.cpp
    ${_NX}/ai/final_battle/doctor_frenzied.cpp
    ${_NX}/ai/final_battle/final_misc.cpp
    ${_NX}/ai/final_battle/misery_finalbattle.cpp
    ${_NX}/ai/final_battle/sidekicks.cpp
    ${_NX}/ai/first_cave/first_cave.cpp
    ${_NX}/ai/hell/ballos_misc.cpp
    ${_NX}/ai/hell/ballos_priest.cpp
    ${_NX}/ai/hell/hell.cpp
    ${_NX}/ai/last_cave/last_cave.cpp
    ${_NX}/ai/maze/balrog_boss_missiles.cpp
    ${_NX}/ai/maze/critter_purple.cpp
    ${_NX}/ai/maze/gaudi.cpp
    ${_NX}/ai/maze/labyrinth_m.cpp
    ${_NX}/ai/maze/pooh_black.cpp
    ${_NX}/ai/maze/maze.cpp
    ${_NX}/ai/npc/balrog.cpp
    ${_NX}/ai/npc/curly.cpp
    ${_NX}/ai/npc/curly_ai.cpp
    ${_NX}/ai/npc/misery.cpp
    ${_NX}/ai/npc/npcguest.cpp
    ${_NX}/ai/npc/npcplayer.cpp
    ${_NX}/ai/npc/npcregu.cpp
    ${_NX}/ai/oside/oside.cpp
    ${_NX}/ai/plantation/plantation.cpp
    ${_NX}/ai/sand/curly_boss.cpp
    ${_NX}/ai/sand/puppy.cpp
    ${_NX}/ai/sand/sand.cpp
    ${_NX}/ai/sand/toroko_frenzied.cpp
    ${_NX}/ai/sym/smoke.cpp
    ${_NX}/ai/sym/sym.cpp
    ${_NX}/ai/village/balrog_boss_running.cpp
    ${_NX}/ai/village/ma_pignon.cpp
    ${_NX}/ai/village/village.cpp
    ${_NX}/ai/weapons/blade.cpp
    ${_NX}/ai/weapons/bubbler.cpp
    ${_NX}/ai/weapons/fireball.cpp
    ${_NX}/ai/weapons/missile.cpp
    ${_NX}/ai/weapons/nemesis.cpp
    ${_NX}/ai/weapons/polar_mgun.cpp
    ${_NX}/ai/weapons/snake.cpp
    ${_NX}/ai/weapons/spur.cpp
    ${_NX}/ai/weapons/weapons.cpp
    ${_NX}/ai/weapons/whimstar.cpp
    ${_NX}/ai/weed/balrog_boss_flying.cpp
    ${_NX}/ai/weed/frenzied_mimiga.cpp
    ${_NX}/ai/weed/weed.cpp
    ${_NX}/common/BList.cpp
    ${_NX}/common/DBuffer.cpp
    ${_NX}/common/DString.cpp
    ${_NX}/common/InitList.cpp
    ${_NX}/common/StringList.cpp
    ${_NX}/common/misc.c
    ${_NX}/common/bufio.c
    ${_NX}/endgame/credits.cpp
    ${_NX}/endgame/CredReader.cpp
    ${_NX}/endgame/island.cpp
    ${_NX}/endgame/endgame_misc.cpp
    ${_NX_X}/cachefiles.c
    ${_NX_X}/extractorg.c
    ${_NX_X}/extractpxt.c
    ${_NX_X}/extractstages.c
    ${_NX}/graphics/graphics.cpp
    ${_NX}/graphics/nxsurface.cpp
    ${_NX}/graphics/font.cpp
    ${_NX}/graphics/sprites.cpp
    ${_NX}/graphics/tileset.cpp
    ${_NX}/intro/intro.cpp
    ${_NX}/intro/title.cpp
    ${_NX}/pause/dialog.cpp
    ${_NX}/pause/message.cpp
    ${_NX}/pause/objects.cpp
    ${_NX}/pause/options.cpp
    ${_NX}/pause/pause.cpp
    ${_NX}/libretro/libretro.cpp
    ${_NX}/libretro/libretro_shared.c
    ${_NX}/main.cpp
    ${_NX}/siflib/sectSprites.cpp
    ${_NX}/siflib/sectStringArray.cpp
    ${_NX}/siflib/sif.cpp
    ${_NX}/siflib/sifloader.cpp
    ${_NX}/sound/org.cpp
    ${_NX}/sound/pxt.cpp
    ${_NX}/sound/sound.cpp
    ${_NX}/sound/sslib.c
    ${_NX}/TextBox/ItemImage.cpp
    ${_NX}/TextBox/SaveSelect.cpp
    ${_NX}/TextBox/StageSelect.cpp
    ${_NX}/TextBox/TextBox.cpp
    ${_NX}/TextBox/YesNoPrompt.cpp
    ${_NX}/autogen/AssignSprites.cpp
    ${_NX}/autogen/objnames.cpp
    ${_NX}/caret.cpp
    ${_NX}/floattext.cpp
    ${_NX}/game.cpp
    ${_NX}/inventory.cpp
    ${_NX}/map.cpp
    ${_NX}/map_system.cpp
    ${_NX}/object.cpp
    ${_NX}/ObjManager.cpp
    ${_NX}/p_arms.cpp
    ${_NX}/player.cpp
    ${_NX}/playerstats.cpp
    ${_NX}/screeneffect.cpp
    ${_NX}/settings.cpp
    ${_NX}/slope.cpp
    ${_NX}/stageboss.cpp
    ${_NX}/statusbar.cpp
    ${_NX}/trig.cpp
    ${_NX}/tsc.cpp
    ${_NX}/niku.c
    ${_NX}/input.c
    ${_NX}/stagedata.c
    ${_NX}/profile.c
)

target_include_directories(core_nxengine PUBLIC
    ${_NX}
    ${_NX}/graphics
    ${_NX}/libretro
    ${_NX}/sdl/include
    ${_NX_LR}/include
)

target_compile_definitions(core_nxengine PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_nxengine PRIVATE -w -fno-strict-aliasing)

set_target_properties(core_nxengine PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    CXX_STANDARD 11 CXX_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
