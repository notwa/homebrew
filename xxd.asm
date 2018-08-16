xxd:
    // a0: source address
    // a1: source length
    // a2: destination (string) address
    // a3: destination (string) maximum length
    // v0: error code (0 is OK)
    beqz    a1, xxdExit
    lli     v0, 0 // delay slot
    lli     v1, 0x20 // ascii space

xxdLoop:
    lbu     t0, 0(a0)
    subiu   a1, a1, 1
    addiu   a0, a0, 1

    // split byte into nybbles
    srl     t1, t0, 4
    andi    t0, t0, 0xF
    // convert nybbles to ascii bytes
    sltiu   at, t0, 0xA
    bnez    at,+
    addiu   t2, t0, 0x30 // (delay slot)
    addiu   t2, t0, 0x41 - 0xA
+
    sltiu   at, t1, 0xA
    bnez    at,+
    addiu   t3, t1, 0x30 // (delay slot)
    addiu   t3, t1, 0x41 - 0xA
+

    subiu   a3, a3, 3
    blezl   a3, xxdExit
    lli     v0, 1

    sb      v1, 0(a2) // write space
    sb      t3, 1(a2) // write high nybble
    sb      t2, 2(a2) // write low nybble
    addiu   a2, a2, 3

    // pretty-printing:
    andi    at, a0, 0xF
    bnez    at,+
    lli     t9, 0x0A // (delay slot) ascii newline
    subiu   a3, a3, 1
    blezl   a3, xxdExit
    lli     v0, 1
    sb      t9, 0(a2) // write newline
    b       ++
    addiu   a2, a2, 1 // delay slot
+
    andi    at, a0, 0x3
    bnez    at,+
    nop // delay slot
    subiu   a3, a3, 1
    blezl   a3, xxdExit
    lli     v0, 1
    sb      v1, 0(a2) // write extra space
    addiu   a2, a2, 1
+

    bnez    a1, xxdLoop
    nop // delay slot

    beqz    a3, xxdExit
    nop // delay slot

xxdZero:
    // fill the remaining bytes with nulls
    sb      r0, 0(a2)
    subiu   a3, a3, 1
    bnez    a3, xxdZero
    addiu   a2, a2, 1 // delay slot

xxdExit:
    jr      ra
    nop // delay slot

