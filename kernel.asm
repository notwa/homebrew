// not really a kernel,
// just handling some low-level stuff like interrupts.

Start:
    lui     k0, K_BASE

    // copy our interrupt handlers into place.
    lui     t0, 0x8000
    la      t1, _InterruptStart
    la      t2, _InterruptEnd
-
    ld      t3, 0(t1)
    ld      t4, 8(t1)
    addiu   t1, t1, 0x10
    ld      t3, 0(t0)
    sd      t4, 8(t0)
    addiu   t0, t0, 0x10
    bne     t1, t2,-
    cache   1, 0(t0) // not sure if this is necessary, but it doesn't hurt.

    // enable SI and PI interrupts.
    lui     a0, PIF_BASE
    lli     t0, 8
    sw      t0, PIF_RAM+0x3C(a0)

    // SP defaults to RSP instruction memory: 0xA4001FF0
    // we can do better than that.
    lui     sp, K_STACK_INIT_BASE
    // SP should always be 8-byte aligned
    // so that SD and LD instructions don't fail on it.
    subiu   sp, sp, 8

    // TODO: just wipe a portion of RAM?
    sw      r0, K_64DRIVE_MAGIC(k0)
    sw      r0, K_REASON(k0)

Drive64Init:
    lui     gp, CI_BASE
    lui     t2, 0x5544      // "UD" of "UDEV"
    lw      t1, CI_HW_MAGIC(gp)
    ori     t2, t2, 0x4556  // "EV" of "UDEV"

    beq     t1, t2, Drive64Confirmed
    nop

Drive64TryExtended:
    lui     gp, CI_BASE_EXTENDED
    lw      t1, CI_HW_MAGIC(gp)
    bne     t1, t2, Drive64Done
    nop

Drive64Confirmed:
    sw      t2, K_64DRIVE_MAGIC(k0)
    sw      gp, K_CI_BASE(k0)

    // enable writing to cartROM (SDRAM) for USB writing later
    lli     t1, 0xF0

    CI_WAIT()
    sw      t1, CI_COMMAND(gp) // send our command
    CI_WAIT()

Drive64Done:

    // clear internal exception/interrupt value
    ori     k1, r0, r0

    // load up most registers with a dummy value for debugging
    lui     at, 0xCAFE
    ori     at, r0, 0xBABE
    dsllv   at, 32
    // attempting to use this as an address should trigger an interrupt
    ori     at, r0, 0xDEAD
    dsllv   at, 16
    ori     at, r0, 0xBEEF

    // k0, k1, sp intentionally absent
    daddu   v0, at, r0
    daddu   v1, at, r0
    daddu   a0, at, r0
    daddu   a1, at, r0
    daddu   a2, at, r0
    daddu   a3, at, r0
    daddu   t0, at, r0
    daddu   t1, at, r0
    daddu   t2, at, r0
    daddu   t3, at, r0
    daddu   t4, at, r0
    daddu   t5, at, r0
    daddu   t6, at, r0
    daddu   t7, at, r0
    daddu   s0, at, r0
    daddu   s1, at, r0
    daddu   s2, at, r0
    daddu   s3, at, r0
    daddu   s4, at, r0
    daddu   s5, at, r0
    daddu   s6, at, r0
    daddu   s7, at, r0
    daddu   t8, at, r0
    daddu   t9, at, r0
    daddu   gp, at, r0
    daddu   fp, at, r0
    daddu   ra, at, r0

    j       Main
    nop

align(0x10)
_InterruptStart: // for copying purposes
pushvar base

// note that we jump to the handler by jr instead of j
// because we want to change the PC to cached memory,
// which depends on the higher bits that j cannot change.

base 0x80000000
InterruptTBLRefill:
    la      k0, InterruptHandler
    jr      k0
    lli     k1, K_INT_TLB_REFILL

    nops(0x80000080)
InterruptXTLBRefill:
    la      k0, InterruptHandler
    jr      k0
    lli     k1, K_INT_XTLB_REFILL

    nops(0x80000100)
InterruptCacheError: // A0000100?
    la      k0, InterruptHandler
    jr      k0
    lli     k1, K_INT_CACHE_ERROR

    nops(0x80000180)
InterruptOther:
    la      k0, InterruptHandler
    jr      k0
    lli     k1, K_INT_OTHER

nops(0x80000200)
pullvar base
_InterruptEnd: // for copying purposes

InterruptHandler:
    lui     k0, K_BASE
    sw      k1, K_REASON(k0)

    sd      at, K_DUMP+0x08(k0)

    // disable interrupts, clear exception and error level bits:
    mfc0    at, CP0_Status
    sw      at, K_STATUS(k0) // TODO: restored later
    addiu   at, r0, 0xFFFC
    and     k1, k1, at
    mtc0    k1, CP0_Status

    mfc0    k1, CP0_Cause
    sw      k1, K_CAUSE(k0)

    // TODO: option to only store clobbered registers
    // TODO: option to dump COP1 registers too

    sd      r0, K_DUMP+0x00(k0) // intentional (it'd be weird if
                                // r0 showed as nonzero in memory dumps)
    sd      v0, K_DUMP+0x10(k0)
    sd      v1, K_DUMP+0x18(k0)
    sd      a0, K_DUMP+0x20(k0)
    sd      a1, K_DUMP+0x28(k0)
    sd      a2, K_DUMP+0x30(k0)
    sd      a3, K_DUMP+0x38(k0)
    sd      t0, K_DUMP+0x40(k0)
    sd      t1, K_DUMP+0x48(k0)
    sd      t2, K_DUMP+0x50(k0)
    sd      t3, K_DUMP+0x58(k0)
    sd      t4, K_DUMP+0x60(k0)
    sd      t5, K_DUMP+0x68(k0)
    sd      t6, K_DUMP+0x70(k0)
    sd      t7, K_DUMP+0x78(k0)
    sd      s0, K_DUMP+0x80(k0)
    sd      s1, K_DUMP+0x88(k0)
    sd      s2, K_DUMP+0x90(k0)
    sd      s3, K_DUMP+0x98(k0)
    sd      s4, K_DUMP+0xA0(k0)
    sd      s5, K_DUMP+0xA8(k0)
    sd      s6, K_DUMP+0xB0(k0)
    sd      s7, K_DUMP+0xB8(k0)
    sd      t8, K_DUMP+0xC0(k0)
    sd      t9, K_DUMP+0xC8(k0)
    sd      k0, K_DUMP+0xD0(k0)
    sd      k1, K_DUMP+0xD8(k0)
    sd      gp, K_DUMP+0xE0(k0)
    sd      sp, K_DUMP+0xE8(k0)
    sd      fp, K_DUMP+0xF0(k0)
    sd      ra, K_DUMP+0xF8(k0)

    mfhi    t0
    mflo    t1
    sd      t0, K_DUMP+0x100(k0)
    sd      t1, K_DUMP+0x108(k0)

    // free to modify any GPR here

    lui     k0, K_BASE
    ld      t0, K_DUMP+0x100(k0)
    ld      t1, K_DUMP+0x108(k0)
    mthi    t0
    mtlo    t1

    ld      at, K_DUMP+0x08(k0)
    ld      v0, K_DUMP+0x10(k0)
    ld      v1, K_DUMP+0x18(k0)
    ld      a0, K_DUMP+0x20(k0)
    ld      a1, K_DUMP+0x28(k0)
    ld      a2, K_DUMP+0x30(k0)
    ld      a3, K_DUMP+0x38(k0)
    ld      t0, K_DUMP+0x40(k0)
    ld      t1, K_DUMP+0x48(k0)
    ld      t2, K_DUMP+0x50(k0)
    ld      t3, K_DUMP+0x58(k0)
    ld      t4, K_DUMP+0x60(k0)
    ld      t5, K_DUMP+0x68(k0)
    ld      t6, K_DUMP+0x70(k0)
    ld      t7, K_DUMP+0x78(k0)
    ld      s0, K_DUMP+0x80(k0)
    ld      s1, K_DUMP+0x88(k0)
    ld      s2, K_DUMP+0x90(k0)
    ld      s3, K_DUMP+0x98(k0)
    ld      s4, K_DUMP+0xA0(k0)
    ld      s5, K_DUMP+0xA8(k0)
    ld      s6, K_DUMP+0xB0(k0)
    ld      s7, K_DUMP+0xB8(k0)
    ld      t8, K_DUMP+0xC0(k0)
    ld      t9, K_DUMP+0xC8(k0)
    ld      gp, K_DUMP+0xE0(k0)
    ld      sp, K_DUMP+0xE8(k0)
    ld      fp, K_DUMP+0xF0(k0)
    ld      ra, K_DUMP+0xF8(k0)

    lw      k1, K_CAUSE(k0)
    andi    k1, k1, 0x2000 // check if this was a trap exception
    mfc0    k0, CP0_EPC
    beqz    k1, ReturnFromInterrupt
    sw      k0, K_EPC(k0)

ReturnFromTrap:
    addiu   k0, k0, 4

ReturnFromInterrupt:
    // restore interrupts
    mfc0    k1, CP0_Status
    ori     k1, k1, 1
    mtc0    k1, CP0_Status

    // wait, shouldn't this be ERET?
    rfe
    jr      k0
    or      k1, r0, r0

    nops((K_BASE << 16) + 0x10000)
