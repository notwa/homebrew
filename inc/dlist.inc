if HICOLOR {
constant G_SETCIMB_UPPER_WORD(0xFF180000)
} else {
constant G_SETCIMB_UPPER_WORD(0xFF100000)
}
define dpos(0)

macro WriteDL(evaluate L, evaluate R) {
    lui     t0, ({L} >> 16) & 0xFFFF
    lui     t1, ({R} >> 16) & 0xFFFF
    ori     t0, {L} & 0xFFFF
    ori     t1, {R} & 0xFFFF
    sw      t0, {dpos}+0(a0)
    sw      t1, {dpos}+4(a0)
global evaluate dpos({dpos}+8)
if {dpos} >= 0x2000 {
    addiu   a0, 0x2000
    global evaluate dpos({dpos}-0x2000)
}
}

macro WriteCB(evaluate L) {
    lui     t0, ({L} >> 16) & 0xFFFF
    ori     t0, {L} & 0xFFFF
    sw      t0, {dpos}+0(a0)
    sw      a1, {dpos}+4(a0)
global evaluate dpos({dpos}+8)
if {dpos} >= 0x2000 {
    addiu   a0, 0x2000
    global evaluate dpos({dpos}-0x2000)
}
}

macro MatEye() {
    dh 0x0001, 0x0000, 0x0000, 0x0000
    dh 0x0000, 0x0001, 0x0000, 0x0000
    dh 0x0000, 0x0000, 0x0001, 0x0000
    dh 0x0000, 0x0000, 0x0000, 0x0001

    dh 0x0000, 0x0000, 0x0000, 0x0000
    dh 0x0000, 0x0000, 0x0000, 0x0000
    dh 0x0000, 0x0000, 0x0000, 0x0000
    dh 0x0000, 0x0000, 0x0000, 0x0000
}

macro MatObject(variable x, variable y, variable z, variable scale) {
    dh scale >> 16, 0, 0, 0
    dh 0, scale >> 16, 0, 0
    dh 0, 0, scale >> 16, 0
    dh x >> 16, y >> 16, z >> 16, 1

    dh scale, 0, 0, 0
    dh 0, scale, 0, 0
    dh 0, 0, scale, 0
    dh x, y, z, 0
}
