constant DPC_BASE($A410)   // $04100000..$0410001F DP Command (DPC) Base Register
constant DPC_START($00)    // $04100000..$04100003 DPC: CMD DMA Start Register
constant DPC_END($04)      // $04100004..$04100007 DPC: CMD DMA End Register
constant DPC_CURRENT($08)  // $04100008..$0410000B DPC: CMD DMA Current Register
constant DPC_STATUS($0C)   // $0410000C..$0410000F DPC: CMD Status Register
constant DPC_CLOCK($10)    // $04100010..$04100013 DPC: Clock Counter Register
constant DPC_BUFBUSY($14)  // $04100014..$04100017 DPC: Buffer Busy Counter Register
constant DPC_PIPEBUSY($18) // $04100018..$0410001B DPC: Pipe Busy Counter Register
constant DPC_TMEM($1C)     // $0410001C..$0410001F DPC: TMEM Load Counter Register

constant DPS_BASE($A420)       // $04200000..$0420000F DP Span (DPS) Base Register
constant DPS_TBIST($00)        // $04200000..$04200003 DPS: Tmem Bist Register
constant DPS_TEST_MODE($04)    // $04200004..$04200007 DPS: Span Test Mode Register
constant DPS_BUFTEST_ADDR($08) // $04200008..$0420000B DPS: Span Buffer Test Address Register
constant DPS_BUFTEST_DATA($0C) // $0420000C..$0420000F DPS: Span Buffer Test Data Register

