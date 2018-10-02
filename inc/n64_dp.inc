constant DPC_BASE($A410)   // $04100000 DP Command Base Register
constant DPC_START($00)    // $04100000 CMD DMA Start Register
constant DPC_END($04)      // $04100004 CMD DMA End Register
constant DPC_CURRENT($08)  // $04100008 CMD DMA Current Register
constant DPC_STATUS($0C)   // $0410000C CMD Status Register
constant DPC_CLOCK($10)    // $04100010 Clock Counter Register
constant DPC_BUFBUSY($14)  // $04100014 Buffer Busy Counter Register
constant DPC_PIPEBUSY($18) // $04100018 Pipe Busy Counter Register
constant DPC_TMEM($1C)     // $0410001C TMEM Load Counter Register

constant DPS_BASE($A420)       // $04200000 DP Span Base Register
constant DPS_TBIST($00)        // $04200000 Tmem Bist Register
constant DPS_TEST_MODE($04)    // $04200004 Span Test Mode Register
constant DPS_BUFTEST_ADDR($08) // $04200008 Span Buffer Test Address Register
constant DPS_BUFTEST_DATA($0C) // $0420000C Span Buffer Test Data Register

// DPC_STATUS Read Flags:
constant DPC_XBS($001) // Use XBUS DMEM DMA Or DRAM DMA
constant DPC_FRZ($002) // RDP Frozen
constant DPC_FLUSH($004) // RDP Flushed
constant DPC_GCL($008) // GCLK Alive
constant DPC_TMB($010) // TMEM Busy
constant DPC_PLB($020) // RDP PIPELINE Busy
constant DPC_CMB($040) // RDP COMMAND Unit Busy
constant DPC_CMR($080) // RDP COMMAND Buffer Ready
constant DPC_DMA($100) // RDP DMA Busy
constant DPC_CME($200) // RDP COMMAND END Register Valid
constant DPC_CMS($400) // RDP COMMAND START Register Valid

// DPC_STATUS Write Flags:
constant DPC_XBS_CLR($001) // Clear XBUS DMEM DMA
constant DPC_XBS_SET($002) //   Set XBUS DMEM DMA
constant DPC_FRZ_CLR($004) // Clear FREEZE
constant DPC_FRZ_SET($008) //   Set FREEZE
constant DPC_FLUSH_CLR($010) // Clear FLUSH
constant DPC_FLUSH_SET($020) //   Set FLUSH
constant DPC_TMC_CLR($040) // Clear TMEM COUNTER
constant DPC_PLC_CLR($080) // Clear PIPELINE COUNTER
constant DPC_CMC_CLR($100) // Clear COMMAND COUNTER
constant DPC_CLK_CLR($200) // Clear CLOCK COUNTER
