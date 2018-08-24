Drive64Write:
    // a0: RAM address to copy from
    // a1: length of data to copy in bytes
    // v0: error code (0 is OK)

    // TODO: a0 should be double-word aligned if used directly with DMA
    // assert a0 (RAM address) is word-aligned
    andi    t9, a0, 3
    bnez    t9, Drive64WriteExit
    lli     v0, 1

    // assert a1 (copy length) is word-aligned
    andi    t9, a1, 3
    bnez    t9, Drive64WriteExit
    lli     v0, 2

    blez    a1, Drive64WriteExit // nothing to write? nothing to do!
    lli     v0, 0

    lui     t0, K_BASE
    lw      t1, K_CONSOLE_AVAILABLE(t0)
    beqz    t1, Drive64WriteExit
    lli     v0, 0

    lui     a2, 0x103F // SDRAM destination
    move    a3, a1 // SDRAM length

    // flush the cache at a0 to RAM before doing any DMA
    andi    t6, a0, 0xF
    addu    t7, a0, a1 // stop flushing around here
    subu    t6, a0, t6 // align a0 to data line
-
    cache   1, 0(t6) // data cache Index Writeback Invalidate
    addiu   t6, 0x10 // += data line size
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
    PI_WAIT()

Drive64WriteDirect: // TODO: rewrite so this takes a0,a1 instead of a2,a3
    lli     v0, 0

    lui     at, 0x0100      // set printf channel
    or      a3, a3, at
    lli     t1, 0x08        // WRITE mode
    // SDRAM parameter is given in multiples of halfwords
    li      t9, 0x0FFFFFFF
    and     a2, a2, t9
    srl     a2, a2, 1

    lui     t9, K_BASE
    lw      t9, K_CI_BASE(t9)

    CI_USB_WRITE_WAIT(0x10000) // clobbers t0,v0, requires t9
    bnez    v0, Drive64WriteExit
    nop

    sw      a2, CI_USB_PARAM_RESULT_0(t9)
    PI_WAIT() // yes, these waits seem to be necessary
    sw      a3, CI_USB_PARAM_RESULT_1(t9)
    PI_WAIT()
    sw      t1, CI_USB_COMMAND_STATUS(t9)

    CI_USB_WRITE_WAIT(0x10000) // clobbers t0,v0, requires t9

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
    bnez    v0, DumpAndWriteExit

    or      a0, s0, r0 // delay slot
    jal     Drive64Write
    or      a1, s1, r0
    // v0 passthru

DumpAndWriteExit:
    lw      ra, 0x10(sp)
    lw      s0, 0x14(sp)
    lw      s1, 0x18(sp)
    jr      ra
    addiu   sp, sp, 0x20

DumpRegisters:
    // NOTE: only use this in ISR_Main
    // a0: temp string address
    // a1: temp string maximum length
    // v0: error code (0 is OK)
    // TODO: 64-bit variant
    subiu   sp, 0x30
    sw      ra, 0x10(sp)
    sw      s0, 0x14(sp)
    sw      s1, 0x18(sp)
    sw      s2, 0x1C(sp)
    sw      s3, 0x20(sp)

    slti    at, a1, (4 + 8 + 1) * 34 + 1 // = 443
    bnez    at, DumpRegistersExit
    lli     v0, 1

    la      s0, DumpRegistersStrings
    lui     s1, K_BASE

macro DumpReg(offset) {
    lb      t1, 0(s0)
    lb      t2, 1(s0)
    lb      t3, 2(s0)
    lb      t4, 3(s0)
    sb      t1, 0(a0)
    sb      t2, 1(a0)
    sb      t3, 2(a0)
    sb      t4, 3(a0)
    addiu   a0, 4

    jal     DumpRegistersHelper // a0 passthru
    lw      a1, K_DUMP+{offset}+4(s1)

    or      a0, v0, r0
}

    lli     s2, 0x20 // ascii space
    lli     s3, 0x0A // ascii newline

define DR_i(0)
while {DR_i} < 16 {
    DumpReg({DR_i} * 8)
    sb      s2, 0(a0)
    addiu   a0, 1
    addiu   s0, 16 * 4
    DumpReg({DR_i} * 8 + 0x80)
    sb      s3, 0(a0)
    addiu   a0, 1
    subiu   s0, 16 * 4 - 4
    evaluate DR_i({DR_i} + 1)
}

    // dump HI and LO separately
    addiu   s0, 16 * 4
    DumpReg(32 * 8)
    sb      s2, 0(a0)
    addiu   a0, 1
    addiu   s0, 4
    DumpReg(33 * 8)
    sb      s3, 0(a0)
    addiu   a0, 1

    sb      r0, 0(a0) // null-terminate
    lli     v0, 0

DumpRegistersExit:
    lw      ra, 0x10(sp)
    lw      s0, 0x14(sp)
    lw      s1, 0x18(sp)
    lw      s2, 0x1C(sp)
    lw      s3, 0x20(sp)
    jr      ra
    addiu   sp, 0x20

DumpRegistersHelper:
    // a0: output pointer
    // a1: 32-bit value to dump
    // v0: new output pointer
    andi    t1, a1, 0xF
    srl     t2, a1, 4
    andi    t2, t2, 0xF
    srl     t3, a1, 8
    andi    t3, t3, 0xF
    srl     t4, a1, 12
    andi    t4, t4, 0xF
    srl     t5, a1, 16
    andi    t5, t5, 0xF
    srl     t6, a1, 20
    andi    t6, t6, 0xF
    srl     t7, a1, 24
    andi    t7, t7, 0xF
    srl     t8, a1, 28

macro AsciiNybble(reg, out) {
    sltiu   at, {reg}, 0xA
    bnez    at,+
    addiu   {out}, {reg}, 0x30 // delay slot
    addiu   {out}, {reg}, 0x41 - 0xA
+
}

    AsciiNybble(t8, v0)
    sb      v0, 0(a0)
    AsciiNybble(t7, v0)
    sb      v0, 1(a0)
    AsciiNybble(t6, v0)
    sb      v0, 2(a0)
    AsciiNybble(t5, v0)
    sb      v0, 3(a0)
    AsciiNybble(t4, v0)
    sb      v0, 4(a0)
    AsciiNybble(t3, v0)
    sb      v0, 5(a0)
    AsciiNybble(t2, v0)
    sb      v0, 6(a0)
    AsciiNybble(t1, v0)
    sb      v0, 7(a0)

    jr      ra
    addiu   v0, a0, 8

// each string is assumed to be 4 bytes long
DumpRegistersStrings:
db "r0: ", "at: ", "v0: ", "v1: "
db "a0: ", "a1: ", "a2: ", "a3: "
db "t0: ", "t1: ", "t2: ", "t3: "
db "t4: ", "t5: ", "t6: ", "t7: "
db "s0: ", "s1: ", "s2: ", "s3: "
db "s4: ", "s5: ", "s6: ", "s7: "
db "t8: ", "t9: ", "k0: ", "k1: "
db "gp: ", "sp: ", "fp: ", "ra: "
db "HI: ", "LO: "

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

PokeInstrCache:
    lui     a0, 0x8000
    ori     a1, a0, 16 * 1024 // cache size
-
    cache   0, 0x00(a0)
    cache   0, 0x20(a0)
    cache   0, 0x40(a0)
    cache   0, 0x60(a0)
    cache   0, 0x80(a0)
    cache   0, 0xA0(a0)
    cache   0, 0xC0(a0)
    cache   0, 0xE0(a0)
    addiu   a0, 0x100
    bne     a0, a1,-
    nop
    jr      ra
    nop

PokeCaches:
    subiu   sp, 0x18
    sw      ra, 0x10(sp)
    jal     PokeDataCache
    nop
    jal     PokeInstrCache
    nop
    lw      ra, 0x10(sp)
    jr      ra
    addiu   sp, 0x18
