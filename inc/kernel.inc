// "kernel" constants:
constant K_BASE(0x8000) // k0 is set to this.

constant K_DUMP(0x0400) // we save registers and state here
                        // when handling interrupts

constant K_REASON(0x0600)
constant K_CAUSE(0x0604)
constant K_STATUS(0x0608)
constant K_IN_ISR(0x060C)
constant K_EPC(0x0610)
constant K_ERRORPC(0x0614)
constant K_BADVADDR(0x0618)
constant K_HISTORY(0x061C)

constant K_64DRIVE_MAGIC(0x0700)
constant K_CI_BASE(0x0704)
constant K_CONSOLE_AVAILABLE(0x0708)

constant K_STACK(0x0C00 - 0x10)
constant K_XXD(0x0C00) // size: 0x400 (any larger and you overwrite kernel code)

// note this gets subtracted by 0x10 and the stack grows *backwards.*
constant K_STACK_INIT(0x800F9000) // size: a measly 36 KiB

// internal interrupt enum: (0 means no known interrupt/exception)
constant K_INT_TLB_REFILL(1)
constant K_INT_XTLB_REFILL(2)
constant K_INT_CACHE_ERROR(3)
constant K_INT_OTHER(4)

macro _WriteString(name) {
if K_DEBUG {
    // does not include error/console-checking!
    // note: this first instruction must be okay to be in a delay slot.
    la      a2, {name}
    jal     Drive64WriteDirect
    lli     a3, {name}X - {name}
}
}

macro WriteString(str) {
if K_DEBUG {
    lui     t0, K_BASE
    lw      t1, K_CONSOLE_AVAILABLE(t0)
    beqz    t1,+
    _WriteString({str})
+
}
}

macro KWriteString(str) {
if K_DEBUG {
    lw      t1, K_CONSOLE_AVAILABLE(k0)
    beqz    t1,+
    _WriteString({str})
+
}
}

macro KS(name, str) {
    align(16)
{name}:
    db {str}, 0
    align(16)
{name}X:
}

macro KSL(name, str) {
    align(16)
{name}:
    db {str}, 10, 0
    align(16)
{name}X:
}
