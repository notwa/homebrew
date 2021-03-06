// a decompressor for the variant of LZSS used by Bomberman 64.
// a matching compressor is available here:
// https://github.com/notwa/baku/blob/master/compressor.c

// this unsafe variant assumes that:
//  * the 0x400 bytes before the destination are readable and null
//  * the input data ends exactly where it is expected to
//  * the input data writes exactly as many bytes as expected
// the performance gain over the safe variant is around 38%.

LzDecomp:
    // a0: pointer to compressed data (must be RDRAM, cart is unsupported)
    // a1: compressed size
    // a2: output pointer
    // a3: maximum uncompressed size
    // v0: error code (0 is OK)

    // t0: current pointer for reading
    // t1: end pointer (exclusive)
    // t2: current pointer for writing
    // t3: end pointer (exclusive)
    // t4: current code, shifted as necessary
    // t5: 1 means raw, 0 means copy
    // t6: either raw byte or part of copy command
    // t7: current pseudo-position
    // t8: match length
    // t9: match position

    beqz    a1, LzExit // nothing to decompress? nothing to do!
    lli     v0, 0

    blez    a3, LzExit
    lli     v0, 1

    or      t0, a0, r0
    addu    t1, a0, a1
    or      t2, a2, r0
    addu    t3, a2, a3

    lli     t7, 0x3BE

LzNextCode:
    // READ
    lbu     t4, 0(t0)
    addiu   t0, 1

    ori     t4, t4, 0x100 // add end marker

    andi    t5, t4, 1
LzReadCode:
    beq     t2, t3, LzExit
    lli     v0, 0

    // READ
    lbu     t6, 0(t0)
    addiu   t0, 1

    beqz    t5, LzCopy
    nop

LzRaw:
    // WRITE
    addiu   t7, 1
    andi    t7, t7, 0x3FF
    sb      t6, 0(t2)
    addiu   t2, 1

    // SHIFT
    srl     t4, 1
    xori    at, t4, 1
    bnez    at, LzReadCode // branch if t4 != 1
    andi    t5, t4, 1

    // reiterate
    bne     t0, t1, LzNextCode
    nop

    b       LzExit
    lli     v0, 0

LzCopy:
    // READ
    lbu     t8, 0(t0)
    addiu   t0, 1

    // extract match position
    sll     t9, t8, 2
    andi    t9, 0x0300
    or      t9, t6

    // extract and prepare match length
    andi    t8, 0x003F
    addiu   t8, 3

    // prepare absolute match position
    subu    t9, t7, t9
    subiu   t9, 1
    andi    t9, 0x03FF
    addiu   t9, 1
    subu    t9, t2, t9

    // preemptively move pseudo-position ahead (don't need it for the loop)
    addu    t7, t8
    andi    t7, t7, 0x3FF

LzCopyLoop:
    // repurposing t6: byte being copied
    lbu     t6, 0(t9)

    // WRITE
    subiu   t8, 1
    sb      t6, 0(t2)
    addiu   t2, 1

    bnez    t8, LzCopyLoop
    addiu   t9, 1

    // SHIFT
    srl     t4, 1
    xori    at, t4, 1
    bnez    at, LzReadCode // branch if t4 != 1
    andi    t5, t4, 1

    // reiterate
    bne     t0, t1, LzNextCode
    nop

    lli     v0, 0

LzExit:
    jr      ra
    nop
