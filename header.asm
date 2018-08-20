//============
// N64 Header
//============
// PI_BSB_DOM1
  db $80
  db $37
  db $12
  db $40

// CLOCK RATE
  dw $000F // Initial Clock Rate

// VECTOR
  dw Start // Boot Address Offset
  dw $1444 // Release Offset

// COMPLEMENT CHECK & CHECKSUM
  db "CRC1" // CRC1: COMPLEMENT CHECK
  db "CRC2" // CRC2: CHECKSUM

  dd 0 // UNUSED

// PROGRAM TITLE (27 Byte ASCII String, Use Spaces For Unused Bytes)
  db "NOTWA'S TESTING THE 64DRIVE"
//   "123456789012345678901234567"

// DEVELOPER ID CODE 
  db $00 // "N" = Nintendo

// CARTRIDGE ID CODE
  db $00

  db 0 // UNUSED

// COUNTRY CODE 
  db $00 // "D" = Germany, "E" = USA, "J" = Japan, "P" = Europe, "U" = Australia

  db 0 // UNUSED
