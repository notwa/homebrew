// built on the N64 ROM template by krom
arch n64.cpu
endian msb

include "inc/util.inc"
include "inc/n64.inc"
include "inc/64drive.inc"
include "inc/main.inc"
include "inc/kernel.inc"

output "test.z64", create
fill 1052672 // ROM size

origin 0x00000000
base 0x80000000

include "header.asm"
insert "bin/6102.bin"
if origin() != 0x1000 {
    error "bad header or bootcode; combined size should be exactly 0x1000"
}

include "kernel.asm"

Main:
    lui     s0, MAIN_BASE

if 0 {
    nop; nop; nop; nop
    mfc0    t0, CP0_Count
    sw      t0, MAIN_COUNTS+0(s0)

    // decompress our picture
    la      a0, LZ_BAKU + 4
    lw      a3, -4(a0) // load uncompressed size from the file itself
    li      a1, LZ_BAKU.size - 4
    li      a2, VIDEO_C_IMAGE
    jal     LzDecomp
    nop

    mfc0    t0, CP0_Count
    nop; nop; nop; nop

    lw      t1, MAIN_COUNTS+0x0(s0)
    sw      t0, MAIN_COUNTS+0x4(s0)
    subu    t1, t0, t1
    sw      t1, MAIN_COUNTS+0xC(s0)

    jal     PokeDataCache
    nop
}

    lui     a0, MAIN_BASE
    lli     a1, 0x20
    ori     a2, a0, MAIN_XXD
    jal     DumpAndWrite
    lli     a3, 0x20 * 4
    WriteString(KS_Newline)

Test3D:
    // write the jump to our actual commands
    lui     a0, MAIN_BASE
    lui     t0, 0xDE01 // jump (no push)
    ori     t1, a0, MAIN_DLIST
    sw      t0, MAIN_DLIST_JUMPER+0(a0)
    sw      t1, MAIN_DLIST_JUMPER+4(a0)

    jal     SetupScreen
    nop

    lli     s1, 1 // s1: which color buffer we're writing to (1: alt)

Start3D:
    lui     a0, MAIN_BASE
    ori     a0, MAIN_DLIST
    jal     WriteDList
    or      a1, s1, r0
    jal     PokeDataCache
    nop

    ClearIntMask()

    // prepare RSP
    lui     a0, SP_BASE
    lli     t0, SP_SG2_CLR | SP_SG1_CLR | SP_SG0_CLR | SP_INT_ON_BREAK_SET
    sw      t0, SP_STATUS(a0)

    SP_HALT_WAIT()

    // set RSP PC to IMEM+$0
    lui     a0, SP_PC_BASE
    // only the lowest 12 bits are used, so 00000000 is equivalent to 04001000.
    sw      r0, SP_PC(a0)

    lui     a0, MAIN_BASE
    jal     PushVideoTask
    ori     a0, a0, MAIN_SP_TASK

    SP_DMA_WAIT()

    jal     LoadRSPBoot
    nop

    SP_DMA_WAIT()

    // clear all flags that would halt RSP (i.e. tell it to run!)
    lui     a0, SP_BASE
    lli     t0, SP_INT_ON_BREAK_SET | SP_SINGLE_STEP_CLR | SP_BREAK_CLR | SP_HALT_CLR
    sw      t0, SP_STATUS(a0)
    nop

    SetIntMask()

MainLoop:
    SP_HALT_WAIT()

    WriteString(SPreFrame)

    // wait on VI too
-
    lui     t0, VI_BASE
    lw      t0, VI_V_CURRENT_LINE(t0)
    // until line <= 3
    sltiu   t0, 4 // larger values seem to die on N64 (cen64 has no problem)
    beqz    t0,-
    nop

    WriteString(SNewFrame)

    // swap buffers
    lui     a0, VI_BASE
    beqz    s1, SwitchToAlt
    nop
SwitchToMain:
    la      t0, VIDEO_C_IMAGE_ALT
    sw      t0, VI_ORIGIN(a0)
    j       Start3D
    lli     s1, 0
SwitchToAlt:
    la      t0, VIDEO_C_IMAGE
    sw      t0, VI_ORIGIN(a0)
    j       Start3D
    lli     s1, 1

KSL(SPreFrame, "now waiting for VI")
KSL(SNewFrame, "next frame")

SetupScreen:
if HICOLOR {
    ScreenNTSC(WIDTH, HEIGHT, BPP32|INTERLACE|AA_MODE_2, VIDEO_C_IMAGE | UNCACHED)
} else {
    ScreenNTSC(WIDTH, HEIGHT, BPP16|AA_MODE_2, VIDEO_C_IMAGE | UNCACHED)
}
    jr      ra
    nop

PushVideoTask:
    // a0: Task RDRAM Pointer (size: 0x40) (should probably be row-aligned)
    subiu   sp, sp, 0x18
    sw      ra, 0x10(sp)

    lli     t0, 1 // mode: video
    lli     t1, TASK_DP_WAIT // flags
    li      t2, UCODE_BOOT // does not need masking (not actually used?)
    li      t3, UCODE_BOOT.size
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
    li      t2, VIDEO_OUTPUT & ADDR_MASK
    // most commercial games re-use the yield pointer, so i assume it's fine:
    li      t3, VIDEO_YIELD & ADDR_MASK // stores output buffer size
    li      t4, ((MAIN_BASE << 16) | MAIN_DLIST_JUMPER) & ADDR_MASK // initial DList
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
    or      t4, a0, r0
    SP_DMA_WAIT() // clobbers t0, a0
    la      t1, 0xA4000FC0
    sw      t1, SP_MEM_ADDR(a0)
    sw      t4, SP_DRAM_ADDR(a0)
    sw      t3, SP_RD_LEN(a0) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

LoadRSPBoot:
    la      t2, UCODE_BOOT & ADDR_MASK
    li      t3, UCODE_BOOT.size
    subiu   t3, t3, 1 // DMA quirk
    SP_DMA_WAIT() // clobbers t0, a0
    la      t1, 0xA4001000
    sw      t1, SP_MEM_ADDR(a0)
    sw      t2, SP_DRAM_ADDR(a0)
    sw      t3, SP_RD_LEN(a0) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

include "lzss.baku.unsafe.asm"
include "dlist.asm"

align(16); insert UCODE_BOOT, "bin/common.boot.bin"
align(16); insert F3DZEX_IMEM, "bin/F3DZEX2.bin"
align(16); insert F3DZEX_DMEM, "bin/F3DZEX2.data.bin"

//align(16); insert FONT, "res/dwarf.1bpp"
//align(16); insert LZ_BAKU, "res/Image.baku.lzss"

if pc() > (MAIN_BASE << 16) {
    error "ran out of memory for code and data"
}
