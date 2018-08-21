// not really a kernel,
// just handling some low-level stuff like interrupts.

Start:
    mtc0    r0, CP0_Cause // clear cause
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

    // enable SI and PI interrupts.
    lui     a0, PIF_BASE
    lli     t0, 8
    sw      t0, PIF_RAM+0x3C(a0)

    // enable CPU interrupts.
    mfc0    t1, CP0_Status
    ori     t1, t1, CP0_STATUS_IM_ALL
    mtc0    t1, CP0_Status

    // enable even more interrupts.
    lui     t2, MI_BASE
    ori     t2, t2, MI_INTR_MASK
    lli     t0, MI_INTR_MASK_ALL
    sw      t0, 0(t2)

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
    //       or just DMA in the IH and our defaults from ROM...
    sw      r0, K_64DRIVE_MAGIC(gp)
    sw      r0, K_REASON(gp)
    sw      r0, K_IN_MAIN(gp)
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
    KDumpString(KSConsoleConfirmed)
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
    sd      r0, {x}(t0)
evaluate x({x} + 8)
}
    addiu   t0, 0x100
    bne     t0, t1,-
    nop

    // delay to empty pipeline
    nop
    nop
    nop
    nop
    nop

    // try out an interrupt:
//  sw      r0, 0(r0)
//  nop
//  mfc0    t1, CP0_Status
//  ori     t1, 2
//  mtc0    t1, CP0_Status
//  la      t0, WipeRegisters
//  mtc0    t0, CP0_EPC
//  j       InterruptHandler
//  nop

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

    // TODO: option to only store clobbered registers
    // TODO: option to dump COP1 registers too (remember to check Status[FR])

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

    mfc0    k1, CP0_EPC // TODO: check that this is valid?
    sw      k1, K_EPC(k0)

    mfc0    k1, CP0_ErrorPC // TODO: check that this is valid?
    sw      k1, K_ERRORPC(k0)

    mfc0    k1, CP0_BadVAddr
    sw      k1, K_BADVADDR(k0)

    // prevent recursive interrupts if IHMain somehow causes an interrupt
//  lw      t1, K_IN_MAIN(k0)
//  bnez    t1, IHExit // TODO: reimplement properly
    lli     t0, 1
    sw      t0, K_IN_MAIN(k0)

    // be wary, this is a tiny temporary stack!
    ori     sp, k0, K_STACK

IHMain: // free to modify any GPR from here to IHExit

if K_DEBUG {
    KMaybeDumpString(KSNewline)
    KMaybeDumpString(KSHandling)

    ori     a0, k0, K_DUMP + 0x80 * 0
    lli     a1, 0x80
    ori     a2, k0, K_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4

    KMaybeDumpString(KSNewline)

    ori     a0, k0, K_DUMP + 0x80 * 1
    lli     a1, 0x80
    ori     a2, k0, K_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4

    KMaybeDumpString(KSNewline)

    // currently just 0x10 in size: LO and HI registers.
    ori     a0, k0, K_DUMP + 0x80 * 2
    lli     a1, 0x10
    ori     a2, k0, K_XXD
    jal     DumpAndWrite
    lli     a3, 0x10 * 4

    KMaybeDumpString(KSNewline)
    KMaybeDumpString(KSStates)

    ori     a0, k0, K_REASON
    lli     a1, 0x80
    ori     a2, k0, K_XXD
    jal     DumpAndWrite
    lli     a3, 0x80 * 4

    KMaybeDumpString(KSNewline)
    KMaybeDumpString(KSCode)
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
    KMaybeDumpString(KSNewline)

IHExit:
    sw      r0, K_IN_MAIN(k0)

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

    // eret pseudo-code:
    //if status & 4 then
    //  jump to ErrorPC
    //  clear status & 4
    //elseif status & 2 then
    //  jump to EPC
    //  clear status & 2
    //else
    //  raise new exception???
    //end
    eret
    // no branch delay for eret

KCode0:
    KMaybeDumpString(KSCode0)

KMILoop:
    lui     a0, MI_BASE
    lw      s0, MI_INTR(a0)

    beqz    s0,+

    andi    t3, s0, MI_INTR_SP // delay slot
    bnez    t3, KMISP

    andi    t4, s0, MI_INTR_SI // delay slot
    bnez    t4, KMISI

    andi    t3, s0, MI_INTR_AI // delay slot
    bnez    t3, KMIAI

    andi    t4, s0, MI_INTR_VI // delay slot
    bnez    t4, KMIVI

    andi    t3, s0, MI_INTR_PI // delay slot
    bnez    t3, KMIPI

    andi    t4, s0, MI_INTR_DP // delay slot
    bnez    t4, KMIDP
    nop
+

    j       KCodeDone
    nop

// FIXME: camelcase sucks
KMISP:
    KMaybeDumpString(KSMISP)

    lli     t0, CLR_SG3 | CLR_INT // delay slot
    lui     a1, SP_BASE
    sw      t0, SP_STATUS(a1)

    // then check andi t1, SG1 | SG2 ?

    j       KMILoop
    andi    s0, ~MI_INTR_SP

KMISI:
    KMaybeDumpString(KSMISI)

    lui     a1, SI_BASE
    sw      r0, SI_STATUS(a1)

    j       KMILoop
    andi    s0, ~MI_INTR_SI

KMIAI:
    KMaybeDumpString(KSMIAI)

    lli     t0, 0x01
    lui     a1, AI_BASE
    sw      t0, AI_STATUS(a1)

    j       KMILoop
    andi    s0, ~MI_INTR_AI

KMIVI:
    KMaybeDumpString(KSMIVI)

    lui     a1, VI_BASE
    sw      r0, VI_V_CURRENT_LINE(a1)

    j       KMILoop
    andi    s0, ~MI_INTR_VI

KMIPI:
    KMaybeDumpString(KSMIPI)

    lli     t0, 0x02
    lui     a1, PI_BASE
    sw      t0, PI_STATUS(a1)

    j       KMILoop
    andi    s0, ~MI_INTR_PI

KMIDP:
    KMaybeDumpString(KSMIDP)

    lli     t0, 0x800
    lui     a1, MI_BASE
    sw      t0, MI_INIT_MODE(a1)

    j       KMILoop
    andi    s0, ~MI_INTR_DP

KCode1:; KMaybeDumpString(KSCode1); j   KCodeDone; nop
KCode2:; KMaybeDumpString(KSCode2); j   KCodeDone; nop
KCode3:; KMaybeDumpString(KSCode3); j   KCodeDone; nop
KCode4:; KMaybeDumpString(KSCode4); j   KCodeDone; nop
KCode5:; KMaybeDumpString(KSCode5); j   KCodeDone; nop
KCode6:; KMaybeDumpString(KSCode6); j   KCodeDone; nop
KCode7:; KMaybeDumpString(KSCode7); j   KCodeDone; nop
KCode8:; KMaybeDumpString(KSCode8); j   KCodeDone; nop
KCode9:; KMaybeDumpString(KSCode9); j   KCodeDone; nop
KCode10:; KMaybeDumpString(KSCode10); j   KCodeDone; nop
KCode11:; KMaybeDumpString(KSCode11); j   KCodeDone; nop
KCode12:; KMaybeDumpString(KSCode12); j   KCodeDone; nop
KCode13:; KMaybeDumpString(KSCode13); j   KCodeDone; nop
KCode14:; KMaybeDumpString(KSCode14); j   KCodeDone; nop
KCode15:; KMaybeDumpString(KSCode15); j   KCodeDone; nop
KCode16:; KMaybeDumpString(KSCode16); j   KCodeDone; nop
KCode17:; KMaybeDumpString(KSCode17); j   KCodeDone; nop
KCode18:; KMaybeDumpString(KSCode18); j   KCodeDone; nop
KCode19:; KMaybeDumpString(KSCode19); j   KCodeDone; nop
KCode20:; KMaybeDumpString(KSCode20); j   KCodeDone; nop
KCode21:; KMaybeDumpString(KSCode21); j   KCodeDone; nop
KCode22:; KMaybeDumpString(KSCode22); j   KCodeDone; nop
KCode23:; KMaybeDumpString(KSCode23); j   KCodeDone; nop
KCode24:; KMaybeDumpString(KSCode24); j   KCodeDone; nop
KCode25:; KMaybeDumpString(KSCode25); j   KCodeDone; nop
KCode26:; KMaybeDumpString(KSCode26); j   KCodeDone; nop
KCode27:; KMaybeDumpString(KSCode27); j   KCodeDone; nop
KCode28:; KMaybeDumpString(KSCode28); j   KCodeDone; nop
KCode29:; KMaybeDumpString(KSCode29); j   KCodeDone; nop
KCode30:; KMaybeDumpString(KSCode30); j   KCodeDone; nop
KCode31:; KMaybeDumpString(KSCode31); j   KCodeDone; nop

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
KS(KSNewline, 10)
KSL(KSConsoleConfirmed, "USB debug console detected")
KSL(KSHandling, " ~~ Handling Interrupt ~~")
KSL(KSStates, "    Interrupt States:")

KS(KSCode, "    Interrupt Type: ")
KSL(KSCode0, "Regular Interrupt")
KSL(KSCode1, "TLB Modification Exception")
KSL(KSCode2, "TLB Exception (Load/Fetch)")
KSL(KSCode3, "TLB Exception (Store)")
KSL(KSCode4, "Address Error Exception (Load/Fetch)")
KSL(KSCode5, "Address Error Exception (Store)")
KSL(KSCode6, "Bus Error Exception (Fetch)")
KSL(KSCode7, "Bus Error Exception (Load/Store)")
KSL(KSCode8, "SysCall Exception")
KSL(KSCode9, "Breakpoint Exception")
KSL(KSCode10, "Reserved Instruction Exception")
KSL(KSCode11, "Coprocessor Unusable Exception")
KSL(KSCode12, "Arithmetic Overflow Exception")
KSL(KSCode13, "Trap Exception")
KSL(KSCode14, "RESERVED 14")
KSL(KSCode15, "Floating Point Exception")
KSL(KSCode16, "RESERVED 16")
KSL(KSCode17, "RESERVED 17")
KSL(KSCode18, "RESERVED 18")
KSL(KSCode19, "RESERVED 19")
KSL(KSCode20, "RESERVED 20")
KSL(KSCode21, "RESERVED 21")
KSL(KSCode22, "RESERVED 22")
KSL(KSCode23, "Watch")
KSL(KSCode24, "RESERVED 24")
KSL(KSCode25, "RESERVED 25")
KSL(KSCode26, "RESERVED 26")
KSL(KSCode27, "RESERVED 27")
KSL(KSCode28, "RESERVED 28")
KSL(KSCode29, "RESERVED 29")
KSL(KSCode30, "RESERVED 30")
KSL(KSCode31, "RESERVED 31")

KSL(KSMISP, "    Signal Processor Interrupt")
KSL(KSMISI, "    Serial Interface Interrupt")
KSL(KSMIAI, "    Audio Interface Interrupt")
KSL(KSMIVI, "    Video Interface Interrupt")
KSL(KSMIPI, "    Peripheral Interface Interrupt")
KSL(KSMIDP, "    Display Processor Interrupt")
}

align(4)
    nops((K_BASE << 16) + 0x10000)
