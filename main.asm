// built on the N64 ROM template by krom
arch n64.cpu
endian msb

include "inc/util.inc"
include "inc/n64.inc"
include "inc/64drive.inc"
include "inc/main.inc"
include "inc/kernel.inc"

output "test.z64", create
fill 1052672 // Set ROM Size

origin 0x00000000
base 0x80000000

include "header.asm"
insert "bin/6102.bin"
// after inserting the header and bootrom,
// origin should be at 0x1000.

include "kernel.asm"

Main:
    lui     t0, K_BASE

    lui     s0, BLAH_BASE
    mfc0    t1, CP0_Status
    sw      t1, 8(s0)

    nop; nop; nop; nop
    mfc0    t0, CP0_Count
    sw      t0, BLAH_COUNTS+0(s0)

    // decompress our picture
    la      a0, LZ_BAKU + 4
    lw      a3, -4(a0) // load uncompressed size from the file itself
    li      a1, LZ_BAKU.size - 4
    li      a2, VIDEO_C_BUFFER
    jal     LzDecomp
    nop

    mfc0    t0, CP0_Count
    nop; nop; nop; nop

    lw      t1, BLAH_COUNTS+0x0(s0)
    sw      t0, BLAH_COUNTS+0x4(s0)
    subu    t1, t0, t1
    sw      t1, BLAH_COUNTS+0xC(s0)

    jal     PokeDataCache
    nop

    lui     a0, BLAH_BASE
    lli     a1, 0x20
    ori     a2, a0, BLAH_XXD
    jal     DumpAndWrite
    lli     a3, 0x20 * 4
    KMaybeDumpString(KSNewline)

InitVideo:
    jal     SetupScreen
    nop

Test3D:
    // write the jump to our actual instructions
    lui     a0, BLAH_BASE
    lui     t0, 0xDE01 // jump (no push)
    ori     t1, a0, BLAH_DLIST
    sw      t0, BLAH_DLIST_JUMPER+0(a0)
    sw      t1, BLAH_DLIST_JUMPER+4(a0)

    lui     a0, BLAH_BASE
    ori     a0, BLAH_DLIST

include "dlist.asm" // takes a0

    jal     PokeCaches
    nop

    // take a peek at the display list we wrote
    lui     a0, BLAH_BASE
    ori     a0, BLAH_DLIST
    lli     a1, 0x80
    ori     a2, a0, BLAH_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4

Start3D:
    DisableInt()

    // stuff i'm borrowing from zelda:
    lui     a0, SP_BASE
    lli     t0, CLR_SG2 | CLR_SG1 | CLR_SG0 | SET_IOB
    sw      t0, SP_STATUS(a0)

    // wait
    lui     a0, SP_BASE
-
    lw      t0, SP_STATUS(a0)
    andi    t0, 1
    beqz    t0,-
    nop

    // set RSP PC to IMEM+$0
    lui     a0, SP_PC_BASE
    //sw      r0, SP_PC(a0)
    li      t0, 0x04001000
    sw      t0, SP_PC(a0)

    lui     a0, BLAH_BASE
    jal     PushVideoTask
    ori     a0, a0, BLAH_SP_TASK

    // take a peek at the Task data we wrote
    lui     a0, BLAH_BASE
    ori     a0, a0, BLAH_SP_TASK
    lli     a1, 0x40
    ori     a2, a0, BLAH_XXD
    jal     DumpAndWrite
    lli     a3, 0x40 * 4
    KMaybeDumpString(KSNewline)

    SP_BUSY_WAIT()

    jal     LoadRSPBoot
    nop

    SP_BUSY_WAIT()

    // clear all flags that would halt RSP (i.e. tell it to run!)
    lui     a0, SP_BASE
    lli     t0, SET_IOB | CLR_STP | CLR_BRK | CLR_HLT
    sw      t0, SP_STATUS(a0)
    nop

    EnableInt()

MainLoop:
    // borrowing code from krom for now:
    WaitScanline(0x1E0) // Wait For Scanline To Reach Vertical Blank
    WaitScanline(0x1E2)
    // WaitScanline sets a0

    li      t0, 0x00000800 // Even Field
    sw      t0, VI_Y_SCALE(a0)

    WaitScanline(0x1E0) // Wait For Scanline To Reach Vertical Blank
    WaitScanline(0x1E2)
    // WaitScanline sets a0

    li      t0, 0x02000800 // Odd Field
    sw      t0, VI_Y_SCALE(a0)

    j MainLoop
    nop // delay slot

SetupScreen:
    ScreenNTSC(640, 480, BPP32|INTERLACE|AA_MODE_2, VIDEO_C_BUFFER | UNCACHED)
    jr      ra
    nop

PushVideoTask:
    // a0: Task RDRAM Pointer (size: 0x40) (should probably be row-aligned)
    subiu   sp, sp, 0x18
    sw      ra, 0x10(sp)

    lli     t0, 1 // mode: video
    lli     t1, 4 // flags: ???
    li      t2, F3DZEX_BOOT // does not need masking for some reason
    li      t3, F3DZEX_BOOT.size
    li      t4, F3DZEX_IMEM & ADDR_MASK
    li      t5, F3DZEX_IMEM.size
    li      t6, F3DZEX_DMEM & ADDR_MASK
    li      t7, F3DZEX_DMEM.size
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
    li      t2, VIDEO_SOMETHING & ADDR_MASK
    li      t3, (VIDEO_SOMETHING & ADDR_MASK) + VIDEO_SOMETHING_SIZE // end pointer (not size!)
    li      t4, ((BLAH_BASE << 16) | BLAH_DLIST_JUMPER) & ADDR_MASK // initial DList
    lli     t5, 8 // size of one jump command. this is ignored and 0xA8 is used instead
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

    // tell data cache to write itself out
    cache   0x19, 0x00(a0)
    cache   0x19, 0x10(a0)
    cache   0x19, 0x20(a0)
    cache   0x19, 0x30(a0)

    li      t9, ADDR_MASK
    jal     PushRSPTask
    and     a0, a0, t9

    lw      ra, 0x10(sp)
    jr      ra
    addiu   sp, sp, 0x18

PushRSPTask:
    lli     t3, 0x40 - 1 // DMA quirk
    SP_DMA_WAIT() // clobbers t0, t5
    la      t1, 0xA4000FC0
    sw      t1, SP_MEM_ADDR(t5)
    sw      a0, SP_DRAM_ADDR(t5)
    sw      t3, SP_RD_LEN(t5) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

LoadRSPBoot:
    la      t2, F3DZEX_BOOT & ADDR_MASK
    li      t3, F3DZEX_BOOT.size
    subiu   t3, t3, 1 // DMA quirk
    SP_DMA_WAIT() // clobbers t0, t5
    la      t1, 0xA4001000
    sw      t1, SP_MEM_ADDR(t5)
    sw      t2, SP_DRAM_ADDR(t5)
    sw      t3, SP_RD_LEN(t5) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

include "lzss.baku.unsafe.asm"

align(16); insert F3DZEX_BOOT, "bin/F3DZEX2.boot.bin"
align(16); insert F3DZEX_DMEM, "bin/F3DZEX2.data.bin"
align(16); insert F3DZEX_IMEM, "bin/F3DZEX2.bin"
align(16); insert FONT, "res/dwarf.1bpp"
align(16); insert LZ_BAKU, "res/Image.baku.lzss"
