// by krom, expanded and reorganized by notwa

include "n64_cpu.inc"
include "n64_cp0.inc"
include "n64_cp1.inc"
include "n64_map.inc"
include "n64_sp.inc"
include "n64_dp.inc"
include "n64_mi.inc"
include "n64_vi.inc"
include "n64_ai.inc"
include "n64_pi.inc"
include "n64_ri.inc"
include "n64_si.inc"
include "n64_pif.inc"
include "n64_util.inc"

// Memory Map
constant RDRAM_BASE($A3F0)       // $03F00000..$03F00027 RDRAM Base Register
constant RDRAM_DEVICE_TYPE($00)  // $03F00000..$03F00003 RDRAM: Device Type Register
constant RDRAM_DEVICE_ID($04)    // $03F00004..$03F00007 RDRAM: Device ID Register
constant RDRAM_DELAY($08)        // $03F00008..$03F0000B RDRAM: Delay Register
constant RDRAM_MODE($0C)         // $03F0000C..$03F0000F RDRAM: Mode Register
constant RDRAM_REF_INTERVAL($10) // $03F00010..$03F00013 RDRAM: Ref Interval Register
constant RDRAM_REF_ROW($14)      // $03F00014..$03F00017 RDRAM: Ref Row Register
constant RDRAM_RAS_INTERVAL($18) // $03F00018..$03F0001B RDRAM: Ras Interval Register
constant RDRAM_MIN_INTERVAL($1C) // $03F0001C..$03F0001F RDRAM: Minimum Interval Register
constant RDRAM_ADDR_SELECT($20)  // $03F00020..$03F00023 RDRAM: Address Select Register
constant RDRAM_DEVICE_MANUF($24) // $03F00024..$03F00027 RDRAM: Device Manufacturer Register
