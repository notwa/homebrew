include "inc/F3DEX2.inc"
include "inc/dlist.inc"

constant FOV90(0)

macro _g(variable c, variable a, variable b) {
    WriteDL((c << 24) | a, b)
}

framecount:
    dw 0

SmoothStep16:
    // a0: s15.16?
    // v0: s15.16
    // v1: lower 16 bits

    // t9 = abs(a0)
    bgez    a0,+
    addu    t9, r0, a0
    subu    t9, r0, a0
+

    // t9 = triangle_wave(t9)
    // note that every minimum and maximum value is repeated once
    li      t0, 0x1FFFF // period of 2
    and     t9, t0
    lli     t0, 0xFFFF
    subu    t9, t0, t9
    bgez    t9,+
    subiu   t1, r0, 1
    subu    t9, t1, t9
+
    subu    t9, t0, t9

    // t8 = t9 * t9
    multu   t9, t9
    mflo    t8
    srl     t8, 16
    // t7 = 3 - 2 * t9
    sll     t7, t9, 1 // times two
    subu    t7, r0, t7 // negate
    li      t0, 3 << 16
    addu    t7, t0
    // t6 = t8 * t7
    // instead do a u0.15 * u2.15 multiply to avoid overflow:
    srl     t8, 1
    srl     t7, 1
    multu   t8, t7
    mflo    t6
    srl     v0, t6, 14
    sll     v1, t6, 1

    jr      ra
    nop

WriteDList:
    // a0: pointer to receive F3DZEX instructions
    // a1: use alt color buffer (boolean)
    subiu   sp, 0x20
    sw      ra, 0x10(sp)
    sw      s0, 0x14(sp)
    sw      s1, 0x18(sp)
    sw      s2, 0x1C(sp)

    bnez    a1,+
    nop
    la      a1, VIDEO_C_IMAGE
    j       ++
    nop
+
    la      a1, VIDEO_C_IMAGE_ALT
+

    or      s0, a0, r0
    or      s1, a1, r0

    // move the object around based on framecount

    la      t8, framecount
    lw      t9, 0(t8)

    sll     a0, t9, 16 + 7
    srl     a0, 15
    jal     SmoothStep16
    nop

    or      s2, v0, r0
    la      t8, framecount
    lw      t9, 0(t8)

    sll     a0, t9, 16 + 7
    srl     a0, 15
    jal     SmoothStep16
    subiu   a0, 0x7FFF

    subu    s2, r0, s2
    addiu   s2, 0x7FFF
    sll     s2, 1

    subu    v0, r0, v0
    addiu   v0, 0x7FFF
    sll     v0, 1

    // s2: cos-like
    // v0: sin-like

    la      t8, view_mat1

    sh      s2, MAT_XX_FRAC(t8)
    sra     t9, s2, 16
    sh      t9, MAT_XX(t8)

    subu    v0, r0, v0
    sh      v0, MAT_XZ_FRAC(t8)
    sra     t9, v0, 16
    sh      t9, MAT_XZ(t8)

    subu    v0, r0, v0
    sh      v0, MAT_ZX_FRAC(t8)
    sra     t9, v0, 16
    sh      t9, MAT_ZX(t8)

    sh      s2, MAT_ZZ_FRAC(t8)
    sra     t9, s2, 16
    sh      t9, MAT_ZZ(t8)

    or      a0, s0, r0

    // init
    gPipeSync()
    gSetSegment0(0) // set to 0 so that 00-prefixed addresses are absolute.
    gTextureOff()
    gSetCombine(15,15,31,4,7,7,7,4, 15,15,31,4,7,7,7,4)
    gSetScissor(0, 0, 0, WIDTH, HEIGHT) // TODO: use mode enum
    gSetBlendColor(0,0,0,0)
    gClipRatio(2)
    gSetZImage(VIDEO_Z_IMAGE)

    // this overwrites our color image address so we must do it first:
    gClearZImage(WIDTH, HEIGHT, VIDEO_Z_IMAGE)
    gPipeSync()

    WriteCB(G_SETCIMB_UPPER_WORD | (WIDTH - 1), s1)

if HICOLOR {
    gSetFillColor(0x444444FF) // dark gray
} else {
    gSetFillColor(0x42114211) // dark gray
}

    gFillRect(0, 0, WIDTH - 1, HEIGHT - 1)
    gPipeSync()

if HICOLOR {
    gSetFillColor(0xFFFFFFFF) // white
} else {
    gSetFillColor(0xFFFFFFFF) // white
}

    gPipeSync()

    // note that all the coordinates are inclusive!
if HIRES {
    gFillRect(312, 232, 327, 247)
} else {
    gFillRect(156, 116, 163, 123)
}

    gPipeSync()
    gViewport(viewport)
    gPerspNorm(PERSPECTIVE_NORMALIZATION)
    gMatrix(view_mat0, G_MTX_NOPUSH | G_MTX_LOAD | G_MTX_PROJECTION)
    gMatrix(view_mat1, G_MTX_NOPUSH | G_MTX_MUL | G_MTX_PROJECTION)

    gPipeSync()
    gSetCombine(0,0,0,4,0,0,0,4, 0,0,0,4,0,0,0,4)
variable upper(G_PM_NPRIMITIVE | G_CYC_1CYCLE | G_TP_NONE | G_TD_CLAMP | G_TL_TILE | G_TT_NONE | G_TF_AVERAGE | G_TC_FILT | G_CK_NONE | G_CD_MAGICSQ | G_AD_PATTERN)
variable lower(AA_EN | Z_CMP | Z_UPD | IM_RD | CVG_DST_CLAMP | ZMODE_OPA | ALPHA_CVG_SEL | G_BL_CLR_IN << 30 | G_BL_A_IN << 26 | G_BL_CLR_MEM << 22 | G_BL_A_MEM << 18)
    gSetOtherMode(upper, lower)
    gGeometryMode(0, G_ZBUFFER | G_SHADE | G_CULL_FRONT | G_SHADING_SMOOTH)

    gSetSegment6(model)
    gMatrix(model_mat, G_MTX_NOPUSH | G_MTX_LOAD | G_MTX_MODELVIEW)
    gDisplayList((6 << 24) | MODEL_START)

if 0 {
    // debug: display coverage values onscreen.
    gPipeSync()
    gSetOtherMode(G_CYC_1CYCLE, G_ZS_PRIM | IM_RD | FORCE_BL | G_BL_CLR_IN << 30 | G_BL_0 << 26 | G_BL_CLR_BL << 22 | G_BL_A_MEM << 18)
    gSetBlendColor(0xFF,0xFF,0xFF,0xFF)
    gSetPrimDepth(0xFFFF, 0xFFFF)
    gFillRect(0, 0, WIDTH - 1, HEIGHT - 1)
}

    // finish.
    gFullSync()
    gEndList()

    la      t8, framecount
    lw      t9, 0(t8)
    addiu   t9, 1
    sw      t9, 0(t8)

    lw      ra, 0x10(sp)
    lw      s0, 0x14(sp)
    lw      s1, 0x18(sp)
    lw      s2, 0x1C(sp)
    jr      ra
    addiu   sp, 0x20

print {dpos} / 8, "\n"

align(8)

viewport:
    // note that the third parameters here affect the range of Z-buffering.
    dh WIDTH/2*4, HEIGHT/2*4, 0x1FF, 0 // scale
    dh WIDTH/2*4, HEIGHT/2*4, 0x1FF, 0 // translation

view_mat0:
if FOV90 {
    Mat.X($0000'C000, $0000'0000, $0000'0000, $0000'0000)
    Mat.Y($0000'0000, $0001'0000, $0000'0000, $0000'0000)
} else {
    Mat.X($0001'4C8D, $0000'0000, $0000'0000, $0000'0000)
    Mat.Y($0000'0000, $0001'BB67, $0000'0000, $0000'0000)
}
    Mat.Z($0000'0000, $0000'0000, $FFFE'FF9A, $FFFF'0000)
    Mat.W($0000'0000, $0000'0000, $FFEB'FC00, $0000'0000)
    Mat.rix()
constant PERSPECTIVE_NORMALIZATION($000A)

view_mat1:
    Mat.X($0001'0000, $0000'0000, $0000'0000, $0000'0000)
    Mat.Y($0000'0000, $0001'0000, $0000'0000, $0000'0000)
    Mat.Z($0000'0000, $0000'0000, $0001'0000, $0000'0000)
if FOV90 {
    Mat.W($0000'0000, $FFD4'0000, $FF80'0000, $0001'0000)
} else {
    Mat.W($0000'0000, $FFD4'0000, $FF40'0000, $0001'0000)
}
    Mat.rix()

model_mat:
    MatObject(0,0,0, 0x0800)

identity:
    MatEye()

macro _g(variable c, variable a, variable b) {
    dw (c << 24) | a, b
}

if 0 {
model: // a colorful cube
constant S(0x400)
    // TODO: write a macro for this struct
    dh  -S, -S, -S, 0,  0, 0, 0x0000, 0x00FF
    dh  -S, -S, +S, 0,  0, 0, 0x0000, 0xFFFF
    dh  -S, +S, -S, 0,  0, 0, 0x00FF, 0x00FF
    dh  -S, +S, +S, 0,  0, 0, 0x00FF, 0xFFFF
    dh  +S, -S, -S, 0,  0, 0, 0xFF00, 0x00FF
    dh  +S, -S, +S, 0,  0, 0, 0xFF00, 0xFFFF
    dh  +S, +S, -S, 0,  0, 0, 0xFFFF, 0x00FF
    dh  +S, +S, +S, 0,  0, 0, 0xFFFF, 0xFFFF

constant MODEL_START(pc() - model)
    gPipeSync()
    gVertex(0x06000000, 8, 0)
    gQuadTri(0, 1, 3, 2)
    gQuadTri(1, 5, 7, 3)
    gQuadTri(5, 4, 6, 7)
    gQuadTri(4, 0, 2, 6)
    gQuadTri(4, 5, 1, 0)
    gQuadTri(2, 3, 7, 6)
    gEndList()
} else {
    constant MODEL_START(0)
    insert model, "res/teapot.F3D"
}
