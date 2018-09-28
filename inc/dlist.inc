if HICOLOR {
constant G_SETCIMB_UPPER_WORD(0xFF180000)
} else {
constant G_SETCIMB_UPPER_WORD(0xFF100000)
}

constant MAT_XX(0x00)
constant MAT_XY(0x02)
constant MAT_XZ(0x04)
constant MAT_XW(0x06)
constant MAT_YX(0x08)
constant MAT_YY(0x0A)
constant MAT_YZ(0x0C)
constant MAT_YW(0x0E)
constant MAT_ZX(0x10)
constant MAT_ZY(0x12)
constant MAT_ZZ(0x14)
constant MAT_ZW(0x16)
constant MAT_WX(0x18)
constant MAT_WY(0x1A)
constant MAT_WZ(0x1C)
constant MAT_WW(0x1E)

constant MAT_FRAC(0x20)

constant MAT_XX_FRAC(MAT_XX + MAT_FRAC)
constant MAT_XY_FRAC(MAT_XY + MAT_FRAC)
constant MAT_XZ_FRAC(MAT_XZ + MAT_FRAC)
constant MAT_XW_FRAC(MAT_XW + MAT_FRAC)
constant MAT_YX_FRAC(MAT_YX + MAT_FRAC)
constant MAT_YY_FRAC(MAT_YY + MAT_FRAC)
constant MAT_YZ_FRAC(MAT_YZ + MAT_FRAC)
constant MAT_YW_FRAC(MAT_YW + MAT_FRAC)
constant MAT_ZX_FRAC(MAT_ZX + MAT_FRAC)
constant MAT_ZY_FRAC(MAT_ZY + MAT_FRAC)
constant MAT_ZZ_FRAC(MAT_ZZ + MAT_FRAC)
constant MAT_ZW_FRAC(MAT_ZW + MAT_FRAC)
constant MAT_WX_FRAC(MAT_WX + MAT_FRAC)
constant MAT_WY_FRAC(MAT_WY + MAT_FRAC)
constant MAT_WZ_FRAC(MAT_WZ + MAT_FRAC)
constant MAT_WW_FRAC(MAT_WW + MAT_FRAC)

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
    dh 1, 0, 0, 0
    dh 0, 1, 0, 0
    dh 0, 0, 1, 0
    dh 0, 0, 0, 1

    dh 0, 0, 0, 0
    dh 0, 0, 0, 0
    dh 0, 0, 0, 0
    dh 0, 0, 0, 0
}

macro Matrix(variable xx, variable xy, variable xz, variable xw, variable yx, variable yy, variable yz, variable yw, variable zx, variable zy, variable zz, variable zw, variable wx, variable wy, variable wz, variable ww) {
    // no floats in bass expressions unfortunately...
    // signed integer part
    dh xx >> 16, xy >> 16, xz >> 16, xw >> 16
    dh yx >> 16, yy >> 16, yz >> 16, yw >> 16
    dh zx >> 16, zy >> 16, zz >> 16, zw >> 16
    dh wx >> 16, wy >> 16, wz >> 16, ww >> 16

    // fractional part
    dh xx & 0xFFFF, xy & 0xFFFF, xz & 0xFFFF, xw & 0xFFFF
    dh yx & 0xFFFF, yy & 0xFFFF, yz & 0xFFFF, yw & 0xFFFF
    dh zx & 0xFFFF, zy & 0xFFFF, zz & 0xFFFF, zw & 0xFFFF
    dh wx & 0xFFFF, wy & 0xFFFF, wz & 0xFFFF, ww & 0xFFFF
}

scope Mat {
    define xx(0); define xy(0); define xz(0); define xw(0)
    define yx(0); define yy(0); define yz(0); define yw(0)
    define zx(0); define zy(0); define zz(0); define zw(0)
    define wx(0); define wy(0); define wz(0); define ww(0)

    macro X(variable xx, variable xy, variable xz, variable xw) {
        global evaluate Mat.xx(xx)
        global evaluate Mat.xy(xy)
        global evaluate Mat.xz(xz)
        global evaluate Mat.xw(xw)
    }

    macro Y(variable yx, variable yy, variable yz, variable yw) {
        global evaluate Mat.yx(yx)
        global evaluate Mat.yy(yy)
        global evaluate Mat.yz(yz)
        global evaluate Mat.yw(yw)
    }

    macro Z(variable zx, variable zy, variable zz, variable zw) {
        global evaluate Mat.zx(zx)
        global evaluate Mat.zy(zy)
        global evaluate Mat.zz(zz)
        global evaluate Mat.zw(zw)
    }

    macro W(variable wx, variable wy, variable wz, variable ww) {
        global evaluate Mat.wx(wx)
        global evaluate Mat.wy(wy)
        global evaluate Mat.wz(wz)
        global evaluate Mat.ww(ww)
    }

    macro rix() {
        Matrix({Mat.xx}, {Mat.xy}, {Mat.xz}, {Mat.xw}, {Mat.yx}, {Mat.yy}, {Mat.yz}, {Mat.yw}, {Mat.zx}, {Mat.zy}, {Mat.zz}, {Mat.zw}, {Mat.wx}, {Mat.wy}, {Mat.wz}, {Mat.ww})
    }
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
