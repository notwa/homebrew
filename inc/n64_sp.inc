constant SP_MEM_BASE($A400) // $04000000 SP MEM Base Register
constant SP_DMEM($0000)     // $04000000 RSP DMEM (4096 Bytes)
constant SP_IMEM($1000)     // $04001000 RSP IMEM (4096 Bytes)

constant SP_BASE($A404)    // $04040000 SP Base Register
constant SP_MEM_ADDR($00)  // $04040000 Master, SP Memory Address Register
constant SP_DRAM_ADDR($04) // $04040004 Slave, SP DRAM DMA Address Register
constant SP_RD_LEN($08)    // $04040008 Read DMA Length Register
constant SP_WR_LEN($0C)    // $0404000C Write DMA Length Register
constant SP_STATUS($10)    // $04040010 Status Register
constant SP_DMA_FULL($14)  // $04040014 DMA Full Register
constant SP_DMA_BUSY($18)  // $04040018 DMA Busy Register
constant SP_SEMAPHORE($1C) // $0404001C Semaphore Register

constant SP_PC_BASE($A408) // $04080000 SP PC Base Register
constant SP_PC($00)        // $04080000 PC Register
constant SP_IBIST_REG($04) // $04080004 IMEM BIST Register

// SP_STATUS Read Flags:
constant SP_HALT($0001)
constant SP_BREAK($0002)
constant SP_BUSY($0004) // DMA busy
constant SP_FULL($0008) // DMA full
constant SP_IO_FULL($0010)
constant SP_SINGLE_STEP($0020)
constant SP_INT_ON_BREAK($0040) // Interrupt On Break
constant SP_SIG0($0080) // Signal 0 Set
constant SP_SIG1($0100) // Signal 1 Set
constant SP_SIG2($0200) // Signal 2 Set
constant SP_SIG3($0400) // Signal 3 Set
constant SP_SIG4($0800) // Signal 4 Set
constant SP_SIG5($1000) // Signal 5 Set
constant SP_SIG6($2000) // Signal 6 Set
constant SP_SIG7($4000) // Signal 7 Set

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
constant SP_SIG0_CLR($00000200)
constant SP_SIG0_SET($00000400)
constant SP_SIG1_CLR($00000800)
constant SP_SIG1_SET($00001000)
constant SP_SIG2_CLR($00002000)
constant SP_SIG2_SET($00004000)
constant SP_SIG3_CLR($00008000)
constant SP_SIG3_SET($00010000)
constant SP_SIG4_CLR($00020000)
constant SP_SIG4_SET($00040000)
constant SP_SIG5_CLR($00080000)
constant SP_SIG5_SET($00100000)
constant SP_SIG6_CLR($00200000)
constant SP_SIG6_SET($00400000)
constant SP_SIG7_CLR($00800000)
constant SP_SIG7_SET($01000000)

// signal conventions:
constant SP_YIELD(SP_SIG0)
constant SP_YIELDED(SP_SIG1)
constant SP_TASKDONE(SP_SIG2)
constant SP_RSPSIGNAL(SP_SIG3)
constant SP_CPUSIGNAL(SP_SIG4)

constant SP_YIELD_CLR(SP_SIG0_CLR)
constant SP_YIELD_SET(SP_SIG0_SET)
constant SP_YIELDED_CLR(SP_SIG1_CLR)
constant SP_YIELDED_SET(SP_SIG1_SET)
constant SP_TASKDONE_CLR(SP_SIG2_CLR)
constant SP_TASKDONE_SET(SP_SIG2_SET)
constant SP_RSPSIGNAL_CLR(SP_SIG3_CLR)
constant SP_RSPSIGNAL_SET(SP_SIG3_SET)
constant SP_CPUSIGNAL_CLR(SP_SIG4_CLR)
constant SP_CPUSIGNAL_SET(SP_SIG4_SET)

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
