    // copy our interrupt handlers into place.
    lui     t0, 0x8000
    la      t1, _InterruptStart
    la      t2, _InterruptEnd
-
    ld      t3, 0(t1)
    ld      t4, 8(t1)
    addiu   t1, 0x10
    sd      t3, 0(t0)
    sd      t4, 8(t0)
    cache   0x19, 0(t0) // tell data cache to write itself out
    cache   0x10, 0(t0) // tell instruction cache it needs to reload
    // an instruction cache line is 2 rows, and a data cache line is 1 row,
    // so poking at the start of each row is enough to flush them both.
    bne     t1, t2,-
    addiu   t0, 0x10

    // flush denormals to 0 and enable invalid operations
    li      a0, 0x01000800 // TODO: use flag constants
    ctc1    a0, CP1_FCSR
    // is this just anti-gameshark BS?
    lui     a0, 0x0490
    mtc0    a0, CP0_WatchLo

    // initialize the N64 so it doesn't immediately die.
    SI_WAIT()
    lui     a0, PIF_BASE
    lw      t1, PIF_RAM+0x3C(a0)
    SI_WAIT()
    // the stuff above probably isn't really necessary.
    lli     t1, 8
    lui     a0, PIF_BASE
    sw      t1, PIF_RAM+0x3C(a0)

    // initialize TLB
    lli     t1, 0x1E
    lui     t2, 0x8000
    mtc0    t2, CP0_EntryHi
    mtc0    r0, CP0_EntryLo0
    mtc0    r0, CP0_EntryLo1
-
    mtc0    t1, CP0_Index
    nop
    tlbwi
    nop
    nop
    subiu   t1, 1
    bgez    t1,-
    nop
    mtc0    r0, CP0_EntryHi

    // fill TLB
    lli     t1, 0x1F
    mtc0    t1, CP0_Index
    mtc0    r0, CP0_PageMask
    lui     t1, 0xC000
    mtc0    t1, CP0_EntryHi
    li      t3, 0x02000017
    mtc0    t3, CP0_EntryLo0
    lli     t1, 1
    mtc0    t1, CP0_EntryLo1
    nop
    tlbwi
    nop
    nop
    nop
    nop
    mtc0    r0, CP0_EntryHi

    // set BSD DOM1 stuff, whatever that is.
    lui     v1, CART_DOM1_ADDR2
    lw      v0, 0(v1)
    srl     t8, v0, 16
    srl     t4, v0, 20
    andi    t9, t8, 0xF // t9=$07
    andi    t5, t4, 0xF // t5=$03
    srl     t7, v0, 8
    //
    andi    t7, 0xFF    // t7=$12
    andi    v0, 0xFF    // v0=$40
    // wait for PI
    lui     t2, PI_BASE
-
    lw      t0, PI_STATUS(t2)
    andi    t0, 3
    bnez    t0,-
    nop
    //
    sw      v0, PI_BSD_DOM1_LAT(t2) // $40
    sw      t9, PI_BSD_DOM1_PGS(t2) // $07
    sw      t5, PI_BSD_DOM1_RLS(t2) // $03
    sw      t7, PI_BSD_DOM1_PWD(t2) // $12

    // clear DPC counters
    lui     a0, DPC_BASE
    lli     t0, DPC_TMC_CLR | DPC_PLC_CLR | DPC_CMC_CLR | DPC_CLK_CLR
    sw      t0, DPC_STATUS(a0)

    // enable CPU interrupts.
    mfc0    t1, CP0_Status
    ori     t1, CP0_STATUS_IM_ALL | CP0_STATUS_IE
    mtc0    t1, CP0_Status

    // enable even more interrupts.
    lui     t2, MI_BASE
    lli     t0, MI_INTR_MASK_ALL_SET
    sw      t0, MI_INTR_MASK(t2)
