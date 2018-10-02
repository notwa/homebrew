constant FONT_SIZE16(8 * 12 * 2 * 256) // 0xC000

LoadFont16:
    // loads a 256-character, 8x12 font
    // as an RGB5A1 (16-bpp) image to the specified address.
    // a0: address to load font to (size: 0xC000)
    li      t9, FONT_SIZE16 
    addu    a1, a0, t9              // a1: end of output (exclusive)
    la      a2, FONT                // a2: start of input
    la      a3, FONT + FONT.size    // a3: end of input (exclusive)

LoadFont16Loop:
    lbu     t9, 0(a2)
    addiu   a2, 1

    // sign-extend every pixel to get our blacks and whites.
    sll     t1, t9, 24
    sll     t2, t9, 25
    sll     t3, t9, 26
    sll     t4, t9, 27
    sll     t5, t9, 28
    sll     t6, t9, 29
    sll     t7, t9, 30
    sll     t8, t9, 31
    //
    sra     t1, 31
    sra     t2, 31
    sra     t3, 31
    sra     t4, 31
    sra     t5, 31
    sra     t6, 31
    sra     t7, 31
    sra     t8, 31

    sh      t1, 0x0(a0)
    sh      t2, 0x2(a0)
    sh      t3, 0x4(a0)
    sh      t4, 0x6(a0)
    sh      t5, 0x8(a0)
    sh      t6, 0xA(a0)
    sh      t7, 0xC(a0)
    sh      t8, 0xE(a0)

    bne     a2, a3, LoadFont16Loop
    addiu   a0, 0x10

    jr      ra
    nop

DrawChar16:
    // draws a 16-bpp character on-screen at the specified coordinates.
    // a0: font data address (same argument as LoadFont16)
    // a1: character (range: 0 to 255 inclusive)
    // a2: X, Y coordinate in pixels: X | Y << 16
    // a3: output image address

    lli     t9, 8 * 12 * 2
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

    lli     t9, 12          // t9: rows remaining (character height)

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

    jr      ra
    nop

align(16); insert FONT, "res/dwarf.1bpp"
