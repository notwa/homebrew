// Coprocessor 0 registers
constant CP0_Index(0)
constant CP0_Random(1)
constant CP0_EntryLo0(2)
constant CP0_EntryLo1(3)
constant CP0_Context(4)
constant CP0_PageMask(5)
constant CP0_Wired(6)
constant CP0_Reserved_1(7)
constant CP0_BadVAddr(8)
constant CP0_Count(9)
constant CP0_EntryHi(10)
constant CP0_Compare(11)
constant CP0_Status(12)
constant CP0_Cause(13)
constant CP0_EPC(14)
constant CP0_PRid(15)
constant CP0_Config(16)
constant CP0_LLAddr(17)
constant CP0_WatchLo(18)
constant CP0_WatchHi(19)
constant CP0_XContext(20)
constant CP0_Reserved_2(21)
constant CP0_Reserved_3(22)
constant CP0_Reserved_4(23)
constant CP0_Reserved_5(24)
constant CP0_Reserved_6(25)
constant CP0_PErr(26) // unused
constant CP0_CacheErr(27) // unused
constant CP0_TagLo(28)
constant CP0_TagHi(29) // reserved
constant CP0_ErrorPC(30)
constant CP0_Reserved_7(31)

constant CP0_STATUS_IE($0001)  // Interrupt Enable
constant CP0_STATUS_EXL($0002) // Exception Level
constant CP0_STATUS_ERL($0004) // Error Level
constant CP0_STATUS_IM0($0100) // Interrupt Mask 0 (Software)
constant CP0_STATUS_IM1($0200) // Interrupt Mask 1 (Software)
constant CP0_STATUS_IM2($0400) // Interrupt Mask 2 (External)
constant CP0_STATUS_IM3($0800) // Interrupt Mask 3 (External)
constant CP0_STATUS_IM4($1000) // Interrupt Mask 4 (External)
constant CP0_STATUS_IM5($2000) // Interrupt Mask 5 (External)
constant CP0_STATUS_IM6($4000) // Interrupt Mask 6 (External)
constant CP0_STATUS_IM7($8000) // Interrupt Mask 7 (External)
constant CP0_STATUS_IM_ALL($FF00) // all interrupt masks

// note that these are all masks.
constant CP0_CAUSE_CODE($007C) // actually supposed to be called ExcCode
constant CP0_CAUSE_IP0($0100) // Interrupt Pending 0 (Software)
constant CP0_CAUSE_IP1($0200) // Interrupt Pending 1 (Software)
constant CP0_CAUSE_IP2($0400) // Interrupt Pending 2 (External)
constant CP0_CAUSE_IP3($0800) // Interrupt Pending 3 (External)
constant CP0_CAUSE_IP4($1000) // Interrupt Pending 4 (External)
constant CP0_CAUSE_IP5($2000) // Interrupt Pending 5 (External)
constant CP0_CAUSE_IP6($4000) // Interrupt Pending 6 (External)
constant CP0_CAUSE_IP7($8000) // Interrupt Pending 7 (External)
// upper halfword:
constant CP0_CAUSE_CE($30000000) // Coprocessor Error
constant CP0_CAUSE_BD($80000000) // Branch Delay (not an exception, just info)

// note that these constants are shifted left 2 into the Cause register,
// so you must shift-right the value from the register before comparing them.
constant CP0_CODE_INT(0)    // Interrupt
constant CP0_CODE_MOD(1)    // TLB modification exception
constant CP0_CODE_TLBL(2)   // TLB Exception (Load or instruction fetch)
constant CP0_CODE_TLBS(3)   // TLB Exception (Store)
constant CP0_CODE_ADEL(4)   // Address Error Exception (Load or instruction fetch)
constant CP0_CODE_ADES(5)   // Address Error Exception (Store)
constant CP0_CODE_IBE(6)    // Bus Error Exception (instruction fetch)
constant CP0_CODE_DBE(7)    // Bus Error Exception (data reference: load or store)
constant CP0_CODE_SYS(8)    // SysCall Exception
constant CP0_CODE_BP(9)     // Breakpoint Exception
constant CP0_CODE_RI(10)    // Reserved instruction Exception
constant CP0_CODE_CPU(11)   // Coprocessor Unusable Exception
constant CP0_CODE_OV(12)    // Arithmetic Overflow Exception
constant CP0_CODE_TR(13)    // Trap Exception
constant CP0_CODE_RESERVED_14(14)
constant CP0_CODE_FPE(15)   // Floating Point Exception
constant CP0_CODE_RESERVED_16(16)
constant CP0_CODE_RESERVED_17(17)
constant CP0_CODE_RESERVED_18(18)
constant CP0_CODE_RESERVED_19(19)
constant CP0_CODE_RESERVED_20(20)
constant CP0_CODE_RESERVED_21(21)
constant CP0_CODE_RESERVED_22(22)
constant CP0_CODE_WATCH(23) // Reference to WatchHi/WatchLo address
constant CP0_CODE_RESERVED_24(24)
constant CP0_CODE_RESERVED_25(25)
constant CP0_CODE_RESERVED_26(26)
constant CP0_CODE_RESERVED_27(27)
constant CP0_CODE_RESERVED_28(28)
constant CP0_CODE_RESERVED_29(29)
constant CP0_CODE_RESERVED_30(30)
constant CP0_CODE_RESERVED_31(31)
