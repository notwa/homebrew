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

// Rates
constant CLOCK_RATE(93750000)
constant COUNT_RATE(CLOCK_RATE / 2) // for use with the CP0 Count register.
constant COP_RATE(CLOCK_RATE * 2 / 3)

// Memory Map
constant RDRAM_BASE($A3F0)       // $03F00000 RDRAM Base
constant RDRAM_DEVICE_TYPE($00)  // $03F00000 Device Type
constant RDRAM_DEVICE_ID($04)    // $03F00004 Device ID
constant RDRAM_DELAY($08)        // $03F00008 Delay
constant RDRAM_MODE($0C)         // $03F0000C Mode
constant RDRAM_REF_INTERVAL($10) // $03F00010 Ref Interval
constant RDRAM_REF_ROW($14)      // $03F00014 Ref Row
constant RDRAM_RAS_INTERVAL($18) // $03F00018 Ras Interval
constant RDRAM_MIN_INTERVAL($1C) // $03F0001C Minimum Interval
constant RDRAM_ADDR_SELECT($20)  // $03F00020 Address Select
constant RDRAM_DEVICE_MANUF($24) // $03F00024 Device Manufacturer
