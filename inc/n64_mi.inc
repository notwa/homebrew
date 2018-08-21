constant MI_BASE($A430)    // $04300000..$0430000F MIPS Interface (MI) Base Register
constant MI_INIT_MODE($00) // $04300000..$04300003 MI: Init Mode Register
constant MI_VERSION($04)   // $04300004..$04300007 MI: Version Register
constant MI_INTR($08)      // $04300008..$0430000B MI: Interrupt Register
constant MI_INTR_MASK($0C) // $0430000C..$0430000F MI: Interrupt Mask Register

constant MI_INTR_SP($01)
constant MI_INTR_SI($02)
constant MI_INTR_AI($04)
constant MI_INTR_VI($08)
constant MI_INTR_PI($10)
constant MI_INTR_DP($20)
constant MI_INTR_ALL($3F)

// TODO: SET and CLR rather than just MASK
constant MI_INTR_MASK_SP($002)
constant MI_INTR_MASK_SI($008)
constant MI_INTR_MASK_AI($020)
constant MI_INTR_MASK_VI($080)
constant MI_INTR_MASK_PI($200)
constant MI_INTR_MASK_DP($800)
constant MI_INTR_MASK_ALL($AAA)
