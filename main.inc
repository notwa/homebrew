constant UNCACHED(0xA0000000)
constant ADDR_MASK(0x1FFFFFFF)

constant BLAH_BASE(0x803F)
constant BLAH_CONFIRMED(0x0000)
constant BLAH_CI_BASE(0x0004)
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

macro CI_WAIT() {
    PI_WAIT()
-
    lw      t0, CI_STATUS(gp)
    srl     t0, t0, 12 // first 12 bits are reserved, so ignore them
    bnez    t0,-
    nop // delay slot
}

macro CI_USB_WRITE_WAIT() {
    PI_WAIT()
-
    lw      t0, CI_USB_COMMAND_STATUS(gp)
    srl     t0, t0, 4 // shift out ARM status, leaving WRITE status
    bnez    t0,-
    nop // delay slot
}

