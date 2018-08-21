constant EXT_SYS_AD($8000) // $80000000..$FFFFFFFF External SysAD Device
constant RDRAM($A000) // $00000000..$003FFFFF RDRAM Memory 4MB ($00000000..$007FFFFF 8MB With Expansion Pak)

constant UNCACHED(0xA0000000)
constant ADDR_MASK(0x1FFFFFFF)

constant CART_DOM2_ADDR1($A500) // $05000000..$0507FFFF Cartridge Domain 2 (Address 1) SRAM
constant CART_DOM1_ADDR1($A600) // $06000000..$07FFFFFF Cartridge Domain 1 (Address 1) 64DD
constant CART_DOM2_ADDR2($A800) // $08000000..$0FFFFFFF Cartridge Domain 2 (Address 2) SRAM
constant CART_DOM1_ADDR2($B000) // $10000000..$18000803 Cartridge Domain 1 (Address 2) ROM
constant CART_DOM1_ADDR3($BFD0) // $1FD00000..$7FFFFFFF Cartridge Domain 1 (Address 3)
