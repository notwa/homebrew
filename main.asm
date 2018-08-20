// built on the N64 ROM template by krom
arch n64.cpu
endian msb
include "inc/n64.inc"
include "inc/n64_gfx.inc"
include "inc/64drive.inc"

output "test.z64", create
fill 1052672 // Set ROM Size

origin 0x00000000
base 0x80000000

include "header.asm"
insert "bin/6102.bin"
// after inserting the header and bootrom,
// origin should be at 0x1000.

include "inc/main.inc"

include "inc/kernel.inc"
include "kernel.asm"

    nops(0x80010000)

Main:
    lui     t0, K_BASE

    lui     s0, BLAH_BASE
    mfc0    t1, CP0_Status+0
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
    // TODO: flush cache on color buffer

    mfc0    t0, CP0_Count
    nop; nop; nop; nop

    lw      t1, BLAH_COUNTS+0(s0)
    sw      t0, BLAH_COUNTS+8(s0)
    subu    t1, t0, t1
    sw      t1, BLAH_COUNTS+0xC(s0)

    // FIXME: this is triggering a PI interrupt somehow,
    //        which is causing the IH debug output to be repeated instead!
    lui     a0, BLAH_BASE
    lli     a1, 0x20
    ori     a2, a0, BLAH_XXD
    jal     DumpAndWrite
    lli     a3, 0x20 * 4

InitVideo:
    jal     LoadRSPBoot
    nop

    lui     a0, BLAH_BASE
    jal     PushVideoTask
    ori     a0, a0, BLAH_SP_TASK

    jal     SetupScreen
    nop

    mfc0    t0, CP0_Count
    sw      t0, BLAH_COUNTS+0xC(s0)

TestRDP:
if 0 {
    // take a peek at the stuff at the Task data we wrote
    lui     a0, BLAH_BASE
    ori     a0, a0, BLAH_SP_TASK
    lli     a1, 0x80
    ori     a2, a0, BLAH_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4
}

    // write the jump to our actual instructions
    lui     a0, BLAH_BASE
    lui     t0, 0xDE01 // jump (no push)
    sw      t0, BLAH_DLIST_JUMPER+0(a0)
    ori     t1, a0, BLAH_DLIST
    sw      t1, BLAH_DLIST_JUMPER+4(a0)

define dpos(BLAH_DLIST)
macro WriteDL(evaluate L, evaluate R) {
    lui     t0, ({L} >> 16) & 0xFFFF
    lui     t1, ({R} >> 16) & 0xFFFF
    ori     t0, {L} & 0xFFFF
    ori     t1, {R} & 0xFFFF
    sw      t0, {dpos}+0(a0)
    sw      t1, {dpos}+4(a0)
global evaluate dpos({dpos}+8)
if {dpos} >= 0x8000 {
    error "much too much"
    // FIXME: just add dpos to a0 and set dpos to 0 when this happens
}
}

    // write some F3DZEX instructions

{
    // G_RDPPIPESYNC
    WriteDL(0xE7000000, 0)

    // G_TEXTURE (disable tile descriptor; dummy second argument)
    WriteDL(0xD7000000, 0xFFFFFFFF)

    // G_SETCOMBINE (too complicated to explain here...)
    WriteDL(0xFCFFFFFF, 0xFFFE793C)

    // G_RDPSETOTHERMODE (set higher flags, clear all lower flags)
    // 0011 1000 0010 1100 0011 0000
    // G_AD_DISABLE | G_CD_MAGICSQ | G_TC_FILT | G_TF_BILERP |
    // G_TT_NONE | G_TL_TILE | G_TD_CLAMP | G_MDSFT_TEXTPERSP |
    // G_CYC_FILL | G_PM_NPRIMITIVE
    WriteDL(0xEF382C30, 0x00000000)

    // G_GEOMETRYMODE
    // set some bits (TODO: which?), clear none
    WriteDL(0xD9000000, 0x00220405)

    // G_SETSCISSOR     coordinate order: (top, left), (right, bottom)
    WriteDL(0xED000000 | (0 << 14) | (0 << 2), (320 << 14) | (240 << 2))

    // G_SETBLENDCOLOR
    // sets alpha component to 8, everything else to 0
    WriteDL(0xF9000000, 0x00000008)

    // sets near-far plane clipping? maybe?
    // G_MOVEWORD, sets G_MW_CLIP+$0004
    WriteDL(0xDB040004, 2)
    // G_MOVEWORD, sets G_MW_CLIP+$000C
    WriteDL(0xDB04000C, 2)
    // G_MOVEWORD, sets G_MW_CLIP+$0014
    WriteDL(0xDB040014, 0x10000 - 2)
    // G_MOVEWORD, sets G_MW_CLIP+$001C
    WriteDL(0xDB04001C, 0x10000 - 2)

    // G_ENDDL: absent since we're not jumping to this routine
}

    // G_SETCIMG, set our color buffer (fmt 0, bit size %10, width)
    WriteDL(0xFF100000 | (640 - 1), VIDEO_C_BUFFER)

    // G_SETZIMG, set our z buffer (fmt 0, bit size %00, width)
    WriteDL(0xFE000000, VIDEO_Z_BUFFER)

    // G_SETFILLCOLOR
    WriteDL(0xF7000000, 0xFFFFFFFF)

    // G_FILLRECT       coordinate order: (right, bottom), (top, left)
    // note that the coordinates are all inclusive!
    WriteDL(0xF6000000 | (199 << 14) | (199 << 2), (100 << 14) | (100 << 2))

    // G_RDPPIPESYNC
    WriteDL(0xE7000000, 0)

    // always finish it off by telling RDP to stop!
    // G_RDPFULLSYNC, G_ENDDL
    WriteDL(0xE9000000, 0); WriteDL(0xDF000000, 0)

    // take a peek at the display list we wrote
    lui     a0, BLAH_BASE
    ori     a0, BLAH_DLIST
    lli     a1, 0x80
    ori     a2, a0, BLAH_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4

    // stuff i'm borrowing from zelda:
    lui     a0, SP_BASE
    lli     t0, CLR_SG2 | CLR_SG1 | CLR_SG0 | SET_IOB
    sw      t0, SP_STATUS(a0)

    // NOTE: we should be asserting here that SP_STATUS & 1 != 0
    // set RSP PC to IMEM+$0
    lui     a0, SP_PC_BASE
    li      t0, 0x04001000
    sw      t0, SP_PC(a0)

    // tell RSP to run by clearing flags
    lui     a0, SP_BASE
    lli     t0, SET_IOB | CLR_STP | CLR_BRK | CLR_HLT
    sw      t0, SP_STATUS(a0)
    nop

    // also one thing i noticed in zelda is they set VI_V_INTR to 2
    // so they get interrupts with scanlines (unlike us who just waits)

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
    // NTSC: 640x480, 32BPP, Interlace, Resample Only, DRAM Origin VIDEO_C_BUFFER
    ScreenNTSC(640, 480, BPP32|INTERLACE|AA_MODE_2, VIDEO_C_BUFFER | UNCACHED)
    jr      ra
    nop

LoadRSPBoot:
    li      t2, F3DZEX_BOOT
    li      t3, F3DZEX_BOOT.size
    subiu   t3, t3, 1 // DMA quirk
    SP_DMA_WAIT() // clobbers t0, t5
//  ori     t1, t5, 0x1000
    la      t1, 0xA4001000
    sw      t1, SP_MEM_ADDR(t5)
    sw      t2, SP_DRAM_ADDR(t5)
    sw      t3, SP_RD_LEN(t5) // pull data from RDRAM into DMEM/IMEM
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
    li      t2, VIDEO_SOMETHING & ADDR_MASK
    li      t3, (VIDEO_SOMETHING & ADDR_MASK) + VIDEO_SOMETHING_SIZE // end pointer (not size!)
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
//  ori     t1, t5, 0xFC0
    la      t1, 0xA4000FC0
    sw      t1, SP_MEM_ADDR(t5)
    sw      a0, SP_DRAM_ADDR(t5)
    sw      t3, SP_RD_LEN(t5) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

include "lzss.baku.unsafe.asm"

align(16); insert F3DZEX_BOOT, "bin/F3DZEX2.boot.bin"
align(16); insert F3DZEX_DMEM, "bin/F3DZEX2.data.bin"
align(16); insert F3DZEX_IMEM, "bin/F3DZEX2.bin"
align(16); insert FONT, "res/dwarf.1bpp"
align(16); insert LZ_BAKU, "res/Image.baku.lzss"
