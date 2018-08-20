// settings:
constant K_DEBUG(1) // slows down interrupt handling to enable debug routines

// address stuff:
constant UNCACHED(0xA0000000)
constant ADDR_MASK(0x1FFFFFFF)

constant BLAH_BASE(0x803F)
constant BLAH_COUNTS(0x0010)
constant BLAH_SP_TASK(0x0040)
constant BLAH_DLIST_JUMPER(0x0080)
constant BLAH_XXD(0x0100)
constant BLAH_DLIST(0x1000)

constant VIDEO_C_BUFFER(0x80100000)
constant VIDEO_C_BUFFER_SIZE(640 * 480 * 4)
constant VIDEO_Z_BUFFER(VIDEO_C_BUFFER + VIDEO_C_BUFFER_SIZE)
constant VIDEO_Z_BUFFER_SIZE(640 * 480 * 2)
constant VIDEO_SOMETHING(VIDEO_Z_BUFFER + VIDEO_Z_BUFFER_SIZE)
constant VIDEO_SOMETHING_SIZE(0x18000)
constant VIDEO_STACK(VIDEO_SOMETHING + VIDEO_SOMETHING_SIZE)
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
    nop
}

macro SP_DMA_WAIT() { // from CPU
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
