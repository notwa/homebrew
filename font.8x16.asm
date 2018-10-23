constant FONT_WIDTH(8)
constant FONT_HEIGHT(16)
constant FONT_SIZE16(FONT_WIDTH * FONT_HEIGHT * 2 * 95) // 0x5F00

LoadFont16:
    // loads a 95-character, 8x16 font
    // as an RGB5A1 (16-bpp) image to the specified address.
    // a0: address to load font to (size: 0x5F00)
    li      t9, FONT_SIZE16
    addu    a1, a0, t9              // a1: end of output (exclusive)
    la      a2, FONT                // a2: start of input
    la      a3, FONT + FONT.size    // a3: end of input (exclusive)

LoadFont16Loop:
    lhu     t9, 0(a2)
    addiu   a2, 2

    srl     t1, t9, 12
    srl     t2, t9, 8
    srl     t3, t9, 4
    andi    t4, t9, 0x0F
    andi    t2, 0x0F
    andi    t3, 0x0F

if 0 {
    sll     t1, 2
    sll     t2, 2
    sll     t3, 2
    sll     t4, 2
} else {
    // copy lsb to get the full 5-bit range of values.
    sll     t5, t1, 1
    sll     t6, t2, 1
    sll     t7, t3, 1
    sll     t8, t4, 1
    andi    t1, 1
    andi    t2, 1
    andi    t3, 1
    andi    t4, 1
    or      t1, t5
    or      t2, t6
    or      t3, t7
    or      t4, t8
    sll     t1, 1
    sll     t2, 1
    sll     t3, 1
    sll     t4, 1
}

    sll     t5, t1, 5
    sll     t6, t2, 5
    sll     t7, t3, 5
    sll     t8, t4, 5
    or      t1, t5
    or      t2, t6
    or      t3, t7
    or      t4, t8

    sll     t5, t1, 5
    sll     t6, t2, 5
    sll     t7, t3, 5
    sll     t8, t4, 5
    or      t1, t5
    or      t2, t6
    or      t3, t7
    or      t4, t8

    ori     t1, 1
    ori     t2, 1
    ori     t3, 1
    ori     t4, 1

    sh      t1, 0x0(a0)
    sh      t2, 0x2(a0)
    sh      t3, 0x4(a0)
    sh      t4, 0x6(a0)

    bne     a2, a3, LoadFont16Loop
    addiu   a0, 0x8

    jr      ra
    nop

DrawChar16:
    // draws a 16-bpp character on-screen at the specified coordinates.
    // a0: font data address (same argument as LoadFont16)
    // a1: character (range: 32 to 126 inclusive)
    // a2: X, Y coordinate in pixels: X | Y << 16
    // a3: output image address

    // exit early if character is outside of valid range.
    subiu   a1, 0x20
    bltz    a1, DrawCharDone
    sltiu   at, a1, 0x80 - 0x20
    beqz    at, DrawCharDone

    lli     t9, FONT_WIDTH * FONT_HEIGHT * 2 // delay slot
    multu   a1, t9
    mflo    t9
    addu    a0, t9          // a0: character data address

    andi    a1, a2, 0xFFFF  // a1: X
    srl     a2, 16          // a2: Y

    sll     t0, a1, 1
    lli     t9, WIDTH * 2
    multu   a2, t9
    mflo    t9
    addu    a3, t0 // offset output by X
    addu    a3, t9 // offset output by Y

    lli     t9, FONT_HEIGHT // t9: rows remaining

DrawChar16Loop:
    // character width hardcoded for 8.
    lhu     t1, 0x0(a0)
    lhu     t2, 0x2(a0)
    lhu     t3, 0x4(a0)
    lhu     t4, 0x6(a0)
    lhu     t5, 0x8(a0)
    lhu     t6, 0xA(a0)
    lhu     t7, 0xC(a0)
    lhu     t8, 0xE(a0)

    sh      t1, 0x0(a3)
    sh      t2, 0x2(a3)
    sh      t3, 0x4(a3)
    sh      t4, 0x6(a3)
    sh      t5, 0x8(a3)
    sh      t6, 0xA(a3)
    sh      t7, 0xC(a3)
    sh      t8, 0xE(a3)

    addiu   a0, 0x10
    subiu   t9, 1

    bnez    t9, DrawChar16Loop
    addiu   a3, WIDTH * 2

DrawCharDone:
    jr      ra
    nop

insert FONT, "res/fonts/NotoSansMono-SemiCondensedMedium.16.i4"
