constant SI_BASE($A480)         // $04800000 Serial Interface (SI) Base
constant SI_DRAM_ADDR($00)      // $04800000 DRAM Address
constant SI_PIF_ADDR_RD64B($04) // $04800004 Address Read 64B
//*RESERVED*($08)               // $04800008 Reserved
//*RESERVED*($0C)               // $0480000C Reserved
constant SI_PIF_ADDR_WR64B($10) // $04800010 Address Write 64B
//*RESERVED*($14)               // $04800014 Reserved
constant SI_STATUS($18)         // $04800018 Status

macro SI_WAIT() {
    lui     a0, SI_BASE
-
    lw      t0, SI_STATUS(a0)
    andi    t0, 0x0003
    sltu    t0, r0, t0
    bnez    t0,-
    nop
}
