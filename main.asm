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

include "kernel.asm"

    nops(0x80010000)

Main:
    lui     t0, K_BASE

    lui     s0, BLAH_BASE

    mfc0    t0, CP0_Count
    mfc0    t1, CP0_Status+0
    sw      t0, BLAH_COUNTS+0(s0)
    sw      t1, 8(s0)

// decompress our picture
include "lz.asm"

    mfc0    t0, CP0_Count
    sw      t0, BLAH_COUNTS+8(s0)
    lui     t0, K_BASE
    lw      t1, K_64DRIVE_MAGIC(t0)
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

    mfc0    t0, CP0_Count
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
    subiu   sp, sp, 0x18
    sw      ra, 0x10(sp)

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
    li      t0, VIDEO_STACK & ADDR_MASK // used for DList calls and returns?
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

    lw      ra, 0x10(sp)
    jr      ra
    addiu   sp, sp, 0x18

PushRSPTask:
    lli     t3, 0x40 - 1 // DMA quirk
    SP_DMA_WAIT() // clobbers t0, t5
    ori     t1, t5, 0xFC0
    sw      t1, SP_MEM_ADDR(t5)
    sw      a0, SP_DRAM_ADDR(t5)
    sw      t3, SP_RD_LEN(t5) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

align(16); insert F3DZEX_BOOT, "F3DZEX2.boot.bin"
align(16); insert F3DZEX_DMEM, "F3DZEX2.data.bin"
align(16); insert F3DZEX_IMEM, "F3DZEX2.bin"
align(16); insert FONT, "dwarf.1bpp"
align(16); insert LZ, "Image.lz"
