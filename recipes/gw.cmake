# cores/gw.cmake — libretro Game and Watch (gw-libretro). Pure-Lua
# game runtime backed by a custom retroluxury graphics framework, with
# bundled bzip2 + Lua 5.3.
#
# Asset .h files (PNG / Lua → header) are pre-generated and checked
# into the upstream repo, so this is a straight C compile — no
# build-time conversion script needed.

include(FetchContent)

FetchContent_Declare(libretro_gw
    GIT_REPOSITORY https://github.com/libretro/gw-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_gw)

set(_GW ${libretro_gw_SOURCE_DIR})

add_library(core_gw STATIC
    ${_GW}/src/libretro.c
    ${_GW}/src/libretro_version.c
    ${_GW}/src/missing.c
    ${_GW}/gwrom/gwrom.c
    ${_GW}/gwlua/bsreader.c
    ${_GW}/gwlua/functions.c
    ${_GW}/gwlua/gwlua.c
    ${_GW}/gwlua/image.c
    ${_GW}/gwlua/ref.c
    ${_GW}/gwlua/sound.c
    ${_GW}/gwlua/timer.c
    ${_GW}/retroluxury/src/rl_backgrnd.c
    ${_GW}/retroluxury/src/rl_image.c
    ${_GW}/retroluxury/src/rl_map.c
    ${_GW}/retroluxury/src/rl_rand.c
    ${_GW}/retroluxury/src/rl_sound.c
    ${_GW}/retroluxury/src/rl_sprite.c
    ${_GW}/retroluxury/src/rl_tile.c
    ${_GW}/retroluxury/src/rl_version.c
    ${_GW}/bzip2/blocksort.c
    ${_GW}/bzip2/huffman.c
    ${_GW}/bzip2/crctable.c
    ${_GW}/bzip2/randtable.c
    ${_GW}/bzip2/compress.c
    ${_GW}/bzip2/decompress.c
    ${_GW}/bzip2/bzlib.c
    ${_GW}/lua/src/lapi.c
    ${_GW}/lua/src/lcode.c
    ${_GW}/lua/src/lctype.c
    ${_GW}/lua/src/ldebug.c
    ${_GW}/lua/src/ldo.c
    ${_GW}/lua/src/ldump.c
    ${_GW}/lua/src/lfunc.c
    ${_GW}/lua/src/lgc.c
    ${_GW}/lua/src/llex.c
    ${_GW}/lua/src/lmem.c
    ${_GW}/lua/src/lobject.c
    ${_GW}/lua/src/lopcodes.c
    ${_GW}/lua/src/lparser.c
    ${_GW}/lua/src/lstate.c
    ${_GW}/lua/src/lstring.c
    ${_GW}/lua/src/ltable.c
    ${_GW}/lua/src/ltm.c
    ${_GW}/lua/src/lundump.c
    ${_GW}/lua/src/lvm.c
    ${_GW}/lua/src/lzio.c
    ${_GW}/lua/src/lauxlib.c
    ${_GW}/lua/src/lbaselib.c
    ${_GW}/lua/src/lbitlib.c
    ${_GW}/lua/src/lcorolib.c
    ${_GW}/lua/src/ldblib.c
    ${_GW}/lua/src/lmathlib.c
    ${_GW}/lua/src/lstrlib.c
    ${_GW}/lua/src/ltablib.c
    ${_GW}/lua/src/lutf8lib.c
    ${_GW}/lua/src/loadlib.c
)

target_include_directories(core_gw PUBLIC
    ${_GW}
    ${_GW}/src
    ${_GW}/gwrom
    ${_GW}/gwlua
    ${_GW}/bzip2
    ${_GW}/lua/src
    ${_GW}/retroluxury/src
)

target_compile_definitions(core_gw PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    BZ_NO_STDIO=1
    rl_malloc=malloc
    rl_free=free
    gwlua_malloc=malloc
    gwlua_realloc=realloc
    gwlua_free=free
    gwrom_malloc=malloc
    gwrom_free=free
    NDEBUG=1
)

target_compile_options(core_gw PRIVATE -w -fno-strict-aliasing)

set_target_properties(core_gw PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
