// write some F3DZEX instructions to a0
// clobbers t0,t1,a0

constant WIDTH(320)
constant HEIGHT(240)
constant HICOLOR(0)

define dpos(0)

macro WriteDL(evaluate L, evaluate R) {
    lui     t0, ({L} >> 16) & 0xFFFF
    lui     t1, ({R} >> 16) & 0xFFFF
    ori     t0, {L} & 0xFFFF
    ori     t1, {R} & 0xFFFF
    sw      t0, {dpos}+0(a0)
    sw      t1, {dpos}+4(a0)
global evaluate dpos({dpos}+8)
if {dpos} >= 0x8000 {
    error "much too much"
    // FIXME: just add dpos to a0 and set dpos to 0 when this happens
}
}

    // G_RDPPIPESYNC
    WriteDL(0xE7000000, 0)

    // G_TEXTURE (disable tile descriptor; dummy second argument)
    WriteDL(0xD7000000, 0xFFFFFFFF)

    // G_SETCOMBINE (too complicated to explain here...)
    WriteDL(0xFCFFFFFF, 0xFFFE793C)

    // G_RDPSETOTHERMODE (set higher flags, clear all lower flags)
    // 0011 1000 0010 1100 0011 0000
    // G_AD_DISABLE | G_CD_MAGICSQ | G_TC_FILT | G_TF_BILERP |
    // G_TT_NONE | G_TL_TILE | G_TD_CLAMP | G_MDSFT_TEXTPERSP |
    // G_CYC_FILL | G_PM_NPRIMITIVE
    // TODO: try running without this
    WriteDL(0xEF382C30, 0x00000000)

    // G_GEOMETRYMODE
    // set some bits (TODO: which?), clear none
    WriteDL(0xD9000000, 0x00220405)

    // G_SETSCISSOR     coordinate order: (top, left), (right, bottom)
    WriteDL(0xED000000 | (0 << 14) | (0 << 2), (WIDTH << 14) | (HEIGHT << 2))

    // G_SETBLENDCOLOR
    // sets alpha component to 8, everything else to 0
    WriteDL(0xF9000000, 0x00000008)

    // sets near- far-plane clipping? maybe?
    // G_MOVEWORD, sets G_MW_CLIP+$0004
    WriteDL(0xDB040004, 2)
    // G_MOVEWORD, sets G_MW_CLIP+$000C
    WriteDL(0xDB04000C, 2)
    // G_MOVEWORD, sets G_MW_CLIP+$0014
    WriteDL(0xDB040014, 0x10000 - 2)
    // G_MOVEWORD, sets G_MW_CLIP+$001C
    WriteDL(0xDB04001C, 0x10000 - 2)

    // G_SETZIMG, set our z buffer
    WriteDL(0xFE000000, VIDEO_Z_BUFFER)

    // G_SETCIMG, set our z buffer as a color buffer so we can wipe it
    WriteDL(0xFF100000 | (WIDTH - 1), VIDEO_Z_BUFFER)

    WriteDL(0xE3000A01, 0x00300000) // G_SETOTHERMODE_H
    WriteDL(0xE200001C, 0x00000000) // G_SETOTHERMODE_L
    WriteDL(0xF7000000, 0xFFFCFFFC) // G_SETFILLCOLOR to default z value
    // G_FILLRECT the whole z buffer
    WriteDL(0xF6000000 | ((WIDTH - 1) << 14) | ((HEIGHT - 1) << 2), 0)
    WriteDL(0xE7000000, 0) // G_RDPPIPESYNC

    // G_SETCIMG, set our color buffer
if HICOLOR {
    WriteDL(0xFF180000 | (WIDTH - 1), VIDEO_C_BUFFER)
} else {
    WriteDL(0xFF100000 | (WIDTH - 1), VIDEO_C_BUFFER)
}

    WriteDL(0xF8000000, 0x0A0A0A00) // G_SETFOGCOLOR
    WriteDL(0xDB080000, 0x3E80C280) // set fog distance (float?)
    WriteDL(0xE7000000, 0) // G_RDPPIPESYNC

    // G_SETFILLCOLOR
if HICOLOR {
    WriteDL(0xF7000000, 0x007FFFFF)
} else {
    WriteDL(0xF7000000, 0x03FF03FF)
}

    WriteDL(0xE7000000, 0) // G_RDPPIPESYNC

    // G_FILLRECT       coordinate order: (right, bottom), (top, left)
    // note that the coordinates are all inclusive!
    WriteDL(0xF6000000 | (199 << 14) | (199 << 2), (100 << 14) | (100 << 2))

    // G_RDPPIPESYNC
    WriteDL(0xE7000000, 0)

    // always finish it off by telling RDP to stop!
    // G_RDPFULLSYNC
    WriteDL(0xE9000000, 0)
    // G_ENDDL
    WriteDL(0xDF000000, 0)
