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
dw $80371240 // PI_BSB_DOM1
dw $F // Initial Clock Rate
dw Start // Boot Address Offset
dw $1444 // Release Offset
db "CRC1" // CRC1: COMPLEMENT CHECK
db "CRC2" // CRC2: CHECKSUM
dd 0 // unused
db "Cache tests                "
// "123456789012345678901234567"
db $00 // Developer ID Code
db $00 // Cartridge ID Code
db 0 // unused
db $00 // Country Code
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

constant WIDTH(640)
constant HEIGHT(480)
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
    li      t4, 0x12345678

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
    lli     s0, 64          // s0: X
    lli     s1, 48          // s1: Y
    lli     s2, 0x20 / 4    // s2: number of words to draw
    lui     s3, MAIN_BASE
    ori     s3, MAIN_TO     // s3: start of data to dump
//  ori     s3, MAIN_FROM

MainHexDumpLoop:

    lw      s4, 0(s3)       // s4: current word being drawn

    addiu   s0, 8 * 8
    lli     s5, 8           // s5: inner loop iteration count

MainHexDumpInnerLoop:
    andi    t0, s4, 0x0F
    subiu   s0, 8

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
    addiu   s1, 12
    bnez    s2, MainHexDumpLoop
    addiu   s3, 4

    // use our old cache-poking utility for now.
    jal     PokeDataCache
    nop

if 0 {
    ScreenNTSC2(WIDTH, HEIGHT, VIDEO_MODE, VIDEO_BUFFER | UNCACHED)

} else {
    lui     a0, VI_BASE
    li      t1, VIDEO_MODE
    li      t2, VIDEO_BUFFER | UNCACHED
    li      t3, 0x00000280
    li      t4, 0 // 0x00000200
    li      t5, 0x00000000
    li      t6, 0x03E52239
    li      t7, 0x0000020C
    sw      t1, 4 *  0(a0)
    sw      t2, 4 *  1(a0)
    sw      t3, 4 *  2(a0)
    sw      t4, 4 *  3(a0)
    sw      t5, 4 *  4(a0)
    sw      t6, 4 *  5(a0)
    sw      t7, 4 *  6(a0)

    li      t1, 0x00000C15
    li      t2, 0x0C150C15
    li      t3, 0x006C02EC
    li      t4, 0x002301FD
    li      t5, 0x000E0204
    li      t6, 0x00000400
    li      t7, 0x02000800
    sw      t1, 4 *  7(a0)
    sw      t2, 4 *  8(a0)
    sw      t3, 4 *  9(a0)
    sw      t4, 4 * 10(a0)
    sw      t5, 4 * 11(a0)
    sw      t6, 4 * 12(a0)
    sw      t7, 4 * 13(a0)

}

VideoLoop:
    WaitScanline(2)

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

include "font.asm"
