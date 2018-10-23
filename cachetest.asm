arch n64.cpu
endian msb

include "inc/util.inc"
include "inc/n64.inc"
include "inc/64drive.inc"

output "cache.z64", create
fill 1052672 // ROM size

origin 0
base 0x80000000

// N64 header:
dw 0x80371240 // PI_BSB_DOM1
dw 0xF // Initial Clock Rate
dw Start // Boot Address Offset
dw 0x1444 // Release Offset
db "CRC1" // CRC1: COMPLEMENT CHECK
db "CRC2" // CRC2: CHECKSUM
dd 0 // unused
db "Cache tests                "
// "123456789012345678901234567"
db 0x00 // Developer ID Code
db 0x00 // Cartridge ID Code
db 0 // unused
db 0x00 // Country Code
db 0 // unused

insert "bin/6102.bin"

if origin() != 0x1000 {
    error "bad header or bootcode; combined size should be exactly 0x1000"
}

constant K_DEBUG(0)
constant K_BASE(0x8000)
constant K_CONSOLE_AVAILABLE(0x0000)
constant K_CI_BASE(0x0004)
constant K_DUMP(0x0020)

constant MAIN_BASE(0x8001)
constant MAIN_FROM(0x0000)
constant MAIN_TO(0x0080)
constant MAIN_FONT(0x4000)

constant WIDTH(576) // 640 * 0.9
constant HEIGHT(432) // 480 * 0.9
constant DEPTH(2)
constant VIDEO_BUFFER(0x80400000 - WIDTH * HEIGHT * DEPTH)
constant VIDEO_MODE(BPP16 | INTERLACE | AA_MODE_2 | DIVOT_EN | PIXEL_ADV_3 | DITHER_FILTER_EN)

constant INIT_STACK(VIDEO_BUFFER - 0x10) // remember, it grows backwards.

macro AsciiNybble(out, reg) {
    sltiu   at, {reg}, 0xA
    bnez    at,+
    addiu   {out}, {reg}, 0x30 // delay slot
    addiu   {out}, {reg}, 0x41 - 0xA
+
}

Start:
    // initialize the N64 so it doesn't immediately die.
    lui     a0, PIF_BASE
    lli     t0, 8
    sw      t0, PIF_RAM+0x3C(a0)

    // no console for this test, just drawing on the screen.
    lui     a0, K_BASE
    sw      r0, K_CONSOLE_AVAILABLE(a0)

    // set up the stack so we can actually call some functions later.
    la      sp, INIT_STACK
    sw      r0, 0x0(sp)
    sw      r0, 0x4(sp)
    sw      r0, 0x8(sp)
    sw      r0, 0xC(sp)

    // clear the screen.
    la      a0, VIDEO_BUFFER
    la      a1, VIDEO_BUFFER + WIDTH * HEIGHT * DEPTH
-
    addiu   a0, 4
    sw      r0, -4(a0)
    bne     a0, a1,-

    // write some dummy data to play with.
    li      t1, 0xDEADBEEF
    li      t2, 0xCAFEBABE
    li      t3, 0xABAD1DEA
    li      t4, 0xADD0BEE5

    lui     a0, MAIN_BASE
    // spaced out a bit just to see what happens.
    sw      t1, 0x00(a0)
    sw      r0, 0x04(a0)
    sw      t2, 0x08(a0)
    sw      r0, 0x0C(a0)
    sw      t3, 0x10(a0)
    sw      r0, 0x14(a0)
    sw      t4, 0x18(a0)
    sw      r0, 0x1C(a0)

    // let's try a DMA despite not having invalidated the writeback cache.
    SP_DMA_WAIT() // clobbers t0,a0

    la      t5, (SP_MEM_BASE << 16) | SP_DMEM
    la      t6, ((MAIN_BASE << 16) | MAIN_FROM) & ADDR_MASK
    li      t7, 0x20 - 1 // DMA transfers always take one less.

    lui     a0, SP_BASE
    sw      t5, SP_MEM_ADDR(a0)
    sw      t6, SP_DRAM_ADDR(a0)
    sw      t7, SP_RD_LEN(a0) // pull data from RDRAM into DMEM/IMEM
    SP_DMA_WAIT() // clobbers t0,a0

    // and back out again, in a different spot.
    la      t6, ((MAIN_BASE << 16) | MAIN_TO) & ADDR_MASK

    sw      t5, SP_MEM_ADDR(a0)
    sw      t6, SP_DRAM_ADDR(a0)
    sw      t7, SP_WR_LEN(a0) // pull data from DMEM/IMEM into RDRAM
    SP_DMA_WAIT() // clobbers t0,a0

if 0 {
    // load results into registers.
    lui     a0, MAIN_BASE
    lw      t1, 0x80(a0)
    lw      t2, 0x88(a0)
    lw      t3, 0x90(a0)
    lw      t4, 0x98(a0)
}

    lui     a0, MAIN_BASE
    jal     LoadFont16
    ori     a0, MAIN_FONT

    // show our results on-screen.
    lli     s0, 16          // s0: X
    lli     s1, 12          // s1: Y
    lli     s2, 0x20 / 4    // s2: number of words to draw
    lui     s3, MAIN_BASE
    ori     s3, MAIN_TO     // s3: start of data to dump
//  ori     s3, MAIN_FROM

MainHexDumpLoop:

    lw      s4, 0(s3)       // s4: current word being drawn

    addiu   s0, 8 * FONT_WIDTH
    lli     s5, 8           // s5: inner loop iteration count

MainHexDumpInnerLoop:
    andi    t0, s4, 0x0F
    subiu   s0, FONT_WIDTH

    lui     a0, MAIN_BASE
    ori     a0, MAIN_FONT
    AsciiNybble(a1, t0)
    sll     a2, s1, 16
    or      a2, s0
    la      a3, VIDEO_BUFFER
    jal     DrawChar16
    nop

    subiu   s5, 1
    bnez    s5, MainHexDumpInnerLoop
    srl     s4, 4

    subiu   s2, 1
    addiu   s1, FONT_HEIGHT
    bnez    s2, MainHexDumpLoop
    addiu   s3, 4

    la      s3, TEXT
DrawTextLoop:
    lbu     a1, 0(s3)
    addiu   s3, 1

    beqz    a1, DrawTextDone

    lli     t0, 0x0D // delay slot
    beq     a1, t0, DrawTextLoop

    lli     t1, 0x0A // delay slot
    bne     a1, t1,+
    nop
    addiu   s1, FONT_HEIGHT // next line
    b       DrawTextLoop
    lli     s0, 16 // return to base X offset
+

    lui     a0, MAIN_BASE // delay slot
    ori     a0, MAIN_FONT
    sll     a2, s1, 16
    or      a2, s0
    la      a3, VIDEO_BUFFER
    jal     DrawChar16

    addiu   s0, FONT_WIDTH // delay slot
    b       DrawTextLoop
    nop

DrawTextDone:
    // use our old cache-poking utility for now.
    jal     PokeDataCache
    nop

    lui     a0, VI_BASE
    li      t1, VIDEO_MODE
    li      t2, VIDEO_BUFFER & ADDR_MASK
    li      t3, WIDTH // width of the buffer in pixels
    li      t4, 0 // interrupt on line, 0 to disable (i think?)
    li      t5, 0 // current line; any write clears VI interrupt
    li      t6, 0x03E52239 // timings (split into 4)
    li      t7, 525 - 1 // lines; subtracting by one enables interlacing
    sw      t1, VI_STATUS(a0)           // offset 0x00
    sw      t2, VI_ORIGIN(a0)           // offset 0x04
    sw      t3, VI_WIDTH(a0)            // offset 0x08
    sw      t4, VI_V_INTR(a0)           // offset 0x0C
    sw      t5, VI_V_CURRENT_LINE(a0)   // offset 0x10
    sw      t6, VI_TIMING(a0)           // offset 0x14
    sw      t7, VI_V_SYNC(a0)           // offset 0x18

    li      t1, 0x00000C15 // divide VI clock to get proper NTSC rate
    li      t2, 0x0C150C15 // likewise (this is only different on PAL)
    li      t3, 0x008C02CC // 576 pixels per row, starting at ... units
    li      t4, 0x003B01EB // 432 pixels per column, starting at ... units
    li      t5, 0x000E0204 // video burst starts at 14 and lasts for 502 units
    li      t6, 0x00000400 // x offset and x step size (inverse scaling)
    li      t7, 0x02000800 // y offset and y step size (inverse scaling)
    // setting y offset to 0.5 (it's Q10 fixed point)
    // reduces interlacing jitter at the cost of a little image sharpness.
    sw      t1, VI_H_SYNC(a0)           // offset 0x1C
    sw      t2, VI_H_SYNC_LEAP(a0)      // offset 0x20
    sw      t3, VI_H_VIDEO(a0)          // offset 0x24
    sw      t4, VI_V_VIDEO(a0)          // offset 0x28
    sw      t5, VI_V_BURST(a0)          // offset 0x2C
    sw      t6, VI_X_SCALE(a0)          // offset 0x30
    sw      t7, VI_Y_SCALE(a0)          // offset 0x34

VideoLoop:
    lui     a0, VI_BASE
    li      t1, VIDEO_BUFFER & ADDR_MASK

-
    // wait until we're done displaying the frame.
    lw      t0, VI_V_CURRENT_LINE(a0)
    sltiu   at, t0, 2 + 1
    beqz    at,-
    nop

    andi    t0, 1   // check if we're on an odd field.
    li      t2, 0x003B01EB
    bnez    t0,+    // if we're not, branch.
    nop
    addiu   t1, WIDTH * DEPTH   // odd field, so offset the image by one row.
    li      t2, 0x003B01E9 // slightly shorter image so that
                           // the y offset doesn't cause sampling out of bounds
+
    sw      t1, VI_ORIGIN(a0)
    sw      t2, VI_V_VIDEO(a0)

    j       VideoLoop
    nop

Die:
    j       Die
    nop

PokeDataCache:
    lui     a0, 0x8000
    ori     a1, a0, 8 * 1024 // cache size
-
    cache   1, 0x00(a0)
    cache   1, 0x10(a0)
    cache   1, 0x20(a0)
    cache   1, 0x30(a0)
    cache   1, 0x40(a0)
    cache   1, 0x50(a0)
    cache   1, 0x60(a0)
    cache   1, 0x70(a0)
    addiu   a0, 0x80
    bne     a0, a1,-
    nop
    jr      ra
    nop

align(16)
insert TEXT, "text.txt"
db 0
align(4)

include "font.8x16.asm"
