constant PI_BASE($A460)       // $04600000..$04600033 Peripheral Interface (PI) Base
constant PI_DRAM_ADDR($00)    // $04600000 DRAM Address
constant PI_CART_ADDR($04)    // $04600004 Pbus (Cartridge) Address
constant PI_RD_LEN($08)       // $04600008 Read Length
constant PI_WR_LEN($0C)       // $0460000C Write Length
constant PI_STATUS($10)       // $04600010 Status
constant PI_BSD_DOM1_LAT($14) // $04600014 Domain 1 Latency
constant PI_BSD_DOM1_PWD($18) // $04600018 Domain 1 Pulse Width
constant PI_BSD_DOM1_PGS($1C) // $0460001C Domain 1 Page Size
constant PI_BSD_DOM1_RLS($20) // $04600020 Domain 1 Release
constant PI_BSD_DOM2_LAT($24) // $04600024 Domain 2 Latency
constant PI_BSD_DOM2_PWD($28) // $04600028 Domain 2 Pulse Width
constant PI_BSD_DOM2_PGS($2C) // $0460002C Domain 2 Page Size
constant PI_BSD_DOM2_RLS($30) // $04600030 Domain 2 Release

macro PI_WAIT() {
    lui     a0, PI_BASE
-
    lw      t0, PI_STATUS(a0)
    andi    t0, t0, 3
    bnez    t0,-
    nop
}
