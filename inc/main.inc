// settings:
constant K_DEBUG(0) // slows down interrupt handling to enable debug routines
constant HIRES(0)
constant HICOLOR(0)

constant MAIN_DECOMP_IMAGE(HIRES & HICOLOR)

constant MAIN_BASE(0x800E)
constant MAIN_COUNTS(0x0010)
constant MAIN_SP_TASK(0x0040)
constant MAIN_XXD(0x0080)
constant MAIN_DLIST(0x1000)
constant MAIN_DLIST_SIZE(0xF000)
constant MAIN_DLIST_JUMPER(MAIN_DLIST - 0xA8)

if HIRES {
    constant WIDTH(640)
    constant HEIGHT(480)
} else {
    constant WIDTH(320)
    constant HEIGHT(240)
}

if HIRES {
    if HICOLOR {
        // 640x480, 32-bit
        constant VIDEO_MODE(BPP32 | INTERLACE | AA_MODE_3 | PIXEL_ADV_3)
    } else {
        // 640x480, 16-bit
        constant VIDEO_MODE(BPP16 | INTERLACE | AA_MODE_2 | PIXEL_ADV_3)
    }
} else {
    if HICOLOR {
        // 320x240, 32-bit
        constant VIDEO_MODE(BPP32 | AA_MODE_2 | DIVOT_EN | PIXEL_ADV_3)
    } else {
        // 320x240, 16-bit
        constant VIDEO_MODE(BPP16 | AA_MODE_1 | DIVOT_EN | PIXEL_ADV_3)
    }
}

constant TASK_YIELDED(0x0001)
constant TASK_DP_WAIT(0x0002)
constant TASK_LOADABLE(0x0004)
constant TASK_SP_ONLY(0x0008)

constant VIDEO_C_IMAGE_SIZE(WIDTH * HEIGHT * (HICOLOR * 2 + 2))
constant VIDEO_Z_IMAGE_SIZE(WIDTH * HEIGHT * 2)
constant VIDEO_OUTPUT_SIZE(0x18000) // technically a buffer?
constant VIDEO_STACK_SIZE(0x8000) // used for dlist calls, pushing matrices, etc?
constant VIDEO_YIELD_SIZE(0x1000) // stores and restores DMEM.

// NOTE: these should be row-aligned to avoid caching issues and DMA issues.
constant VIDEO_END(0x80400000)
constant VIDEO_C_IMAGE(VIDEO_END - VIDEO_C_IMAGE_SIZE)
constant VIDEO_C_IMAGE_ALT(VIDEO_C_IMAGE - VIDEO_C_IMAGE_SIZE)
constant VIDEO_Z_IMAGE(VIDEO_C_IMAGE_ALT - VIDEO_Z_IMAGE_SIZE)
constant VIDEO_OUTPUT(VIDEO_Z_IMAGE - VIDEO_OUTPUT_SIZE)
constant VIDEO_STACK(VIDEO_OUTPUT - VIDEO_STACK_SIZE)
constant VIDEO_YIELD(VIDEO_STACK - VIDEO_YIELD_SIZE)
constant VIDEO_START(VIDEO_YIELD)

if VIDEO_START < (MAIN_BASE << 16) + 0x10000 {
    error "ran out of memory for video"
}
