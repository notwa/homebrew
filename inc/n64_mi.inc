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

constant MI_INTR_MASK_SP_SET($002)
constant MI_INTR_MASK_SI_SET($008)
constant MI_INTR_MASK_AI_SET($020)
constant MI_INTR_MASK_VI_SET($080)
constant MI_INTR_MASK_PI_SET($200)
constant MI_INTR_MASK_DP_SET($800)
constant MI_INTR_MASK_ALL_SET($AAA)

constant MI_INTR_MASK_SP_CLR($001)
constant MI_INTR_MASK_SI_CLR($004)
constant MI_INTR_MASK_AI_CLR($010)
constant MI_INTR_MASK_VI_CLR($040)
constant MI_INTR_MASK_PI_CLR($100)
constant MI_INTR_MASK_DP_CLR($400)
constant MI_INTR_MASK_ALL_CLR($555)
