// debug routines for the 64drive, not a real devcart!

Drive64Write:
    // a0: RAM address to copy from
    // a1: length of data to copy in bytes
    // v0: error code (0 is OK)

    // TODO: a0 should be double-word aligned if used directly with DMA

    // assert a0 (RAM address) is word-aligned
    andi    t9, a0, 3
    bnezl   t9, Drive64WriteExit
    lli     v0, 1

    // assert a1 (copy length) is word-aligned
    andi    t9, a1, 3
    bnezl   t9, Drive64WriteExit
    lli     v0, 2

    blez    a1, Drive64WriteExit // nothing to write? nothing to do!
    lli     v0, 0 // delay slot

    lui     a2, 0x103F // SDRAM destination
    move    a3, a1 // SDRAM length

    // flush the cache at a0 to RAM before doing any DMA
    andi    t6, a0, 0xF
    addu    t7, a0, a1 // stop flushing around here
    subu    t6, a0, t6 // align a0 to data line
    subiu   t7, t7, 1 // turn inclusive end-point into exclusive instead
-
    cache   1, 0(t6) // peter says: "Index Writeback Invalidate"
    sltu    at, t6, t7
    bnez    at,-
    addiu   t6, 0x10 // (delay slot) += data line size

    // AND off the DRAM address
    li      t9, 0x007FFFFF // __osPiRawStartDma uses 0x1FFFFFFF?
    and     t1, a0, t9

    // cart address
    move    t2, a2

    // set length (needs to be decremented due to DMA quirk)
    subiu   t3, a3, 1

    PI_WAIT()
    sw      t1, PI_DRAM_ADDR(t5)
    sw      t2, PI_CART_ADDR(t5)
    sw      t3, PI_RD_LEN(t5)  // "read" from DRAM to cart
//  PI_WAIT() // if we always wait before doing operations, this shouldn't be necessary

Drive64TestPoint:
    lui     at, 0x0100      // set printf channel
    or      a3, a3, at
    lli     t1, 0x08        // WRITE mode
    // SDRAM parameter is given in multiples of halfwords
    li      t9, 0x0FFFFFFF
    and     a2, a2, t9
    srl     a2, a2, 1

    CI_USB_WRITE_WAIT()
    sw      a2, CI_USB_PARAM_RESULT_0(gp)
    PI_WAIT() // yes, these waits seem to be necessary
    sw      a3, CI_USB_PARAM_RESULT_1(gp)
    PI_WAIT()
    sw      t1, CI_USB_COMMAND_STATUS(gp)
//  CI_USB_WRITE_WAIT() // if we always wait before doing operations, this shouldn't be necessary

Drive64WriteExit:
    jr      ra
    nop // delay slot

Drive64TestWrite:
    li      a2, 0xA0000020
    lli     a3, 0x20
    j       Drive64TestPoint
    nop // delay slot
