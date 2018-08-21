macro EnableInt() {
    lli     t0, 0xAAA
    lli     t1, 0xFF01
    lui     a0, MI_BASE
    sw      t0, MI_INTR_MASK(a0)
    mtc0    t1, CP0_Status
}

macro DisableInt() {
    lli     t0, 0x555
    lli     t1, 0x0001
    lui     a0, MI_BASE
    sw      t0, MI_INTR_MASK(a0)
    mtc0    t1, CP0_Status
}
