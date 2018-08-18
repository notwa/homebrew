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
-
    cache   1, 0(t6) // data cache Index Writeback Invalidate
    addiu   t6, 0x10 // (delay slot) += data line size
    sltu    at, t6, t7
    bnez    at,-
    nop

    // AND off the DRAM address
    li      t9, 0x007FFFFF // __osPiRawStartDma uses 0x1FFFFFFF?
    and     t1, a0, t9

    // cart address
    or      t2, a2, r0

    // set length (needs to be decremented due to DMA quirk)
    subiu   t3, a3, 1

    PI_WAIT()
    sw      t1, PI_DRAM_ADDR(t5)
    sw      t2, PI_CART_ADDR(t5)
    sw      t3, PI_RD_LEN(t5)  // "read" from DRAM to cart
//  PI_WAIT() // if we always wait before doing operations, this shouldn't be necessary

Drive64WriteDirect: // TODO: rewrite so this takes a0, a1 instead of a2, a3
    lui     at, 0x0100      // set printf channel
    or      a3, a3, at
    lli     t1, 0x08        // WRITE mode
    // SDRAM parameter is given in multiples of halfwords
    li      t9, 0x0FFFFFFF
    and     a2, a2, t9
    srl     a2, a2, 1

    lui     t9, K_BASE
    lw      t9, K_CI_BASE(t9)

    CI_USB_WRITE_WAIT() // clobbers t0, requires t9
    sw      a2, CI_USB_PARAM_RESULT_0(t9)
    PI_WAIT() // yes, these waits seem to be necessary
    sw      a3, CI_USB_PARAM_RESULT_1(t9)
    PI_WAIT()
    sw      t1, CI_USB_COMMAND_STATUS(t9)
// if we always wait before doing operations, this shouldn't be necessary:
//  CI_USB_WRITE_WAIT()

Drive64WriteExit:
    jr      ra
    nop

Drive64TestWrite:
    li      a2, 0xA0000020
    lli     a3, 0x20
    j       Drive64WriteDirect
    nop

include "xxd.asm"

DumpAndWrite:
    // a0: source address
    // a1: source length
    // a2: temp string address
    // a3: temp string maximum length
    // v0: error code (0 is OK)
    subiu   sp, sp, 0x20
    sw      ra, 0x10(sp)
    // TODO: can i just use the a0,a1,a2,a3 slots here?
    sw      s0, 0x14(sp)
    sw      s1, 0x18(sp)

    or      s0, a2, r0
    jal     xxd
    or      s1, a3, r0
    // v0 passthru

    bnez    v0, DumpAndWriteExit

    lui     t0, K_BASE // delay slot
    lw      t1, K_64DRIVE_MAGIC(t0)
    beqz    t1, DumpAndWriteExit

    ori     a0, s0, r0 // delay slot
    jal     Drive64Write
    ori     a1, s1, r0
    // v0 passthru

DumpAndWriteExit:
    lw      ra, 0x10(sp)
    lw      s0, 0x14(sp)
    lw      s1, 0x18(sp)
    jr      ra
    addiu   sp, sp, 0x20
