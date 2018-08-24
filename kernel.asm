// not really a kernel,
// just handling some low-level stuff like interrupts.

Start:
    lui     gp, K_BASE

    // copy our interrupt handlers into place.
    lui     t0, 0x8000
    la      t1, _InterruptStart
    la      t2, _InterruptEnd
-
    ld      t3, 0(t1)
    ld      t4, 8(t1)
    addiu   t1, t1, 0x10
    sd      t3, 0(t0)
    sd      t4, 8(t0)
    cache   0x19, 0(t0) // tell data cache to write itself out
    cache   0x10, 0(t0) // tell instruction cache it needs to reload
    // an instruction cache line is 2 rows, and a data cache line is 1 row,
    // so poking at the start of each row is enough to flush them both.
    bne     t1, t2,-
    addiu   t0, t0, 0x10

    // do whatever this does.
    li      a0, 0x01000800
    ctc1    a0, CP1_FCSR
    //
    lui     a0, 0x0490
    mtc0    a0, CP0_WatchLo // is this just anti-gameshark BS?

    // initialize the N64 so it doesn't immediately die.
    SI_WAIT()
    lui     a0, PIF_BASE
    lw      t1, PIF_RAM+0x3C(a0)
    SI_WAIT()
    // the stuff above probably isn't really necessary.
    lli     t1, 8
    lui     a0, PIF_BASE
    sw      t1, PIF_RAM+0x3C(a0)

    // enable CPU interrupts.
    mfc0    t1, CP0_Status
    ori     t1, t1, CP0_STATUS_IM_ALL
    mtc0    t1, CP0_Status

    // enable even more interrupts.
    lui     t2, MI_BASE
    lli     t0, MI_INTR_MASK_ALL_SET
    sw      t0, MI_INTR_MASK(t2)

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
    andi    t0, t0, 3
    bnez    t0,-
    nop
    //
    sw      v0, PI_BSD_DOM1_LAT(t2) // $40
    sw      t9, PI_BSD_DOM1_PGS(t2) // $07
    sw      t5, PI_BSD_DOM1_RLS(t2) // $03
    sw      t7, PI_BSD_DOM1_PWD(t2) // $12

    // SP defaults to RSP instruction memory: 0xA4001FF0
    // we can do better than that.
    lui     sp, K_STACK_INIT_BASE
    // SP should always be 8-byte aligned
    // so that SD and LD instructions don't fail on it.
    // we also need 4 empty words for storing
    // the 32-bit values of the callee's argument registers.
    subiu   sp, sp, 0x10
    sd      r0, 0(sp)
    sd      r0, 8(sp)

    // TODO: just wipe a portion of RAM?
    //       or just DMA in the ISR and our defaults from ROM...
    sw      r0, K_64DRIVE_MAGIC(gp)
    sw      r0, K_REASON(gp)
    sw      r0, K_IN_ISR(gp)
    sw      r0, K_CONSOLE_AVAILABLE(gp)

Drive64Init:
    lui     t9, CI_BASE
    lui     t2, 0x5544      // "UD" of "UDEV"
    lw      t1, CI_HW_MAGIC(t9)
    ori     t2, t2, 0x4556  // "EV" of "UDEV"

    beq     t1, t2, Drive64Confirmed
    nop

Drive64TryExtended:
    lui     t9, CI_BASE_EXTENDED
    lw      t1, CI_HW_MAGIC(t9)
    bne     t1, t2, Drive64Done
    nop

Drive64Confirmed:
    sw      t2, K_64DRIVE_MAGIC(gp)
    sw      t9, K_CI_BASE(gp)

    // enable writing to cartROM (SDRAM) for USB writing later
    lli     t1, 0xF0
    CI_WAIT() // clobbers t0, requires t9
    sw      t1, CI_COMMAND(t9)
    CI_WAIT() // clobbers t0, requires t9

Drive64CheckConsole:
    // NOTE: we only check at boot, so disconnecting the console
    //       while running will cause a ton of lag (timeouts) until reset.
    KDumpString(KS_ConsoleConfirmed)
    lli     t0, 1
    beqzl   v0, Drive64Done
    sw      t0, K_CONSOLE_AVAILABLE(gp)

Drive64Done:

    // zero out RDRAM from 1 MiB to 4 MiB
    // NOTE: this might overwrite the last 4 KiB of ROM that's loaded by 6102?
    li      t0, 0x80100000
    li      t1, 0x80400000
-
define x(0)
while {x} < 0x100 {
    // TODO: is sw faster than sd?
    sd      r0, {x}(t0)
evaluate x({x} + 8)
}
    addiu   t0, 0x100
    bne     t0, t1,-
    nop

WipeRegisters:
    // load up most registers with a dummy value for debugging
    lui     at, 0xCAFE
    ori     at, at, 0xBABE
    dsll    at, 16
    // attempting to use this as an address should trigger an interrupt
    ori     at, at, 0xDEAD
    dsll    at, 16
    ori     at, at, 0xBEEF

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

align(0x10) // align to row for cache-poking purposes
_InterruptStart: // label for copying purposes
pushvar base

// note that we jump to the handler by jr instead of j
// because we want to change the PC to cached memory,
// which depends on the higher bits that j cannot change.

base 0x80000000
Interrupt_TBL_Refill:
    la      k0, InterruptHandler
    jr      k0
    lli     k1, K_INT_TLB_REFILL

    nops(0x80000080)
Interrupt_XTLB_Refill:
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
_InterruptEnd: // label for copying purposes

InterruptHandler:
    lui     k0, K_BASE
    sw      k1, K_REASON(k0)

    sd      at, K_DUMP+0x08(k0)

    // disable interrupts
    mfc0    k1, CP0_Status
    addiu   at, r0, ~CP0_STATUS_IE
    sw      k1, K_STATUS(k0)
    and     k1, k1, at
    mtc0    k1, CP0_Status

    mfc0    k1, CP0_Cause
    sw      k1, K_CAUSE(k0)

    // TODO: dump COP1 registers too (remember to check Status[FR])

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

    mfc0    k1, CP0_EPC // TODO: check validity?
    sw      k1, K_EPC(k0)

    mfc0    k1, CP0_ErrorPC // TODO: check validity?
    sw      k1, K_ERRORPC(k0)

    mfc0    k1, CP0_BadVAddr
    sw      k1, K_BADVADDR(k0)

    // prevent recursive interrupts if ISR_Main somehow causes an interrupt
//  lw      t1, K_IN_ISR(k0)
//  bnez    t1, ISR_Exit // TODO: reimplement properly
    lli     t0, 1
    sw      t0, K_IN_ISR(k0)

    // be wary, this is a tiny temporary stack!
    ori     sp, k0, K_STACK

ISR_Main: // free to modify any GPR from here to ISR_Exit

if K_DEBUG {
    KMaybeDumpString(KS_Newline)
    KMaybeDumpString(KS_Handling)

    ori     a0, k0, K_DUMP + 0x80 * 0
    lli     a1, 0x80
    ori     a2, k0, K_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4

    KMaybeDumpString(KS_Newline)

    ori     a0, k0, K_DUMP + 0x80 * 1
    lli     a1, 0x80
    ori     a2, k0, K_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4

    KMaybeDumpString(KS_Newline)

    // currently just 0x10 in size: LO and HI registers.
    ori     a0, k0, K_DUMP + 0x80 * 2
    lli     a1, 0x10
    ori     a2, k0, K_XXD
    jal     DumpAndWrite
    lli     a3, 0x10 * 4

    KMaybeDumpString(KS_Newline)
    KMaybeDumpString(KS_States)

    ori     a0, k0, K_REASON
    lli     a1, 0x80
    ori     a2, k0, K_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4

    KMaybeDumpString(KS_Newline)
    KMaybeDumpString(KS_Code)
}

    // switch-case on the cause code:
    // conveniently, the ExcCode in Cause is already shifted left by 2.
    lw      t4, K_CAUSE(k0)
    la      t3, KCodes
    andi    t4, CP0_CAUSE_CODE
    addu    t3, t4
    lw      t4, 0(t3)
    jr      t4
    nop
KCodeDone:
    KMaybeDumpString(KS_Newline)

ISR_Exit:
    sw      r0, K_IN_ISR(k0)

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
    andi    k1, k1, CP0_CAUSE_CODE
    xori    k1, k1, CP0_CODE_TR << 2 // check if this was a trap exception
    bnez    k1, ReturnFromInterrupt
    mfc0    k0, CP0_EPC

ReturnFromTrap:
    addiu   k0, k0, 4 // TODO: this probably fails with branch delays?
    mtc0    k0, CP0_EPC

ReturnFromInterrupt:
    // restore interrupts
    mfc0    k1, CP0_Status
    ori     k1, k1, 1
    mtc0    k1, CP0_Status

    eret // jump to EPC or ErrorPC depending on Status
    // no branch delay for eret

KCode0:
    KMaybeDumpString(KS_Code0)

K_MI_Loop:
    lui     a0, MI_BASE
    lw      s0, MI_INTR(a0)

    beqz    s0,+

    andi    t3, s0, MI_INTR_SP // delay slot
    bnez    t3, K_MI_SP

    andi    t4, s0, MI_INTR_SI // delay slot
    bnez    t4, K_MI_SI

    andi    t3, s0, MI_INTR_AI // delay slot
    bnez    t3, K_MI_AI

    andi    t4, s0, MI_INTR_VI // delay slot
    bnez    t4, K_MI_VI

    andi    t3, s0, MI_INTR_PI // delay slot
    bnez    t3, K_MI_PI

    andi    t4, s0, MI_INTR_DP // delay slot
    bnez    t4, K_MI_DP
    nop
+

    j       KCodeDone
    nop

K_MI_SP:
    KMaybeDumpString(KS_MI_SP)

    lli     t0, SP_SG3_CLR | SP_INT_CLR // delay slot
    lui     a1, SP_BASE
    sw      t0, SP_STATUS(a1)

    // then check andi t1, SG1 | SG2 ?

    j       K_MI_Loop
    andi    s0, ~MI_INTR_SP

K_MI_SI:
    KMaybeDumpString(KS_MI_SI)

    lui     a1, SI_BASE
    sw      r0, SI_STATUS(a1)

    j       K_MI_Loop
    andi    s0, ~MI_INTR_SI

K_MI_AI:
    KMaybeDumpString(KS_MI_AI)

    lli     t0, 0x01
    lui     a1, AI_BASE
    sw      t0, AI_STATUS(a1)

    j       K_MI_Loop
    andi    s0, ~MI_INTR_AI

K_MI_VI:
    KMaybeDumpString(KS_MI_VI)

    lui     a1, VI_BASE
    sw      r0, VI_V_CURRENT_LINE(a1)

    j       K_MI_Loop
    andi    s0, ~MI_INTR_VI

K_MI_PI:
    KMaybeDumpString(KS_MI_PI)

    lli     t0, 0x02
    lui     a1, PI_BASE
    sw      t0, PI_STATUS(a1)

    j       K_MI_Loop
    andi    s0, ~MI_INTR_PI

K_MI_DP:
    KMaybeDumpString(KS_MI_DP)

    lli     t0, 0x800
    lui     a1, MI_BASE
    sw      t0, MI_INIT_MODE(a1)

    j       K_MI_Loop
    andi    s0, ~MI_INTR_DP

KCode1:; KMaybeDumpString(KS_Code1); j   KCodeDone; nop
KCode2:; KMaybeDumpString(KS_Code2); j   KCodeDone; nop
KCode3:; KMaybeDumpString(KS_Code3); j   KCodeDone; nop
KCode4:; KMaybeDumpString(KS_Code4); j   KCodeDone; nop
KCode5:; KMaybeDumpString(KS_Code5); j   KCodeDone; nop
KCode6:; KMaybeDumpString(KS_Code6); j   KCodeDone; nop
KCode7:; KMaybeDumpString(KS_Code7); j   KCodeDone; nop
KCode8:; KMaybeDumpString(KS_Code8); j   KCodeDone; nop
KCode9:; KMaybeDumpString(KS_Code9); j   KCodeDone; nop
KCode10:; KMaybeDumpString(KS_Code10); j   KCodeDone; nop
KCode11:; KMaybeDumpString(KS_Code11); j   KCodeDone; nop
KCode12:; KMaybeDumpString(KS_Code12); j   KCodeDone; nop
KCode13:; KMaybeDumpString(KS_Code13); j   KCodeDone; nop
KCode14:; KMaybeDumpString(KS_Code14); j   KCodeDone; nop
KCode15:; KMaybeDumpString(KS_Code15); j   KCodeDone; nop
KCode16:; KMaybeDumpString(KS_Code16); j   KCodeDone; nop
KCode17:; KMaybeDumpString(KS_Code17); j   KCodeDone; nop
KCode18:; KMaybeDumpString(KS_Code18); j   KCodeDone; nop
KCode19:; KMaybeDumpString(KS_Code19); j   KCodeDone; nop
KCode20:; KMaybeDumpString(KS_Code20); j   KCodeDone; nop
KCode21:; KMaybeDumpString(KS_Code21); j   KCodeDone; nop
KCode22:; KMaybeDumpString(KS_Code22); j   KCodeDone; nop
KCode23:; KMaybeDumpString(KS_Code23); j   KCodeDone; nop
KCode24:; KMaybeDumpString(KS_Code24); j   KCodeDone; nop
KCode25:; KMaybeDumpString(KS_Code25); j   KCodeDone; nop
KCode26:; KMaybeDumpString(KS_Code26); j   KCodeDone; nop
KCode27:; KMaybeDumpString(KS_Code27); j   KCodeDone; nop
KCode28:; KMaybeDumpString(KS_Code28); j   KCodeDone; nop
KCode29:; KMaybeDumpString(KS_Code29); j   KCodeDone; nop
KCode30:; KMaybeDumpString(KS_Code30); j   KCodeDone; nop
KCode31:; KMaybeDumpString(KS_Code31); j   KCodeDone; nop

KCodes:
dw      KCode0, KCode1, KCode2, KCode3
dw      KCode4, KCode5, KCode6, KCode7
dw      KCode8, KCode9, KCode10, KCode11
dw      KCode12, KCode13, KCode14, KCode15
dw      KCode16, KCode17, KCode18, KCode19
dw      KCode20, KCode21, KCode22, KCode23
dw      KCode24, KCode25, KCode26, KCode27
dw      KCode28, KCode29, KCode30, KCode31

include "debug.asm"

if K_DEBUG {
KS(KS_Newline, 10)
KSL(KS_ConsoleConfirmed, "USB debug console detected")
KSL(KS_Handling, " ~~ Handling Interrupt ~~")
KSL(KS_States, "    Interrupt States:")

KS(KS_Code, "    Interrupt Type: ")
KSL(KS_Code0, "Regular Interrupt")
KSL(KS_Code1, "TLB Modification Exception")
KSL(KS_Code2, "TLB Exception (Load/Fetch)")
KSL(KS_Code3, "TLB Exception (Store)")
KSL(KS_Code4, "Address Error Exception (Load/Fetch)")
KSL(KS_Code5, "Address Error Exception (Store)")
KSL(KS_Code6, "Bus Error Exception (Fetch)")
KSL(KS_Code7, "Bus Error Exception (Load/Store)")
KSL(KS_Code8, "SysCall Exception")
KSL(KS_Code9, "Breakpoint Exception")
KSL(KS_Code10, "Reserved Instruction Exception")
KSL(KS_Code11, "Coprocessor Unusable Exception")
KSL(KS_Code12, "Arithmetic Overflow Exception")
KSL(KS_Code13, "Trap Exception")
KSL(KS_Code14, "RESERVED 14")
KSL(KS_Code15, "Floating Point Exception")
KSL(KS_Code16, "RESERVED 16")
KSL(KS_Code17, "RESERVED 17")
KSL(KS_Code18, "RESERVED 18")
KSL(KS_Code19, "RESERVED 19")
KSL(KS_Code20, "RESERVED 20")
KSL(KS_Code21, "RESERVED 21")
KSL(KS_Code22, "RESERVED 22")
KSL(KS_Code23, "Watch")
KSL(KS_Code24, "RESERVED 24")
KSL(KS_Code25, "RESERVED 25")
KSL(KS_Code26, "RESERVED 26")
KSL(KS_Code27, "RESERVED 27")
KSL(KS_Code28, "RESERVED 28")
KSL(KS_Code29, "RESERVED 29")
KSL(KS_Code30, "RESERVED 30")
KSL(KS_Code31, "RESERVED 31")

KSL(KS_MI_SP, "    Signal Processor Interrupt")
KSL(KS_MI_SI, "    Serial Interface Interrupt")
KSL(KS_MI_AI, "    Audio Interface Interrupt")
KSL(KS_MI_VI, "    Video Interface Interrupt")
KSL(KS_MI_PI, "    Peripheral Interface Interrupt")
KSL(KS_MI_DP, "    Display Processor Interrupt")
}

align(4)
    nops((K_BASE << 16) + 0x10000)
