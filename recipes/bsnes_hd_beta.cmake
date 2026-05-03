# recipes/bsnes_hd_beta.cmake — libretro bsnes-hd-beta
# (SNES core with HD Mode 7 and widescreen rendering).
#
# UNTESTED. bsnes uses a "unity build" pattern: each subsystem is a
# single .cpp that #includes its sublibraries. The TU list below mirrors
# bsnes/{GNUmakefile,sfc/GNUmakefile,gb/GNUmakefile,processor/GNUmakefile}
# at the libnx target slice.

include(FetchContent)

FetchContent_Declare(libretro_bsnes_hd
    GIT_REPOSITORY https://github.com/libretro/bsnes-hd.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_bsnes_hd)

set(_BSNES ${libretro_bsnes_hd_SOURCE_DIR})
set(_B     ${_BSNES}/bsnes)

add_library(core_bsnes_hd_beta STATIC
    # Core unity TUs.
    ${_BSNES}/libco/libco.c
    ${_B}/emulator/emulator.cpp
    ${_B}/filter/filter.cpp
    ${_B}/lzma/lzma.cpp
    # SNES (SFC) subsystem.
    ${_B}/sfc/interface/interface.cpp
    ${_B}/sfc/system/system.cpp
    ${_B}/sfc/controller/controller.cpp
    ${_B}/sfc/cartridge/cartridge.cpp
    ${_B}/sfc/memory/memory.cpp
    ${_B}/sfc/cpu/cpu.cpp
    ${_B}/sfc/smp/smp.cpp
    ${_B}/sfc/dsp/dsp.cpp
    ${_B}/sfc/ppu/ppu.cpp
    ${_B}/sfc/ppu-fast/ppu.cpp
    ${_B}/sfc/expansion/expansion.cpp
    ${_B}/sfc/coprocessor/coprocessor.cpp
    ${_B}/sfc/slot/slot.cpp
    # SuperGameBoy (vendored SameBoy core).
    ${_B}/gb/Core/apu.c
    ${_B}/gb/Core/camera.c
    # debugger.c omitted — DISABLE_DEBUGGER makes its body collapse into
    # a malformed declaration on the libnx C compiler. SuperGameBoy
    # doesn't need the GB debugger interface.
    ${_B}/gb/Core/display.c
    ${_B}/gb/Core/gb.c
    ${_B}/gb/Core/joypad.c
    ${_B}/gb/Core/mbc.c
    ${_B}/gb/Core/memory.c
    ${_B}/gb/Core/printer.c
    ${_B}/gb/Core/random.c
    ${_B}/gb/Core/rewind.c
    ${_B}/gb/Core/save_state.c
    ${_B}/gb/Core/sgb.c
    ${_B}/gb/Core/sm83_cpu.c
    # sm83_disassembler.c omitted — also references the debugger API
    # that DISABLE_DEBUGGER takes out from under it.
    ${_B}/gb/Core/symbol_hash.c
    ${_B}/gb/Core/timing.c
    # SNES enhancement-chip processors. bsnes/sfc/GNUmakefile sets
    # `processors += wdc65816 spc700 arm7tdmi` so only these three TUs
    # are compiled. The other processor/* subdirs (sm83, gsu, hg51b,
    # upd96050) are NOT part of the libretro build — sm83 in
    # particular references a `bit1` macro that's only #defined inside
    # arm7tdmi/instruction.cpp, so trying to compile sm83 standalone
    # is a dead end.
    ${_B}/processor/arm7tdmi/arm7tdmi.cpp
    ${_B}/processor/spc700/spc700.cpp
    ${_B}/processor/wdc65816/wdc65816.cpp
    # libretro frontend.
    ${_B}/target-libretro/libretro.cpp
)

target_include_directories(core_bsnes_hd_beta PUBLIC
    ${_B}
    ${_BSNES}              # for nall/, libco/
    ${_B}/target-libretro
)

target_compile_definitions(core_bsnes_hd_beta PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    HAVE_POSIX_MEMALIGN=1
    # GB_INTERNAL exposes the SuperGameBoy chip's internal struct fields
    # that bsnes-hd's vendored SameBoy core actually uses. Set globally —
    # non-GB TUs don't include gb.h. DISABLE_DEBUGGER skips the debugger
    # build of debugger.c. Both come from bsnes/gb/GNUmakefile.
    GB_INTERNAL=1
    DISABLE_DEBUGGER=1
    _GNU_SOURCE=1
)
target_compile_options(core_bsnes_hd_beta PRIVATE
    -w
    -Wno-narrowing
    -Wno-multichar
    -fno-strict-aliasing
    # bsnes is an inner-loop-bound cycle-accurate emulator; the foyer
    # default of MinSizeRel (-Os) leaves significant performance on
    # the table, especially for the cycle-accurate PPU path. Override
    # to -O3 for this target only — handheld + docked Switch both
    # benefit. Adds ~5-10 MB to the nro vs -Os.
    -O3
    # nall/arithmetic/natural.hpp uses std::runtime_error without
    # including <stdexcept>. GCC 15 dropped the transitive include,
    # so force it in.
    "SHELL:$<$<COMPILE_LANGUAGE:CXX>:-include stdexcept>"
)
# Link-time optimization. bsnes is a unity-build (each subsystem is
# a single .cpp #including its sublibs), so the compiler already
# inlines aggressively within each TU. -flto extends that across
# TUs — measurable speedup on the SFC CPU/SMP/DSP hot loops.
target_compile_options(core_bsnes_hd_beta PRIVATE -flto)
target_link_options   (core_bsnes_hd_beta PRIVATE -flto)
set_target_properties(core_bsnes_hd_beta PROPERTIES
    C_STANDARD                99
    C_STANDARD_REQUIRED       ON
    CXX_STANDARD              17
    CXX_STANDARD_REQUIRED     ON
    POSITION_INDEPENDENT_CODE ON)
