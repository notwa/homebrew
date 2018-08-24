macro EnableInt() {
    lli     t0, MI_INTR_MASK_ALL_SET
    lui     a0, MI_BASE
    sw      t0, MI_INTR_MASK(a0)
    // careful not to touch unrelated flags here
    mfc0    t1, CP0_Status
    lli     t0, CP0_STATUS_IM_ALL
    or      t1, t0
    mtc0    t1, CP0_Status
}

macro DisableInt() {
    lli     t0, MI_INTR_MASK_ALL_CLR
    lui     a0, MI_BASE
    sw      t0, MI_INTR_MASK(a0)
    // careful not to touch unrelated flags here
    mfc0    t1, CP0_Status
    lli     t0, CP0_STATUS_IM_ALL
    nor     t0, r0 // invert the mask (including upper halfword)
    and     t1, t0
    mtc0    t1, CP0_Status
}
