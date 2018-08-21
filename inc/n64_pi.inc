constant PI_BASE($A460)       // $04600000..$04600033 Peripheral Interface (PI) Base Register
constant PI_DRAM_ADDR($00)    // $04600000..$04600003 PI: DRAM Address Register
constant PI_CART_ADDR($04)    // $04600004..$04600007 PI: Pbus (Cartridge) Address Register
constant PI_RD_LEN($08)       // $04600008..$0460000B PI: Read Length Register
constant PI_WR_LEN($0C)       // $0460000C..$0460000F PI: Write length register
constant PI_STATUS($10)       // $04600010..$04600013 PI: Status Register
constant PI_BSD_DOM1_LAT($14) // $04600014..$04600017 PI: Domain 1 Latency Register
constant PI_BSD_DOM1_PWD($18) // $04600018..$0460001B PI: Domain 1 Pulse Width Register
constant PI_BSD_DOM1_PGS($1C) // $0460001C..$0460001F PI: Domain 1 Page Size Register
constant PI_BSD_DOM1_RLS($20) // $04600020..$04600023 PI: Domain 1 Release Register
constant PI_BSD_DOM2_LAT($24) // $04600024..$04600027 PI: Domain 2 Latency Register
constant PI_BSD_DOM2_PWD($28) // $04600028..$0460002B PI: Domain 2 Pulse Width Register
constant PI_BSD_DOM2_PGS($2C) // $0460002C..$0460002F PI: Domain 2 Page Size Register
constant PI_BSD_DOM2_RLS($30) // $04600030..$04600033 PI: Domain 2 Release Register

macro PI_WAIT() {
    lui     t5, PI_BASE
-
    lw      t0, PI_STATUS(t5)
    andi    t0, t0, 3
    bnez    t0,-
    nop
}
