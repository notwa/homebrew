constant UNCACHED(0xA0000000)
constant ADDR_MASK(0x1FFFFFFF)

// "kernel" constants:
constant K_BASE(0x8000) // k0 is set to this.
constant K_DUMP(0x0400) // we save registers and state here
                        // when handling interrupts
constant K_REASON(0x0600)
constant K_CAUSE(0x0604)
constant K_STATUS(0x0608)
constant K_EPC(0x060C)
constant K_64DRIVE_MAGIC(0x0700)
constant K_CI_BASE(0x0704)
constant K_STACK(0xC00 - 8)
constant K_XXD(0x0C00) // size: 0x400 (any larger and you overwrite kernel code)

constant K_STACK_INIT_BASE(0x803F) // note that this gets subtracted by 8
                                   // and that the stack grows *backwards.*

// internal interrupt enum: (0 means no known interrupt/exception)
constant K_INT_TLB_REFILL(1)
constant K_INT_XTLB_REFILL(2)
constant K_INT_CACHE_ERROR(3)
constant K_INT_OTHER(4)

constant BLAH_BASE(0x803F)
constant BLAH_COUNTS(0x0010)
constant BLAH_SP_TASK(0x0040)
constant BLAH_DLIST_JUMPER(0x0080)
constant BLAH_XXD(0x0100)

constant VIDEO_BUFFER(0x80100000)
constant VIDEO_BUFFER_SIZE(640 * 480 * 4)
constant VIDEO_STACK(VIDEO_BUFFER + VIDEO_BUFFER_SIZE)
constant VIDEO_STACK_SIZE(0x400)
constant VIDEO_YIELD(VIDEO_STACK + VIDEO_STACK_SIZE)
constant VIDEO_YIELD_SIZE(0xC00)

macro nops(new_pc) {
    while (pc() < {new_pc}) {
        nop
    }
}

macro PI_WAIT() {
    lui     t5, PI_BASE
-
    lw      t0, PI_STATUS(t5)
    andi    t0, t0, 3
    bnez    t0,-
    nop // delay slot
}

macro SP_DMA_WAIT() { // external
    lui     t5, SP_BASE
-
    lw      t0, SP_DMA_FULL(t5)
    bnez    t0,-
    nop
-
    lw      t0, SP_DMA_BUSY(t5)
    bnez    t0,-
    nop
}
