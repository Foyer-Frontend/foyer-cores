# cores/stella2014.cmake — libretro stella2014 (Atari 2600, lighter
# fork) core build.
#
# Older fork of Stella with a simpler emucore — lower CPU/thermals
# than the modern `stella` recipe, useful for low-power Switch states.
# Source list mirrors upstream Makefile.common's libnx target
# (CORE_DIR=stella, LIBRETRO_DIR=., STATIC_LINKING=1).

include(FetchContent)

FetchContent_Declare(libretro_stella2014
    GIT_REPOSITORY https://github.com/libretro/stella2014-libretro.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_stella2014)

set(_S2K     ${libretro_stella2014_SOURCE_DIR})
set(_S2K_CD  ${_S2K}/stella)
set(_S2K_LRC ${_S2K}/libretro-common)

set(_S2K_CXX
    ${_S2K_CD}/src/common/Base.cxx
    ${_S2K_CD}/src/common/Sound.cxx
    ${_S2K_CD}/src/emucore/AtariVox.cxx
    ${_S2K_CD}/src/emucore/Booster.cxx
    ${_S2K_CD}/src/emucore/Cart.cxx
    ${_S2K_CD}/src/emucore/Cart0840.cxx
    ${_S2K_CD}/src/emucore/Cart2K.cxx
    ${_S2K_CD}/src/emucore/Cart3E.cxx
    ${_S2K_CD}/src/emucore/Cart3F.cxx
    ${_S2K_CD}/src/emucore/Cart4A50.cxx
    ${_S2K_CD}/src/emucore/Cart4K.cxx
    ${_S2K_CD}/src/emucore/Cart4KSC.cxx
    ${_S2K_CD}/src/emucore/CartAR.cxx
    ${_S2K_CD}/src/emucore/CartBF.cxx
    ${_S2K_CD}/src/emucore/CartBFSC.cxx
    ${_S2K_CD}/src/emucore/CartCM.cxx
    ${_S2K_CD}/src/emucore/CartCTY.cxx
    ${_S2K_CD}/src/emucore/CartCV.cxx
    ${_S2K_CD}/src/emucore/CartDF.cxx
    ${_S2K_CD}/src/emucore/CartDFSC.cxx
    ${_S2K_CD}/src/emucore/CartDPC.cxx
    ${_S2K_CD}/src/emucore/CartDPCPlus.cxx
    ${_S2K_CD}/src/emucore/CartE0.cxx
    ${_S2K_CD}/src/emucore/CartE7.cxx
    ${_S2K_CD}/src/emucore/CartEF.cxx
    ${_S2K_CD}/src/emucore/CartEFSC.cxx
    ${_S2K_CD}/src/emucore/CartF0.cxx
    ${_S2K_CD}/src/emucore/CartF4.cxx
    ${_S2K_CD}/src/emucore/CartF4SC.cxx
    ${_S2K_CD}/src/emucore/CartF6.cxx
    ${_S2K_CD}/src/emucore/CartF6SC.cxx
    ${_S2K_CD}/src/emucore/CartF8.cxx
    ${_S2K_CD}/src/emucore/CartF8SC.cxx
    ${_S2K_CD}/src/emucore/CartFA.cxx
    ${_S2K_CD}/src/emucore/CartFA2.cxx
    ${_S2K_CD}/src/emucore/CartFE.cxx
    ${_S2K_CD}/src/emucore/CartMC.cxx
    ${_S2K_CD}/src/emucore/CartSB.cxx
    ${_S2K_CD}/src/emucore/CartUA.cxx
    ${_S2K_CD}/src/emucore/CartX07.cxx
    ${_S2K_CD}/src/emucore/CompuMate.cxx
    ${_S2K_CD}/src/emucore/Console.cxx
    ${_S2K_CD}/src/emucore/Control.cxx
    ${_S2K_CD}/src/emucore/Driving.cxx
    ${_S2K_CD}/src/emucore/Genesis.cxx
    ${_S2K_CD}/src/emucore/Joystick.cxx
    ${_S2K_CD}/src/emucore/Keyboard.cxx
    ${_S2K_CD}/src/emucore/KidVid.cxx
    ${_S2K_CD}/src/emucore/M6502.cxx
    ${_S2K_CD}/src/emucore/M6532.cxx
    ${_S2K_CD}/src/emucore/MD5.cxx
    ${_S2K_CD}/src/emucore/MindLink.cxx
    ${_S2K_CD}/src/emucore/MT24LC256.cxx
    ${_S2K_CD}/src/emucore/NullDev.cxx
    ${_S2K_CD}/src/emucore/Paddles.cxx
    ${_S2K_CD}/src/emucore/Props.cxx
    ${_S2K_CD}/src/emucore/PropsSet.cxx
    ${_S2K_CD}/src/emucore/Random.cxx
    ${_S2K_CD}/src/emucore/SaveKey.cxx
    ${_S2K_CD}/src/emucore/Serializer.cxx
    ${_S2K_CD}/src/emucore/Settings.cxx
    ${_S2K_CD}/src/emucore/StateManager.cxx
    ${_S2K_CD}/src/emucore/Switches.cxx
    ${_S2K_CD}/src/emucore/System.cxx
    ${_S2K_CD}/src/emucore/Thumbulator.cxx
    ${_S2K_CD}/src/emucore/TIA.cxx
    ${_S2K_CD}/src/emucore/TIASnd.cxx
    ${_S2K_CD}/src/emucore/TIATables.cxx
    ${_S2K_CD}/src/emucore/TrackBall.cxx
    ${_S2K}/libretro.cxx
)

set(_S2K_C
    ${_S2K_LRC}/compat/compat_posix_string.c
    ${_S2K_LRC}/compat/compat_strcasestr.c
    ${_S2K_LRC}/compat/compat_snprintf.c
    ${_S2K_LRC}/compat/compat_strl.c
    ${_S2K_LRC}/compat/fopen_utf8.c
    ${_S2K_LRC}/encodings/encoding_utf.c
    ${_S2K_LRC}/file/file_path.c
    ${_S2K_LRC}/file/file_path_io.c
    ${_S2K_LRC}/time/rtime.c
    ${_S2K_LRC}/streams/file_stream.c
    ${_S2K_LRC}/streams/file_stream_transforms.c
    ${_S2K_LRC}/string/stdstring.c
    ${_S2K_LRC}/vfs/vfs_implementation.c
)

add_library(core_stella2014 STATIC ${_S2K_CXX} ${_S2K_C})

target_include_directories(core_stella2014 PUBLIC
    ${_S2K}
    ${_S2K_CD}
    ${_S2K_CD}/src
    ${_S2K_CD}/stubs
    ${_S2K_CD}/src/emucore
    ${_S2K_CD}/src/common
    ${_S2K_CD}/src/gui
    ${_S2K_LRC}/include
)

target_compile_definitions(core_stella2014 PRIVATE
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    RARCH_INTERNAL
    FRONTEND_SUPPORTS_RGB565=1
    THUMB_SUPPORT
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_stella2014 PRIVATE
    -w
    -U__linux__
    -U__linux
    $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>
    $<$<COMPILE_LANGUAGE:CXX>:-fexceptions>
)

set_target_properties(core_stella2014 PROPERTIES
    CXX_STANDARD              11
    CXX_EXTENSIONS            ON
    C_STANDARD                11
    C_EXTENSIONS              ON
    POSITION_INDEPENDENT_CODE ON)
