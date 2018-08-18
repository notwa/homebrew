// by krom (Peter Lemon)
// https://github.com/PeterLemon/N64/tree/master/Compress/LZ77/LZ77GFX

LZInit:
    la a0, LZ+4 // A0 = Source Address
    lui a1, 0x8010 // A1 = Destination Address (DRAM Start Offset)

    lbu t0, -1(a0) // T0 = HI Data Length Byte
    sll t0, 8
    lbu t1, -2(a0) // T1 = MID Data Length Byte
    or t0, t1
    sll t0, 8
    lbu t1, -3(a0) // T1 = LO Data Length Byte
    or t0, t1 // T0 = Data Length
    addu t0, a1 // T0 = Destination End Offset (DRAM End Offset)

LZLoop:
    lbu t1, 0(a0) // T1 = Flag Data For Next 8 Blocks (0 = Uncompressed Byte,  1 = Compressed Bytes)
    addiu a0, 1 // Add 1 To LZ Offset
    ori t2, r0, %10000000 // T2 = Flag Data Block Type Shifter

LZBlockLoop:
    beq a1, t0, LZEnd // IF (Destination Address == Destination End Offset) LZEnd
    and t4, t1, t2 // Test Block Type (Delay Slot)
    beqz t2, LZLoop // IF (Flag Data Block Type Shifter == 0) LZLoop
    srl t2, 1 // Shift T2 To Next Flag Data Block Type (Delay Slot)
    lbu t3, 0(a0) // T3 = Copy Uncompressed Byte / Number Of Bytes To Copy & Disp MSB's
    bnez t4, LZDecode // IF (BlockType != 0) LZDecode Bytes
    addiu a0, 1 // Add 1 To LZ Offset (Delay Slot)
    sb t3, 0(a1) // Store Uncompressed Byte To Destination
    j LZBlockLoop
    addiu a1, 1 // Add 1 To DRAM Offset (Delay Slot)

LZDecode:
    lbu t4, 0(a0) // T4 = Disp LSB's
    addiu a0, 1 // Add 1 To LZ Offset
    sll t5, t3, 8 // T5 = Disp MSB's
    or t4, t5 // T4 = Disp 16-Bit
    andi t4, 0xFFF // T4 &= 0xFFF (Disp 12-Bit)
    not t4 // T4 = -Disp - 1
    addu t4, a1 // T4 = Destination - Disp - 1
    srl t3, 4 // T3 = Number Of Bytes To Copy (Minus 3)
    addiu t3, 3 // T3 = Number Of Bytes To Copy

LZCopy:
    lbu t5, 0(t4) // T5 = Byte To Copy
    addiu t4, 1 // Add 1 To T4 Offset
    sb t5, 0(a1) // Store Byte To DRAM
    subiu t3, 1 // Number Of Bytes To Copy -= 1
    bnez t3, LZCopy // IF (Number Of Bytes To Copy != 0) LZCopy Bytes
    addiu a1, 1 // Add 1 To DRAM Offset (Delay Slot)
    j LZBlockLoop
    nop // Delay Slot

LZEnd:
