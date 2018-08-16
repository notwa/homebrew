// built on the N64 ROM template by krom
arch n64.cpu
endian msb
include "n64.inc"
include "n64_gfx.inc"
include "64drive.inc"

output "test.z64", create
fill 1052672 // Set ROM Size

origin 0x00000000
base 0x80000000

include "header.asm"
insert "6102.bin"
// after inserting the header and bootrom,
// origin should be at 0x1000.

include "main.inc"

Start:
    N64_INIT() // enable interrupts

    // SP defaults to RSP instruction memory: 0xA4001FF0
    // we can do better than that.
    lui     sp, BLAH_BASE
    // SP should always be 8-byte aligned
    // so that SD and LD instructions don't fail on it.
    subiu   sp, sp, 8

    lui     s0, BLAH_BASE

Drive64Init:
    lui     gp, CI_BASE
    lui     t2, 0x5544      // "UD" of "UDEV"
    lw      t1, CI_HW_MAGIC(gp)
    ori     t2, t2, 0x4556  // "EV" of "UDEV"

    beq     t1, t2, Drive64Confirmed
    nop // delay slot

Drive64TryExtended:
    lui     gp, CI_BASE_EXTENDED
    lw      t1, CI_HW_MAGIC(gp)
    bne     t1, t2, Main
    nop // delay slot

Drive64Confirmed:
    sw      t2, BLAH_CONFIRMED(s0)
    sw      gp, BLAH_CI_BASE(s0)

    // enable writing to cartROM (SDRAM) for USB writing later
    lli     t1, 0xF0

    CI_WAIT()
    sw      t1, CI_COMMAND(gp) // send our command
    CI_WAIT()

Main:
if 0 {
    mfc0    t0, 0x9          // move cycle Count register from COP 0
    sw      t0, BLAH_COUNTS+0(s0)
    mfc0    t0, 0x9          // move cycle Count register from COP 0
    sw      t0, BLAH_COUNTS+4(s0)
    // seems like 41 half-cycles between the two mfc0's, rarely 42?
} else {
    mfc0    t0, 0x9
    mfc0    t1, 0x9
    sw      t0, BLAH_COUNTS+0(s0)
    sw      t1, BLAH_COUNTS+4(s0)
    // seems like 22 half-cycles between the two mfc0's
}

    // what is our stack pointer set to, anyway?
    sw      sp, 0xC(s0)

// decompress our picture
include "lz.asm"

    mfc0    t0, 0x9
    sw      t0, BLAH_COUNTS+8(s0)
    lw      t1, BLAH_CONFIRMED(s0)
    beqz    t1, InitVideo
    nop // delay slot

//  jal     Drive64TestWrite
//  nop // delay slot

    lui     a0, BLAH_BASE
    lli     a1, 0x20
    ori     a2, a0, BLAH_XXD
    lli     a3, 0x20 * 4
    jal     xxd
    nop // delay slot

    lui     a0, BLAH_BASE       // write address
    ori     a0, a0, BLAH_XXD    // (RAM gets copied to SDRAM by routine)
    lli     a1, 0x20 * 4
    jal     Drive64Write
    nop // delay slot

InitVideo: // currently 80001190 (this comment is likely out of date)
    // A4000FC0

    jal     LoadRSPBoot
    nop

    lui     a0, BLAH_BASE
    jal     PushVideoTask
    ori     a0, a0, BLAH_SP_TASK

    jal     SetupScreen
    nop

    mfc0    t0, 0x9 // move cycle Count register from COP 0
    sw      t0, BLAH_COUNTS+0xC(s0)

MainLoop:
    // borrowing code from krom for now:
    WaitScanline(0x1E0) // Wait For Scanline To Reach Vertical Blank
    WaitScanline(0x1E2)
    // WaitScanline sets a0

    ori     t0, r0, 0x00000800 // Even Field
    sw      t0, VI_Y_SCALE(a0)

    WaitScanline(0x1E0) // Wait For Scanline To Reach Vertical Blank
    WaitScanline(0x1E2)
    // WaitScanline sets a0

    li      t0, 0x02000800 // Odd Field
    sw      t0, VI_Y_SCALE(a0)

    j MainLoop
    nop // delay slot

include "debug.asm" // assumes gp is set to CI base

SetupScreen:
    // NTSC: 640x480, 32BPP, Interlace, Resample Only, DRAM Origin VIDEO_BUFFER
    ScreenNTSC(640, 480, BPP32|INTERLACE|AA_MODE_2, VIDEO_BUFFER | UNCACHED)
    jr      ra
    nop

LoadRSPBoot:
    li      t2, F3DZEX_BOOT
    li      t3, F3DZEX_BOOT.size
    subiu   t3, t3, 1 // DMA quirk
    SP_DMA_WAIT() // clobbers t0, t5
    ori     t1, t5, 0x1000
    sw      t1, SP_MEM_ADDR(t5)
    sw      t2, SP_DRAM_ADDR(t5)
    sw      t3, SP_RD_LEN(t5) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

PushVideoTask:
    // a0: Task RDRAM Pointer (size: 0x40)
    subiu   sp, sp, 0x8
    sw      ra, 0(sp)

    lli     t0, 1 // mode: video
    lli     t1, 4 // flags: ???
    li      t2, F3DZEX_BOOT
    li      t3, F3DZEX_BOOT.size
    li      t4, F3DZEX_IMEM & ADDR_MASK
    li      t5, F3DZEX_IMEM.size // note: Zelda uses 0x1000 for some reason (0x80 too big).
    li      t6, F3DZEX_DMEM & ADDR_MASK
    li      t7, F3DZEX_DMEM.size // note: Zelda uses 0x800 for some reason (way too big).
    sw      t0, 0x00(a0)
    sw      t1, 0x04(a0)
    sw      t2, 0x08(a0)
    sw      t3, 0x0C(a0)
    sw      t4, 0x10(a0)
    sw      t5, 0x14(a0)
    sw      t6, 0x18(a0)
    sw      t7, 0x1C(a0)
    li      t0, VIDEO_STACK & ADDR_MASK // ?
    li      t1, VIDEO_STACK_SIZE
    li      t2, VIDEO_BUFFER & ADDR_MASK
    li      t3, (VIDEO_BUFFER & ADDR_MASK) + VIDEO_BUFFER_SIZE // end pointer (not size!)
    li      t4, ((BLAH_BASE << 16) | BLAH_DLIST_JUMPER) & ADDR_MASK // initial DList
    lli     t5, 8 // size of one jump command
    li      t6, VIDEO_YIELD & ADDR_MASK
    li      t7, VIDEO_YIELD_SIZE
    sw      t0, 0x20(a0)
    sw      t1, 0x24(a0)
    sw      t2, 0x28(a0)
    sw      t3, 0x2C(a0)
    sw      t4, 0x30(a0)
    sw      t5, 0x34(a0)
    sw      t6, 0x38(a0)
    sw      t7, 0x3C(a0)
    jal     PushRSPTask // a0 passthru
    nop

    lw      ra, 0(sp)
    jr      ra
    addiu   sp, sp, 0x8

PushRSPTask:
    lli     t3, 0x40 - 1 // DMA quirk
    SP_DMA_WAIT() // clobbers t0, t5
    ori     t1, t5, 0xFC0
    sw      t1, SP_MEM_ADDR(t5)
    sw      a0, SP_DRAM_ADDR(t5)
    sw      t3, SP_RD_LEN(t5) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

include "xxd.asm"

align(16); insert F3DZEX_BOOT, "F3DZEX2.boot.bin"
align(16); insert F3DZEX_DMEM, "F3DZEX2.data.bin"
align(16); insert F3DZEX_IMEM, "F3DZEX2.bin"
align(16); insert FONT, "dwarf.1bpp"
align(16); insert LZ, "Image.lz"
