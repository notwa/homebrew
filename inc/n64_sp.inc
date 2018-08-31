constant SP_MEM_BASE($A400) // $04000000..$04000FFF SP MEM Base Register
constant SP_DMEM($0000)     // $04000000..$04000FFF SP: RSP DMEM (4096 Bytes)
constant SP_IMEM($1000)     // $04001000..$04001FFF SP: RSP IMEM (4096 Bytes)

constant SP_BASE($A404)    // $04040000..$0404001F SP Base Register
constant SP_MEM_ADDR($00)  // $04040000..$04040003 SP: Master, SP Memory Address Register
constant SP_DRAM_ADDR($04) // $04040004..$04040007 SP: Slave, SP DRAM DMA Address Register
constant SP_RD_LEN($08)    // $04040008..$0404000B SP: Read DMA Length Register
constant SP_WR_LEN($0C)    // $0404000C..$0404000F SP: Write DMA Length Register
constant SP_STATUS($10)    // $04040010..$04040013 SP: Status Register
constant SP_DMA_FULL($14)  // $04040014..$04040017 SP: DMA Full Register
constant SP_DMA_BUSY($18)  // $04040018..$0404001B SP: DMA Busy Register
constant SP_SEMAPHORE($1C) // $0404001C..$0404001F SP: Semaphore Register

constant SP_PC_BASE($A408) // $04080000..$04080007 SP PC Base Register
constant SP_PC($00)        // $04080000..$04080003 SP: PC Register
constant SP_IBIST_REG($04) // $04080004..$04080007 SP: IMEM BIST Register

// SP_STATUS Read Flags:
constant SP_HALT($0001)
constant SP_BREAK($0002)
constant SP_BUSY($0004) // DMA busy
constant SP_FULL($0008) // DMA full
constant SP_IO_FULL($0010)
constant SP_SINGLE_STEP($0020)
constant SP_INT_ON_BREAK($0040) // Interrupt On Break
constant SP_SG0($0080) // Signal 0 Set
constant SP_SG1($0100) // Signal 1 Set
constant SP_SG2($0200) // Signal 2 Set
constant SP_SG3($0400) // Signal 3 Set
constant SP_SG4($0800) // Signal 4 Set
constant SP_SG5($1000) // Signal 5 Set
constant SP_SG6($2000) // Signal 6 Set
constant SP_SG7($4000) // Signal 7 Set

// SP_STATUS Write Flags:
constant SP_HALT_CLR($00000001)
constant SP_HALT_SET($00000002)
constant SP_BREAK_CLR($00000004) // Clear Broke
constant SP_INT_CLR($00000008) // Clear Interrupt
constant SP_INT_SET($00000010) //   Set Interrupt
constant SP_SINGLE_STEP_CLR($00000020)
constant SP_SINGLE_STEP_SET($00000040)
constant SP_INT_ON_BREAK_CLR($00000080) // Clear Interrupt On Break
constant SP_INT_ON_BREAK_SET($00000100) //   Set Interrupt On Break
constant SP_SG0_CLR($00000200) // Clear Signal 0
constant SP_SG0_SET($00000400) //   Set Signal 0
constant SP_SG1_CLR($00000800) // Clear Signal 1
constant SP_SG1_SET($00001000) //   Set Signal 1
constant SP_SG2_CLR($00002000) // Clear Signal 2
constant SP_SG2_SET($00004000) //   Set Signal 2
constant SP_SG3_CLR($00008000) // Clear Signal 3
constant SP_SG3_SET($00010000) //   Set Signal 3
constant SP_SG4_CLR($00020000) // Clear Signal 4
constant SP_SG4_SET($00040000) //   Set Signal 4
constant SP_SG5_CLR($00080000) // Clear Signal 5
constant SP_SG5_SET($00100000) //   Set Signal 5
constant SP_SG6_CLR($00200000) // Clear Signal 6
constant SP_SG6_SET($00400000) //   Set Signal 6
constant SP_SG7_CLR($00800000) // Clear Signal 7
constant SP_SG7_SET($01000000) //   Set Signal 7

macro SP_DMA_WAIT() {
    lui     a0, SP_BASE
-
    lw      t0, SP_STATUS(a0)
    andi    t0, SP_IO_FULL | SP_BUSY | SP_FULL
    sltu    t0, r0, t0
    bnez    t0,-
    nop
}

macro SP_HALT_WAIT() {
    lui     a0, SP_BASE
-
    lw      t0, SP_STATUS(a0)
    andi    t0, SP_HALT
    beqz    t0,-
    nop
}
