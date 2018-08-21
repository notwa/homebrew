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
constant RSP_HLT($0001) // Halt
constant RSP_BRK($0002) // Break
constant RSP_BSY($0004) // DMA Busy
constant RSP_FUL($0008) // DMA Full
constant RSP_IOF($0010) // IO Full
constant RSP_STP($0020) // Single Step
constant RSP_IOB($0040) // Interrupt On Break
constant RSP_SG0($0080) // Signal 0 Set
constant RSP_SG1($0100) // Signal 1 Set
constant RSP_SG2($0200) // Signal 2 Set
constant RSP_SG3($0400) // Signal 3 Set
constant RSP_SG4($0800) // Signal 4 Set
constant RSP_SG5($1000) // Signal 5 Set
constant RSP_SG6($2000) // Signal 6 Set
constant RSP_SG7($4000) // Signal 7 Set

// SP_STATUS Write Flags:
constant CLR_HLT($00000001) // Clear Halt
constant SET_HLT($00000002) //   Set Halt
constant CLR_BRK($00000004) // Clear Broke
constant CLR_INT($00000008) // Clear Interrupt
constant SET_INT($00000010) //   Set Interrupt
constant CLR_STP($00000020) // Clear Single Step
constant SET_STP($00000040) //   Set Single Step
constant CLR_IOB($00000080) // Clear Interrupt On Break
constant SET_IOB($00000100) //   Set Interrupt On Break
constant CLR_SG0($00000200) // Clear Signal 0
constant SET_SG0($00000400) //   Set Signal 0
constant CLR_SG1($00000800) // Clear Signal 1
constant SET_SG1($00001000) //   Set Signal 1
constant CLR_SG2($00002000) // Clear Signal 2
constant SET_SG2($00004000) //   Set Signal 2
constant CLR_SG3($00008000) // Clear Signal 3
constant SET_SG3($00010000) //   Set Signal 3
constant CLR_SG4($00020000) // Clear Signal 4
constant SET_SG4($00040000) //   Set Signal 4
constant CLR_SG5($00080000) // Clear Signal 5
constant SET_SG5($00100000) //   Set Signal 5
constant CLR_SG6($00200000) // Clear Signal 6
constant SET_SG6($00400000) //   Set Signal 6
constant CLR_SG7($00800000) // Clear Signal 7
constant SET_SG7($01000000) //   Set Signal 7

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

macro SP_BUSY_WAIT() {
    lui     a0, SP_BASE
-
    lw      t0, SP_STATUS(a0)
    andi    t0, 0x1C
    sltu    t0, r0, t0 // TODO: rewrite this
    bnez    t0,-
    nop
}
