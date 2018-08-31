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

include "lzss.baku.unsafe.asm"
include "dlist.asm"
include "task.asm"

//align(16); insert FONT, "res/dwarf.1bpp"
//align(16); insert LZ_BAKU, "res/Image.baku.lzss"

if pc() > (MAIN_BASE << 16) {
    error "ran out of memory for code and data"
}
