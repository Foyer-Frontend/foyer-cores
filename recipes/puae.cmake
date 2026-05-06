# cores/puae.cmake — libretro PUAE (Amiga 500/1200/2000/3000/4000/CD32/CDTV).
#
# Source list mirrors upstream Makefile.common's libnx target:
# STATIC_LINKING=1 + HAVE_CHD=1 + HAVE_MPEG2=1 (defaults). JIT path is
# disabled — upstream comments it out unconditionally on libnx.

include(FetchContent)

FetchContent_Declare(libretro_puae
    GIT_REPOSITORY https://github.com/libretro/libretro-uae.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE)
FetchContent_MakeAvailable(libretro_puae)

set(_PU     ${libretro_puae_SOURCE_DIR})
set(_PU_E   ${_PU}/sources/src)
set(_PU_LR  ${_PU}/libretro)
set(_PU_LRC ${_PU}/libretro-common)
set(_PU_DP  ${_PU}/deps)
set(_PU_RD  ${_PU}/retrodep)

add_library(core_puae STATIC
    # Libretro frontend
    ${_PU_LR}/libretro-core.c
    ${_PU_LR}/libretro-mapper.c
    ${_PU_LR}/libretro-dc.c
    ${_PU_LR}/libretro-glue.c
    ${_PU_LR}/libretro-vkbd.c
    ${_PU_LR}/libretro-graph.c
    ${_PU_DP}/libz/unzip.c
    ${_PU_DP}/libz/ioapi.c
    # Amiga emulator core
    ${_PU_E}/a2065.c
    ${_PU_E}/a2091.c
    ${_PU_E}/akiko.c
    ${_PU_E}/amax.c
    ${_PU_E}/ar.c
    ${_PU_E}/arcadia.c
    ${_PU_E}/aros.rom.c
    ${_PU_E}/audio.c
    ${_PU_E}/autoconf.c
    ${_PU_E}/blitfunc.c
    ${_PU_E}/blittable.c
    ${_PU_E}/blitter.c
    ${_PU_E}/blkdev.c
    ${_PU_E}/blkdev_cdimage.c
    ${_PU_E}/bsdsocket.c
    ${_PU_E}/calc.c
    ${_PU_E}/caps/caps.c
    ${_PU_E}/caps/uae_dlopen.c
    ${_PU_E}/cd32_fmv.c
    ${_PU_E}/cd32_fmv_genlock.c
    ${_PU_E}/cda_play.c
    ${_PU_E}/cdrom.c
    ${_PU_E}/cdtv.c
    ${_PU_E}/cdtvcr.c
    ${_PU_E}/cfgfile.c
    ${_PU_E}/cia.c
    ${_PU_E}/cpuboard.c
    ${_PU_E}/cpudefs.c
    ${_PU_E}/cpuemu_0.c
    ${_PU_E}/cpuemu_11.c
    ${_PU_E}/cpuemu_13.c
    ${_PU_E}/cpuemu_20.c
    ${_PU_E}/cpuemu_21.c
    ${_PU_E}/cpuemu_22.c
    ${_PU_E}/cpuemu_23.c
    ${_PU_E}/cpuemu_24.c
    ${_PU_E}/cpuemu_31.c
    ${_PU_E}/cpuemu_32.c
    ${_PU_E}/cpuemu_33.c
    ${_PU_E}/cpuemu_34.c
    ${_PU_E}/cpuemu_35.c
    ${_PU_E}/cpuemu_40.c
    ${_PU_E}/cpuemu_50.c
    ${_PU_E}/cpummu.c
    ${_PU_E}/cpummu30.c
    ${_PU_E}/cpustbl.c
    ${_PU_E}/crc32.c
    ${_PU_E}/custom.c
    ${_PU_E}/debug.c
    ${_PU_E}/debugmem.c
    ${_PU_E}/devices.c
    ${_PU_E}/disasm.c
    ${_PU_E}/disk.c
    ${_PU_E}/diskutil.c
    ${_PU_E}/dongle.c
    ${_PU_E}/draco.c
    ${_PU_E}/drawing.c
    ${_PU_E}/driveclick.c
    ${_PU_E}/ethernet.c
    ${_PU_E}/events.c
    ${_PU_E}/expansion.c
    ${_PU_E}/fdi2raw.c
    ${_PU_E}/filesys.c
    ${_PU_E}/filesys_unix.c
    ${_PU_E}/flashrom.c
    ${_PU_E}/fpp.c
    ${_PU_E}/fpp_native.c
    ${_PU_E}/fpp_softfloat.c
    ${_PU_E}/fsdb.c
    ${_PU_E}/fsdb_unix.c
    ${_PU_E}/fsusage.c
    ${_PU_E}/gayle.c
    ${_PU_E}/gfxboard.c
    ${_PU_E}/gfxlib.c
    ${_PU_E}/gfxutil.c
    ${_PU_E}/hardfile.c
    ${_PU_E}/hardfile_unix.c
    ${_PU_E}/hrtmon.rom.c
    ${_PU_E}/ide.c
    ${_PU_E}/idecontrollers.c
    ${_PU_E}/identify.c
    ${_PU_E}/ini.c
    ${_PU_E}/inputdevice.c
    ${_PU_E}/isofs.c
    ${_PU_E}/keybuf.c
    ${_PU_E}/main.c
    ${_PU_E}/memory.c
    ${_PU_E}/misc.c
    ${_PU_E}/missing.c
    ${_PU_E}/native2amiga.c
    ${_PU_E}/ncr_scsi.c
    ${_PU_E}/ncr9x_scsi.c
    ${_PU_E}/newcpu.c
    ${_PU_E}/newcpu_common.c
    ${_PU_E}/pci.c
    ${_PU_E}/picasso96.c
    ${_PU_E}/readcpu.c
    ${_PU_E}/rommgr.c
    ${_PU_E}/rtc.c
    ${_PU_E}/sampler.c
    ${_PU_E}/sana2.c
    ${_PU_E}/savestate.c
    ${_PU_E}/scsi.c
    ${_PU_E}/scsiemul.c
    ${_PU_E}/scsitape.c
    ${_PU_E}/sndboard.c
    ${_PU_E}/specialmonitors.c
    ${_PU_E}/statusline.c
    ${_PU_E}/test_card.c
    ${_PU_E}/traps.c
    ${_PU_E}/uaelib.c
    ${_PU_E}/uaenet.c
    ${_PU_E}/uaeresource.c
    ${_PU_E}/uaeserial.c
    ${_PU_E}/writelog.c
    ${_PU_E}/x86.c
    ${_PU_E}/zfile.c
    ${_PU_E}/zfile_archive.c
    ${_PU_E}/dsp3210/dsp_glue.c
    ${_PU_E}/dsp3210/DSP3210_emulation.c
    ${_PU_E}/softfloat/softfloat.c
    ${_PU_E}/softfloat/softfloat_decimal.c
    ${_PU_E}/softfloat/softfloat_fpsp.c
    # retrodep
    ${_PU_RD}/gui.c
    ${_PU_RD}/main.c
    ${_PU_RD}/mman.c
    ${_PU_RD}/parser.c
    ${_PU_RD}/serial_host.c
    ${_PU_RD}/machdep/support.c
    ${_PU_RD}/sounddep/sound.c
    ${_PU_RD}/threaddep/thread.c
    ${_PU_RD}/stubs/inputrecord.c
    # archivers (dms / lha / mp2)
    ${_PU_E}/archivers/dms/crc_csum.c
    ${_PU_E}/archivers/dms/getbits.c
    ${_PU_E}/archivers/dms/maketbl.c
    ${_PU_E}/archivers/dms/pfile.c
    ${_PU_E}/archivers/dms/tables.c
    ${_PU_E}/archivers/dms/u_deep.c
    ${_PU_E}/archivers/dms/u_heavy.c
    ${_PU_E}/archivers/dms/u_init.c
    ${_PU_E}/archivers/dms/u_medium.c
    ${_PU_E}/archivers/dms/u_quick.c
    ${_PU_E}/archivers/dms/u_rle.c
    ${_PU_E}/archivers/lha/crcio.c
    ${_PU_E}/archivers/lha/dhuf.c
    ${_PU_E}/archivers/lha/header.c
    ${_PU_E}/archivers/lha/huf.c
    ${_PU_E}/archivers/lha/larc.c
    ${_PU_E}/archivers/lha/lhamaketbl.c
    ${_PU_E}/archivers/lha/lharc.c
    ${_PU_E}/archivers/lha/shuf.c
    ${_PU_E}/archivers/lha/slide.c
    ${_PU_E}/archivers/lha/uae_lha.c
    ${_PU_E}/archivers/lha/util.c
    ${_PU_E}/archivers/mp2/kjmp2.c
    # libmpeg2 (cd32 FMV)
    ${_PU_DP}/libmpeg2/src/convert/rgb.c
    ${_PU_DP}/libmpeg2/src/cpu_accel.c
    ${_PU_DP}/libmpeg2/src/cpu_state.c
    ${_PU_DP}/libmpeg2/src/alloc.c
    ${_PU_DP}/libmpeg2/src/decode.c
    ${_PU_DP}/libmpeg2/src/header.c
    ${_PU_DP}/libmpeg2/src/idct.c
    ${_PU_DP}/libmpeg2/src/motion_comp.c
    ${_PU_DP}/libmpeg2/src/slice.c
    # libchdr + zstd + 7zip (HAVE_CHD=1)
    ${_PU_DP}/7zip/7zArcIn.c
    ${_PU_DP}/7zip/7zBuf.c
    ${_PU_DP}/7zip/7zCrc.c
    ${_PU_DP}/7zip/7zCrcOpt.c
    ${_PU_DP}/7zip/7zDec.c
    ${_PU_DP}/7zip/7zFile.c
    ${_PU_DP}/7zip/7zStream.c
    ${_PU_DP}/7zip/Bcj2.c
    ${_PU_DP}/7zip/Bra.c
    ${_PU_DP}/7zip/Bra86.c
    ${_PU_DP}/7zip/BraIA64.c
    ${_PU_DP}/7zip/CpuArch.c
    ${_PU_DP}/7zip/Delta.c
    ${_PU_DP}/7zip/Lzma2Dec.c
    ${_PU_DP}/7zip/LzmaDec.c
    ${_PU_DP}/7zip/LzFind.c
    ${_PU_DP}/7zip/LzmaEnc.c
    ${_PU_DP}/libchdr/src/libchdr_bitstream.c
    ${_PU_DP}/libchdr/src/libchdr_cdrom.c
    ${_PU_DP}/libchdr/src/libchdr_chd.c
    ${_PU_DP}/libchdr/src/libchdr_flac.c
    ${_PU_DP}/libchdr/src/libchdr_huffman.c
    ${_PU_DP}/zstd/lib/common/entropy_common.c
    ${_PU_DP}/zstd/lib/common/error_private.c
    ${_PU_DP}/zstd/lib/common/fse_decompress.c
    ${_PU_DP}/zstd/lib/common/zstd_common.c
    ${_PU_DP}/zstd/lib/common/xxhash.c
    ${_PU_DP}/zstd/lib/decompress/huf_decompress.c
    ${_PU_DP}/zstd/lib/decompress/zstd_ddict.c
    ${_PU_DP}/zstd/lib/decompress/zstd_decompress.c
    ${_PU_DP}/zstd/lib/decompress/zstd_decompress_block.c
    # libretro-common (upstream gates these on STATIC_LINKING != 1
    # but our player binary doesn't supply them either).
    ${_PU_LRC}/compat/compat_strl.c
    ${_PU_LRC}/compat/compat_strcasestr.c
    ${_PU_LRC}/compat/fopen_utf8.c
    ${_PU_LRC}/encodings/encoding_utf.c
    ${_PU_LRC}/file/file_path.c
    ${_PU_LRC}/file/file_path_io.c
    ${_PU_LRC}/file/retro_dirent.c
    ${_PU_LRC}/streams/file_stream.c
    ${_PU_LRC}/streams/file_stream_transforms.c
    ${_PU_LRC}/string/stdstring.c
    ${_PU_LRC}/time/rtime.c
    ${_PU_LRC}/vfs/vfs_implementation.c
)

target_include_directories(core_puae PUBLIC
    ${_PU_E}
    ${_PU_E}/include
    ${_PU}
    ${_PU_RD}
    ${_PU_DP}/7zip
    ${_PU_DP}/libmpeg2/include
    ${_PU_DP}/libchdr/include
    ${_PU_DP}/zstd/lib
    ${_PU_LR}
    ${_PU_LRC}/include
    ${_PU_LRC}/include/compat/zlib
)

target_compile_definitions(core_puae PRIVATE
    __LIBRETRO__=1
    SWITCH=1
    __SWITCH__=1
    HAVE_LIBNX=1
    WITH_MPEG2
    WITH_CHD
    HAVE_7ZIP
    _7ZIP_ST
    ZSTD_DISABLE_ASM
    # Route file I/O through libretro's VFS (rfseek/rftell) instead of
    # the NO_LIBRETRO_VFS branch in sysconfig.h, which calls newlib-
    # missing fseeko64/ftello64.
    USE_LIBRETRO_VFS=1
    STATIC_LINKING=1
    NDEBUG=1
)

target_compile_options(core_puae PRIVATE -w -fno-strict-aliasing -ffast-math)

# gz_uncompress in libretro-glue.c calls gzread/gzerror/gzclose from
# zlib's gzio. We don't compile zlib ourselves (deps/libz/ has only
# unzip.c + ioapi.c, not the gzio bits), so route the link to
# devkitPro's portlibs zlib via -lz.
target_link_libraries(core_puae PUBLIC -lz)

set_target_properties(core_puae PROPERTIES
    C_STANDARD 99 C_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON)
