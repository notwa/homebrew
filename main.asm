arch n64.cpu
endian msb

include "inc/util.inc"
include "inc/n64.inc"
include "inc/64drive.inc"
include "inc/main.inc"
include "inc/kernel.inc"

output "test.z64", create
fill 1052672 // ROM size

origin 0
base 0x80000000

include "header.asm"
insert "bin/6102.bin"
if origin() != 0x1000 {
    error "bad header or bootcode; combined size should be exactly 0x1000"
}

include "kernel.asm"

Main:

if MAIN_DECOMP_IMAGE {
DecompImage:
    lui     s0, MAIN_BASE

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

    lui     a0, MAIN_BASE
    jal     MainDumpWrite
    lli     a1, 0x20
}

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
    mfc0    t0, CP0_Status
    mtc0    t0, CP0_Status

    lui     a0, MAIN_BASE
    ori     a0, MAIN_DLIST
    jal     WriteDList
    or      a1, s1, r0
    jal     PokeDataCache
    nop

    DisableInt()

    // prepare RSP
    lui     a0, SP_BASE
    lli     t0, SP_TASKDONE_CLR | SP_YIELDED_CLR | SP_YIELD_CLR | SP_HALT_SET
    sw      t0, SP_STATUS(a0)

    // set RSP PC to IMEM+$0
    lui     a0, SP_PC_BASE
    // only the lowest 12 bits are used, so 00000000 is equivalent to 04001000.
    sw      r0, SP_PC(a0)

    lui     a0, MAIN_BASE
    jal     PushVideoTask
    ori     a0, MAIN_SP_TASK

    jal     LoadRSPBoot
    nop

    // clear all flags that would halt RSP (i.e. tell it to run!)
    lui     a0, SP_BASE
    lli     t0, SP_INT_ON_BREAK_SET | SP_SINGLE_STEP_CLR | SP_BREAK_CLR | SP_HALT_CLR
    sw      t0, SP_STATUS(a0)

    EnableInt()

MainLoop:
    WriteString(S_SP_Wait)
-
    mfc0    t0, CP0_Status
    mtc0    t0, CP0_Status
    //
    lui     a0, SP_BASE
    lw      t0, SP_STATUS(a0)
    andi    t0, SP_HALT
    beqz    t0,-
    nop

    // queue buffers to swap
    lui     a0, K_BASE
    beqz    s1, SwapToMain
    nop
SwapToAlt:
    la      t0, VIDEO_C_IMAGE_ALT | UNCACHED
    sw      t0, KV_ORIGIN(a0)
    b       +
    lli     s1, 0
SwapToMain:
    la      t0, VIDEO_C_IMAGE | UNCACHED
    sw      t0, KV_ORIGIN(a0)
    lli     s1, 1
+

    // wait on VI too
    WriteString(S_VI_Wait)
    lui     a0, VI_BASE
-
    lw      t0, VI_V_CURRENT_LINE(a0)
    // until half-line <= 2
    sltiu   at, t0, 2 + 1
    beqz    at,-
    nop

    WriteString(SNewFrame)

    j       Start3D
    nop

SetupScreen:
if WIDTH == 640 {
    lli     a0, RES_640_480
} else if WIDTH == 576 {
    lli     a0, RES_576_432
} else if WIDTH == 512 {
    lli     a0, RES_512_448
} else if WIDTH == 320 {
    lli     a0, RES_320_240
} else if WIDTH == 288 {
    lli     a0, RES_288_216
} else if WIDTH == 256 {
    lli     a0, RES_256_224
}

    li      a1, VIDEO_MODE
    la      a2, VIDEO_C_IMAGE | UNCACHED
    j       K_SetScreenNTSC // tail-call
    nop

MainDumpWrite:
    subiu   sp, 0x18
    sw      ra, 0x10(sp)

    lui     a2, MAIN_BASE
    ori     a2, MAIN_XXD
    jal     DumpAndWrite // a0,a1 passthru
    lli     a3, 0x200
    WriteString(KS_Newline)

    lw      ra, 0x10(sp)
    jr      ra
    addiu   sp, 0x18

Die:
    mfc0    t0, CP0_Status
    mtc0    t0, CP0_Status
    j       Die
    nop

KSL(S_SP_Wait, "now waiting on SP")
KSL(S_VI_Wait, "now waiting on VI")
KSL(SNewFrame, "next frame")

if MAIN_DECOMP_IMAGE {
    include "lzss.baku.unsafe.asm"
    align(16); insert LZ_BAKU, "res/Image.baku.lzss"
}
include "dlist.asm"
include "task.asm"

if pc() > (MAIN_BASE << 16) {
    error "ran out of memory for code and data"
}
