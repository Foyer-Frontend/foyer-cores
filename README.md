# foyer-cores

Companion repo to [foyer](../foyer/) — holds the libretro core build recipes
that produce per-system `foyer-<core>.nro` player binaries for Nintendo Switch.

Split out so cores can rebuild on their own cadence (when a libretro upstream
moves) without re-cutting a foyer release, and so GitHub Actions can ship
prebuilt nros that foyer fetches on-device from Settings → Install Cores.

## Layout

```
foyer-cores/
├── recipes/                 # one *.cmake per libretro core
│   ├── fceumm.cmake
│   ├── snes9x.cmake
│   ├── ...
│   ├── rcheevos.cmake       # shared static lib (achievements)
│   └── swanstation_stubs/   # in-repo C++ shims for cores that can't build cleanly
│                            # against libnx (e.g. swanstation's JIT / VM tricks)
└── cmake/
    └── core_recipe.cmake    # foyer_core_static_library() helper used by recipes
```

`recipes/` rather than `cores/` so it's clear what these files are: build
recipes. The actual core source trees get fetched into the build directory
via `FetchContent` at configure time; nothing here is checked-in upstream
source.

## Building from foyer

`foyer/CMakeLists.txt` resolves this directory via `FOYER_CORES_DIR`,
defaulting to a sibling clone (`<parent>/foyer-cores`). To use a different
location:

```sh
cmake --preset Player-fceumm -DFOYER_CORES_DIR=/path/to/foyer-cores
# or
FOYER_CORES_DIR=/path/to/foyer-cores cmake --preset Player-fceumm
```

The recipe interface stays the same as before — each `recipes/<name>.cmake`
declares a static lib named `core_<name>` that the player binary links.

## Authoring a new recipe

Use `foyer_core_static_library()` from `cmake/core_recipe.cmake`:

```cmake
include(FetchContent)
FetchContent_Declare(libretro_<name>
    GIT_REPOSITORY https://github.com/libretro/<name>.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_<name>)

set(_DIR ${libretro_<name>_SOURCE_DIR})
foyer_core_static_library(
    NAME <name>
    SOURCES      ${_DIR}/foo.c ${_DIR}/bar.c ...
    INCLUDE_DIRS ${_DIR} ${_DIR}/libretro-common/include
    COMPILE_DEFS __LIBRETRO__=1 SWITCH=1 __SWITCH__=1 HAVE_LIBNX=1
)
```

Mirror the upstream's `Makefile.libretro` source list. Most cores work with
the standard `__LIBRETRO__`/`SWITCH`/`HAVE_LIBNX` define set; some need
extras (see `snes9x.cmake`, `swanstation.cmake`).

After authoring, also add the core to `foyer/shared/library/system_db.cpp`
under the right system so the browser can launch with it.

## Distribution

GitHub Actions (TBD) will run a matrix build per recipe, producing one
`foyer-<core>.nro` per core and a `manifest.json` listing version, sha256,
download URL, and `system_compat` for foyer's installer.
