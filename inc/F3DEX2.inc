// gMatrix: params argument
constant G_MTX_NOPUSH(0 << 0)
constant G_MTX_PUSH(1 << 0)
//
constant G_MTX_MUL(0 << 1)
constant G_MTX_LOAD(1 << 1)
//
constant G_MTX_MODELVIEW(0 << 2)
constant G_MTX_PROJECTION(1 << 2)

// gMoveWord: index argument
constant G_MW_MATRIX(0x0)
constant G_MW_NUMLIGHT(0x2)
constant G_MW_CLIP(0x4)
constant G_MW_SEGMENT(0x6)
constant G_MW_FOG(0x8)
constant G_MW_LIGHTCOL(0xA)
constant G_MW_FORCEMTX(0xC)
constant G_MW_PERSPNORM(0xE)

// gMoveWord: offset argument
constant G_MWO_CLIP_RNX(0x04)
constant G_MWO_CLIP_RNY(0x0C)
constant G_MWO_CLIP_RPX(0x14)
constant G_MWO_CLIP_RPY(0x1C)

// gMoveMemory: index argument
constant G_MV_MMTX(2)
constant G_MV_PMTX(6)
constant G_MV_VIEWPORT(8)
constant G_MV_LIGHT(10)
constant G_MV_POINT(12)
constant G_MV_MATRIX(14)

// gSetTImage, gSetCImage: fmt argument
constant G_IM_FMT_RGBA(0)
constant G_IM_FMT_YUV(1)
constant G_IM_FMT_CI(2)
constant G_IM_FMT_IA(3)
constant G_IM_FMT_I(4)

// gSetTImage, gSetCImage: size argument
constant G_IM_SIZE_4(0)
constant G_IM_SIZE_8(1)
constant G_IM_SIZE_16(2)
constant G_IM_SIZE_32(3)
constant G_IM_SIZE_DD(5)

// TODO:
constant G_TX_NOMIRROR(0)
constant G_TX_MIRROR(1)
constant G_TX_WRAP(0)
constant G_TX_CLAMP(2)

// TODO: actually unrelated to the last set of enums
constant G_TX_RENDERTILE(0)
constant G_TX_LOADTILE(7)

// gGeometryMode: clearbits, setbits arguments
constant G_ZBUFFER(1 << 0)
constant G_SHADE(1 << 2)
constant G_CULL_FRONT(1 << 9)
constant G_CULL_BACK(1 << 10)
constant G_FOG(1 << 16)
constant G_LIGHTING(1 << 17)
constant G_TEXTURE_GEN(1 << 18)
constant G_TEXTURE_GEN_LINEAR(1 << 19)
constant G_LOD(1 << 20) // unimplemented (presumably no effect)
constant G_SHADING_SMOOTH(1 << 21)
constant G_CLIPPING(1 << 23)
constant G_CULL_BOTH(G_CULL_FRONT | G_CULL_BACK)

// gSetOtherModeL: shift amount
constant G_MDSFT_ALPHACOMPARE(0)
constant G_MDSFT_ZSRCSEL(2)
constant G_MDSFT_RENDERMODE(3)
constant G_MDSFT_BLENDER(16)

// gSetOtherModeH: shift amount
constant G_MDSFT_BLENDMASK(0) // unsupported (presumably no effect)
constant G_MDSFT_ALPHADITHER(4)
constant G_MDSFT_RGBDITHER(6)
constant G_MDSFT_COMBKEY(8)
constant G_MDSFT_TEXTCONV(9)
constant G_MDSFT_TEXTFILT(12)
constant G_MDSFT_TEXTLUT(14)
constant G_MDSFT_TEXTLOD(16)
constant G_MDSFT_TEXTDETAIL(17)
constant G_MDSFT_TEXTPERSP(19)
constant G_MDSFT_CYCLETYPE(20)
constant G_MDSFT_COLORDITHER(22) // unsupported (presumably no effect)
constant G_MDSFT_PIPELINE(23)

// gSetOtherModeH gPipelineMode
constant G_PM_1PRIMITIVE(1 << G_MDSFT_PIPELINE)
constant G_PM_NPRIMITIVE(0 << G_MDSFT_PIPELINE)

// gSetOtherModeH gSetCycleType
constant G_CYC_1CYCLE(0 << G_MDSFT_CYCLETYPE)
constant G_CYC_2CYCLE(1 << G_MDSFT_CYCLETYPE)
constant G_CYC_COPY(2 << G_MDSFT_CYCLETYPE)
constant G_CYC_FILL(3 << G_MDSFT_CYCLETYPE)

// gSetOtherModeH gSetTexturePersp
constant G_TP_NONE(0 << G_MDSFT_TEXTPERSP)
constant G_TP_PERSP(1 << G_MDSFT_TEXTPERSP)

// gSetOtherModeH gSetTextureDetail
constant G_TD_CLAMP(0 << G_MDSFT_TEXTDETAIL)
constant G_TD_SHARPEN(1 << G_MDSFT_TEXTDETAIL)
constant G_TD_DETAIL(2 << G_MDSFT_TEXTDETAIL)

// gSetOtherModeH gSetTextureLOD
constant G_TL_TILE(0 << G_MDSFT_TEXTLOD)
constant G_TL_LOD(1 << G_MDSFT_TEXTLOD)

// gSetOtherModeH gSetTextureLUT
constant G_TT_NONE(0 << G_MDSFT_TEXTLUT)
constant G_TT_RGBA16(2 << G_MDSFT_TEXTLUT)
constant G_TT_IA16(3 << G_MDSFT_TEXTLUT)

// gSetOtherModeH gSetTextureFilter
constant G_TF_POINT(0 << G_MDSFT_TEXTFILT)
constant G_TF_AVERAGE(3 << G_MDSFT_TEXTFILT)
constant G_TF_BILERP(2 << G_MDSFT_TEXTFILT)

// gSetOtherModeH gSetTextureConvert
constant G_TC_CONV(0 << G_MDSFT_TEXTCONV)
constant G_TC_FILTCONV(5 << G_MDSFT_TEXTCONV)
constant G_TC_FILT(6 << G_MDSFT_TEXTCONV)

// gSetOtherModeH gSetCombineKey
constant G_CK_NONE(0 << G_MDSFT_COMBKEY)
constant G_CK_KEY(1 << G_MDSFT_COMBKEY)

// gSetOtherModeH gSetColorDither
constant G_CD_MAGICSQ(0 << G_MDSFT_RGBDITHER)
constant G_CD_BAYER(1 << G_MDSFT_RGBDITHER)
constant G_CD_NOISE(2 << G_MDSFT_RGBDITHER)
constant G_CD_DISABLE(3 << G_MDSFT_RGBDITHER)
constant G_CD_ENABLE(G_CD_NOISE) // for legacy code

// gSetOtherModeH gSetAlphaDither
constant G_AD_PATTERN(0 << G_MDSFT_ALPHADITHER)
constant G_AD_NOTPATTERN(1 << G_MDSFT_ALPHADITHER)
constant G_AD_NOISE(2 << G_MDSFT_ALPHADITHER)
constant G_AD_DISABLE(3 << G_MDSFT_ALPHADITHER)

// gSetOtherModeL gSetAlphaCompare
constant G_AC_NONE(0 << G_MDSFT_ALPHACOMPARE)
constant G_AC_THRESHOLD(1 << G_MDSFT_ALPHACOMPARE)
constant G_AC_DITHER(3 << G_MDSFT_ALPHACOMPARE)

// gSetOtherModeL gSetDepthSource
constant G_ZS_PIXEL(0 << G_MDSFT_ZSRCSEL)
constant G_ZS_PRIM(1 << G_MDSFT_ZSRCSEL)

// gSetOtherModeL gSetRenderMode
constant AA_EN(0x8) // enable anti-aliasing, except not really?
// Z stuff
constant Z_CMP(0x10) // compare pixels to Z buffer (typically used with Z_UPD)
constant Z_UPD(0x20) // write pixels to Z buffer (typically used with Z_CMP)
// coverage stuff
constant IM_RD(0x40)
constant CLR_ON_CVG(0x80)
constant CVG_DST_CLAMP(0)
constant CVG_DST_WRAP(0x100)
constant CVG_DST_FULL(0x200)
constant CVG_DST_SAVE(0x300)
// more Z stuff
constant ZMODE_OPA(0) // opaque
constant ZMODE_INTER(0x400) // interpenetrating
constant ZMODE_XLU(0x800) // translucent
constant ZMODE_DEC(0xC00) // decal
// more coverage stuff
constant CVG_X_ALPHA(0x1000)
constant ALPHA_CVG_SEL(0x2000)
// blending
constant FORCE_BL(0x4000) // no effect?

// blending modes
constant G_BL_CLR_IN(0)
constant G_BL_CLR_MEM(1)
constant G_BL_CLR_BL(2)
constant G_BL_CLR_FOG(3)
constant G_BL_1MA(0)
constant G_BL_A_MEM(1)
constant G_BL_A_IN(0)
constant G_BL_A_FOG(1)
constant G_BL_A_SHADE(2)
constant G_BL_1(2)
constant G_BL_0(3)

macro gNoOp() {
    // stalls the RDP (and not the RSP?)
    _g(0x00, 0, 0)
}

macro gVertex(variable vaddr, variable numv, variable vbidx) {
    // TODO: document
    if numv < 1 || numv > 32 {; error "numv out of range"; }
    if vbidx < 0 || vbidx > 31 {; error "vbidx out of range"; }
    _g(0x01, (numv << 12) | (((vbidx + numv) & 0x7F) << 1), vaddr)
}

macro gModifyVertex(variable vbidx, variable where, variable val) {
    // TODO: document
    if where != 0x10 && where != 0x14 && where != 0x18 && where != 0x1C {; error "invalid enum for where"; }
    if vbidx < 0 || vbidx > 0x7FFF {; error "vbidx out of range"; }
    _g(0x02, (where << 16) | (vbidx << 1), val)
}

macro gCullList(variable vfirst, variable vlast) {
    // TODO: document
    if vfirst < 0 || vfirst > 0x7FFF {; error "vfirst out of range"; }
    if vlast < 0 || vlast > 0x7FFF {; error "vlast out of range"; }
    _g(0x03, vfirst << 1, vlast << 1)
}

macro gBranchLessZ(variable newdl, variable vbidx, variable zval) {
    // TODO: check ranges, document
    gRdpHalf1(newdl)
    _g(0x04, ((vbidx * 5) << 12) | (vbidx * 2), zval)
}

macro gTri1(variable v0, variable v1, variable v2) {
    // draws two triangles given vertex indices relative to those loaded by gVertex.
    // for G_CULL_FRONT, the vertices should be given in a clockwise order.
    // for G_CULL_BACK, the vertices should be given in a counter-clockwise order.
    if v0 < 0 || v0 > 31 {; error "v0 out of range"; }
    if v1 < 0 || v1 > 31 {; error "v1 out of range"; }
    if v2 < 0 || v2 > 31 {; error "v2 out of range"; }
    _g(0x05, (v0 << 17) | (v1 << 9) | (v2 << 1), 0)
}

macro gTri2(variable a0, variable a1, variable a2, variable b0, variable b1, variable b2) {
    // draws two triangles given vertex indices relative to those loaded by gVertex.
    // some microcodes run this faster than the equivalent two gTri1 calls.
    // for G_CULL_FRONT, the vertices should be given in a clockwise order.
    // for G_CULL_BACK, the vertices should be given in a counter-clockwise order.
    if a0 < 0 || a0 > 31 {; error "a0 out of range"; }
    if a1 < 0 || a1 > 31 {; error "a1 out of range"; }
    if a2 < 0 || a2 > 31 {; error "a2 out of range"; }
    if b0 < 0 || b0 > 31 {; error "b0 out of range"; }
    if b1 < 0 || b1 > 31 {; error "b1 out of range"; }
    if b2 < 0 || b2 > 31 {; error "b2 out of range"; }
    _g(0x06, (a0 << 17) | (a1 << 9) | (a2 << 1), (b0 << 17) | (b1 << 9) | (b2 << 1))
}

macro gQuad(variable v0, variable v1, variable v2, variable v3) {
    // you really should be using gTri2 instead.
    // some microcodes don't support this.
    _g(0x07, (v0 << 17) | (v1 << 9) | (v2 << 1), (v0 << 17) | (v2 << 9) | (v3 << 1))
}

macro gLine3D(variable a, variable b) {
    // TODO: document, implement
    _g(0x08, a, b)
}

// these triangle commands are never used directly,
// instead, they are generated by the RSP
// by OR-ing the lowest byte of the current GeometryMode with 0xC8.

macro gTriFill(variable a, variable b) {
    // (internal use) fill triangle
    _g(0xC8, a, b)
}

macro gTriFillZ(variable a, variable b) {
    // (internal use) fill triangle utilizing z-buffer
    _g(0xC9, a, b)
}

macro gTriTexture(variable a, variable b) {
    // (internal use) texture triangle
    _g(0xCA, a, b)
}

macro gTriTextureZ(variable a, variable b) {
    // (internal use) texture triangle utilizing z-buffer
    _g(0xCB, a, b)
}

macro gTriShade(variable a, variable b) {
    // (internal use) shade triangle
    _g(0xCC, a, b)
}

macro gTriShadeZ(variable a, variable b) {
    // (internal use) shade triangle utilizing z-buffer
    _g(0xCD, a, b)
}

macro gTriShadeTexture(variable a, variable b) {
    // (internal use) shade and texture triangle
    _g(0xCE, a, b)
}

macro gTriShadeTextureZ(variable a, variable b) {
    // (internal use) shade and texture triangle utilizing z-buffer
    _g(0xCF, a, b)
}

macro gSpecial3(variable a, variable b) {
    // TODO: see if this actually does something
    _g(0xD3, a, b)
}

macro gSpecial2(variable a, variable b) {
    // TODO: see if this actually does something
    _g(0xD4, a, b)
}

macro gSpecial1(variable a, variable b) {
    // TODO: see if this actually does something
    _g(0xD5, a, b)
}

macro gDmaIo(variable flag, variable dmem, variable dram, variable size) {
    if flag != 0 && flag != 1 {; error "invalid enum for flag"; }
    // TODO: check more ranges
    _g(0xD6, (flag << 23) | (((dmem / 8) & 0x3FF) << 12) | (size - 1), dram)
}

macro gTexture(variable scaleS, variable scaleT, variable level, variable tile, variable on) {
    // TODO: document
    // scaleS and scaleT are fractional values; e.g. 0x8000 is 0.5.
    // level + 1: number of mipmaps
    if level < 0 || level > 7 {; error "level out of range"; }
    if tile < 0 || tile > 7 {; error "tile out of range"; }
    //if on != 0 && on != 1 {; error "invalid enum for on"; } // FIXME
    if scaleS < 0 || scaleS > 0xFFFF {; error "scaleS out of range"; }
    if scaleT < 0 || scaleT > 0xFFFF {; error "scaleT out of range"; }
    _g(0xD7, (level << 11) | (tile << 8) | on, (scaleS << 16) | scaleT)
}

macro gPopMatrix(variable num) {
    // TODO: document, better range?
    if num < 0 || num > 0x3FFFFFF {; error "num out of range"; }
    _g(0xD8, 0x380002, num << 6)
}

macro gGeometryMode(variable clearbits, variable setbits) {
    // TODO: document, add convenience macros
    _g(0xD9, clearbits, setbits)
}

macro gMatrix(variable mtxaddr, variable params) {
    // TODO: document, add convenience macros
    if params < 0 || params > 7 {; error "invalid enum for params"; }
    _g(0xDA, 0x380000 | params ^ G_MTX_PUSH, mtxaddr)
}

macro gMoveWord(variable index, variable offset, variable data) {
    // TODO: document, add (more) convenience macros
    if (index & 1) != 0 || index < 0 || index > 0xE {; error "invalid enum for index"; }
    if offset < 0 || offset > 0xFFFF {; error "offset out of range"; }
    if (offset & 3) != 0 {; error "offset unaligned"; }
    _g(0xDB, (index << 16) | offset, data)
}

macro gMoveMemory(variable size, variable index, variable offset, variable addr) {
    // TODO: document
    if size < 1 || size > 0x100 {; error "size out of range"; }
    if (index & 1) != 0 || index < 0 || index > 14 {; "invalid enum for index"; }
    if offset < 0 || offset > 0x7F8 {; error "offset out of range"; }
    if (offset & 7) != 0 {; error "offset unaligned"; }
    variable written_size(((size - 1) / 8) & 0x1F)
    _g(0xDC, (written_size << 19) | (offset << 5) | index, addr)
}

macro gLoadMicrocode(variable tstart, variable dstart, variable dsize) {
    // TODO: document
    if dsize < 0 || dsize > 0x1000 {; error "dsize out of range"; }
    gRdpHalf1(dstart)
    _g(0xDD, dsize, tstart)
}

macro gDisplayList(variable dl) {
    // "calls" another display list,
    // resuming execution from this point after "returning" with gEndList.
    _g(0xDE, 0, dl)
}

macro gBranchList(variable dl) {
    // jumps to another display list.
    _g(0xDE, 1 << 16, dl)
}

macro gEndList() {
    // ends a display list.
    // this either "returns" to the last gBranchList,
    // or in the absence of that, sets signal 2 and breaks.
    _g(0xDF, 0, 0)
}

macro gSpNoOp() {
    // stalls the RSP (and not the RDP?)
    _g(0xE0, 0, 0)
}

macro gRdpHalf1(variable wordhi) {
    // this command is used in other commands to carry additional information.
    _g(0xE1, 0, wordhi)
}

macro gSetOtherModeL(variable shift, variable length, variable data) {
    // TODO: document, add convenience macros.
    // starts clearing bits starting from shift
    // and upwards (towards the MSB) until length is met.
    // TODO: is a length of 0 valid?
    if shift < 0 || shift > 31 {; error "shift out of range"; }
    if length < 1 || length > 32 {; error "length out of range"; }
    if shift + length > 32 {; error "length exceeds word size for given shift"; }
    _g(0xE2, ((32 - shift - length) << 16) | (length - 1), data)
}

macro gSetOtherModeH(variable shift, variable length, variable data) {
    // TODO: document, add convenience macros.
    // starts clearing bits starting from shift
    // and upwards (towards the MSB) until length is met.
    // TODO: is a length of 0 valid?
    if shift < 0 || shift > 31 {; error "shift out of range"; }
    if length < 1 || length > 32 {; error "length out of range"; }
    if shift + length > 32 {; error "length exceeds word size for given shift"; }
    _g(0xE3, ((32 - shift - length) << 16) | (length - 1), data)
}

macro gTextureRect(variable ulx, variable uly, variable lrx, variable lry, variable tile, variable uls, variable ult, variable dsdx, variable dtdy) {
    // arguments: upper-left x, upper-left y, lower-right x, lower-right y,
    //            tile descriptor, texture S coord, texture T coord,
    //            change in S over X, change in T over Y.
    // TODO: document, check uls/ult ranges
    if ulx < 0 || ulx > 1024 * 4 {; error "ulx out of range"; }
    if uly < 0 || uly > 1024 * 4 {; error "uly out of range"; }
    if lrx < 0 || lrx > 1024 * 4 {; error "lrx out of range"; }
    if lry < 0 || lry > 1024 * 4 {; error "lry out of range"; }
    if tile < 0 || tile > 7 {; error "tile out of range"; }
    _g(0xE4, (lrx << 12) | lry, (tile << 24) | (ulx << 12) | uly)
    gRdpHalf1((uls << 16) | ult)
    gRdpHalf2((dsdx << 16) | dtdy)
}

macro gTextureRect(variable ulx, variable uly, variable lrx, variable lry, variable tile, variable uls, variable ult, variable dtdx, variable dsdy) {
    // same as gTextureRect except flipped along the diagonal:
    // S is instead based on Y, and T is instead based on X.
    // the last two arguments have accordingly different names.
    // TODO: check uls/ult ranges
    if ulx < 0 || ulx > 1024 * 4 {; error "ulx out of range"; }
    if uly < 0 || uly > 1024 * 4 {; error "uly out of range"; }
    if lrx < 0 || lrx > 1024 * 4 {; error "lrx out of range"; }
    if lry < 0 || lry > 1024 * 4 {; error "lry out of range"; }
    if tile < 0 || tile > 7 {; error "tile out of range"; }
    _g(0xE4, (lrx << 12) | lry, (tile << 24) | (ulx << 12) | uly)
    gRdpHalf1((uls << 16) | ult)
    gRdpHalf2((dtdx << 16) | dsdy)
}

macro gRdpLoadSync() {
    // wait for a texture to load.
    _g(0xE6, 0, 0)
}

macro gRdpPipeSync() {
    // wait for the last primitive to finish rendering.
    _g(0xE7, 0, 0)
}

macro gRdpTileSync() {
    // wait for rendering to finish before changing tile attributes.
    // TODO: better document.
    _g(0xE8, 0, 0)
}

macro gRdpFullSync() {
    // finish rendering. usually followed by a final gEndList command.
    _g(0xE9, 0, 0)
}

macro gSetKeyGB() {
    // TODO
    _g(0xEA, 0, 0)
}

macro gSetKeyR() {
    // TODO
    _g(0xEB, 0, 0)
}

macro gSetConvert() {
    // TODO
    _g(0xEC, 0, 0)
}

macro gSetScissor(variable mode, variable ulx, variable uly, variable lrx, variable lry) {
    // constrains rendering to a rectangle.
    // arguments: mode, upper-left x, upper-left y, lower-right x, lower-right y.
    // the lower-right coordinates are exclusive? whereas gFillRect is inclusive.
    if mode != 0 && mode != 2 && mode != 3 {; error "invalid enum for mode"; }
    if ulx < 0 || ulx > 1024 {; error "ulx out of range"; }
    if uly < 0 || uly > 1024 {; error "uly out of range"; }
    if lrx < 0 || lrx > 1024 {; error "lrx out of range"; }
    if lry < 0 || lry > 1024 {; error "lry out of range"; }
    // setting lrx < ulx or lry < uly is probably allowed,
    // though i don't know what it would do.
    _g(0xED, (ulx << 14) | (uly << 2), (lrx << 14) | (lry << 2))
}

macro gSetPrimDepth(variable z, variable dz) {
    // fixes the Z value to a constant for the following primitives.
    // useful for 2.5D effects, maybe?
    // TODO: what are the ranges?
    _g(0xEE, 0, (z << 16) | dz)
}

macro gRdpSetOtherMode(variable omodeH, variable omodeL) {
    // like gSetOtherModeL and gSetOtherModeR combined,
    // but always overwriting existing values.
    // TODO: check enums
    _g(0xEF, omodeH, omodeL)
}

macro gLoadTLUT(variable tile, variable count) { // TODO: rename?
    // used for loading color palettes.
    // TODO: document properly.
    // NOTE: count is off-by-one compared to the official API.
    if tile < 0 || tile > 7 {; error "tile out of range"; }
    if count < 1 || count > 0x400 {; error "count out of range"; }
    _g(0xF0, 0, (tile << 24) | ((count - 1) << 14))
}

macro gRdpHalf2(variable wordlo) {
    // this command is used in other commands to carry additional information.
    _g(0xF1, 0, wordlo)
}

macro gSetTileSize(variable tile, variable uls, variable ult, variable lrs, variable lrt) {
    // TODO: document, check ranges
    if tile < 0 || tile > 7 {; error "tile out of range"; }
    _g(0xF2, (uls << 12) | ult, (tile << 24) | (lrs << 12) | lrt)
}

macro gLoadBlock(variable tile, variable uls, variable ult, variable texels, variable dxt) {
    // TODO: document, check ranges
    if tile < 0 || tile > 7 {; error "tile out of range"; }
    _g(0xF3, (uls << 12) | ult, (tile << 24) | (texels << 12) | dxt)
}

macro gLoadTile(variable tile, variable uls, variable ult, variable lrs, variable lrt) {
    // TODO: document, check ranges
    if tile < 0 || tile > 7 {; error "tile out of range"; }
    _g(0xF4, (uls << 12) | ult, (tile << 24) | (lrs << 12) | lrt)
}

macro gSetTile(variable fmt, variable size, variable line, variable tmem, variable tile, variable palette, variable cmT, variable maskT, variable shiftT, variable cmS, variable maskS, variable shiftS) {
    // TODO: everything.
    _g(0xF5, fmt << 21 | size << 19 | line << 9 | tmem, tile << 24 | palette << 20 | cmT << 18 | maskT << 14 | shiftT << 10 | cmS << 8 | maskS << 4 | shiftS)
}

macro gFillRect(variable ulx, variable uly, variable lrx, variable lry) {
    // TODO: describe.
    // NOTE: coordinates are inclusive.
    if ulx < 0 || ulx > 1024 {; error "ulx out of range"; }
    if uly < 0 || uly > 1024 {; error "uly out of range"; }
    if lrx < 0 || lrx > 1024 {; error "lrx out of range"; }
    if lry < 0 || lry > 1024 {; error "lry out of range"; }
    _g(0xF6, (lrx << 14) | (lry << 2), (ulx << 14) | (uly << 2))
}

macro gSetFillColor(variable color) {
    // TODO: describe.
    _g(0xF7, 0, color)
}

macro gSetFogColor(variable r, variable g, variable b, variable a) {
    // sets fog color. also used as a general-purpose color register for blending.
    // always given as 8-bit values regardless of any color formats being used.
    if r < 0 || r > 0xFF {; error "red out of range"; }
    if g < 0 || g > 0xFF {; error "green out of range"; }
    if b < 0 || b > 0xFF {; error "blue out of range"; }
    if a < 0 || a > 0xFF {; error "alpha out of range"; }
    _g(0xF8, 0, (r << 24) | (g << 16) | (b << 8) | a)
}

macro gSetBlendColor(variable r, variable g, variable b, variable a) {
    // sets a general-purpose color register for blending.
    // always given as 8-bit values regardless of any color formats being used.
    if r < 0 || r > 0xFF {; error "red out of range"; }
    if g < 0 || g > 0xFF {; error "green out of range"; }
    if b < 0 || b > 0xFF {; error "blue out of range"; }
    if a < 0 || a > 0xFF {; error "alpha out of range"; }
    _g(0xF9, 0, (r << 24) | (g << 16) | (b << 8) | a)
}

macro gSetPrimColor(variable minlevel, variable lodfrac, variable r, variable g, variable b, variable a) {
    // TODO: describe.
    // always given as 8-bit values regardless of any color formats being used.
    if minlevel < 0 || minlevel > 0xFF {; error "minlevel out of range"; }
    if lodfrac < 0 || lodfrac > 0xFF {; error "minlevel out of range"; }
    if r < 0 || r > 0xFF {; error "red out of range"; }
    if g < 0 || g > 0xFF {; error "green out of range"; }
    if b < 0 || b > 0xFF {; error "blue out of range"; }
    if a < 0 || a > 0xFF {; error "alpha out of range"; }
    _g(0xFA, (minlevel << 8) | lodfrac, (r << 24) | (g << 16) | (b << 8) | a)
}

macro gSetEnvColor(variable r, variable g, variable b, variable a) {
    // sets environment color. also used as a general-purpose color register for blending.
    if r < 0 || r > 0xFF {; error "red out of range"; }
    if g < 0 || g > 0xFF {; error "green out of range"; }
    if b < 0 || b > 0xFF {; error "blue out of range"; }
    if a < 0 || a > 0xFF {; error "alpha out of range"; }
    _g(0xFB, 0, (r << 24) | (g << 16) | (b << 8) | a)
}

macro gSetCombine(variable a0, variable b0, variable c0, variable d0, variable Aa0, variable Ab0, variable Ac0, variable Ad0, variable a1, variable b1, variable c1, variable d1, variable Aa1, variable Ab1, variable Ac1, variable Ad1) {
    // TODO: describe.
    if a0 != (a0 & 0xF) {; error "a0 out of range"; }
    if c0 != (c0 & 0x1F) {; error "c0 out of range"; }
    if Aa0 != (Aa0 & 0x7) {; error "Aa0 out of range"; }
    if Ac0 != (Ac0 & 0x7) {; error "Ac0 out of range"; }
    if a1 != (a1 & 0xF) {; error "a1 out of range"; }
    if c1 != (c1 & 0x1F) {; error "c1 out of range"; }
    if b0 != (b0 & 0xF) {; error "b0 out of range"; }
    if b1 != (b1 & 0xF) {; error "b1 out of range"; }
    if Aa1 != (Aa1 & 0x7) {; error "Aa1 out of range"; }
    if Ac1 != (Ac1 & 0x7) {; error "Ac1 out of range"; }
    if d0 != (d0 & 0x7) {; error "d0 out of range"; }
    if Ab0 != (Ab0 & 0x7) {; error "Ab0 out of range"; }
    if Ad0 != (Ad0 & 0x7) {; error "Ad0 out of range"; }
    if d1 != (d1 & 0x7) {; error "d1 out of range"; }
    if Ab1 != (Ab1 & 0x7) {; error "Ab1 out of range"; }
    if Ad1 != (Ad1 & 0x7) {; error "Ad1 out of range"; }
    variable upper((a0 << 20) | (c0 << 15) | (Aa0 << 12) | (Ac0 << 9) | (a1 << 5) | c1)
    variable lower((b0 << 28) | (b1 << 24) | (Aa1 << 21) | (Ac1 << 18) | (d0 << 15) | (Ab0 << 12) | (Ad0 << 9) | (d1 << 6) | (Ab1 << 3) | Ad1)
    _g(0xFC, upper, lower)
}

macro gSetTImage(variable fmt, variable size, variable width, variable imgaddr) {
    // sets the location in RDRAM for storing a texture image.
    // only required for the relevant copy operations.
    //if imgaddr & 0x1FFFFFFF > 0x800000 {; error "address out of range"; }
    if fmt < 0 || fmt > 4 {; error "invalid enum for fmt"; }
    if size < 0 || size > 5 || size == 4 {; error "invalid enum for size"; }
    if width < 1 || width > 1024 {; error "width out of range"; }
    _g(0xFD, (fmt << 21) | (size << 19) | (width - 1), imgaddr)
}

macro gSetZImage(variable imgaddr) {
    // sets the location in RDRAM for storing the Z-buffer.
    // only one is needed, and the format is fixed: (14 + 2) bits per pixel.
    //if imgaddr & 0x1FFFFFFF > 0x800000 {; error "address out of range"; }
    _g(0xFE, 0, imgaddr)
}

macro gSetCImage(variable fmt, variable size, variable width, variable imgaddr) {
    // sets the location in RDRAM for storing the color buffer.
    // sometimes refered to as a framebuffer?
    // do not set this to the same address as the VI color buffer
    // or else you will run into issues and wonder why nothing is blitting.
    // instead, allocate space for two color buffers and swap between them.
    if fmt < 0 || fmt > 4 {; error "invalid enum for fmt"; }
    if size < 0 || size > 5 || size == 4 {; error "invalid enum for size"; }
    if width < 1 || width > 1024 {; error "width out of range"; }
    _g(0xFF, (fmt << 21) | (size << 19) | (width - 1), imgaddr)
}

// from here-on it's just convenience.

macro gLoadSync() {; gRdpLoadSync(); }
macro gPipeSync() {; gRdpPipeSync(); }
macro gTileSync() {; gRdpTileSync(); }
macro gFullSync() {; gRdpFullSync(); }
macro gSetOtherMode(variable omodeH, variable omodeL) {; gRdpSetOtherMode(omodeH, omodeL); }

macro gVtx(variable vaddr, variable numv, variable vbidx) {; gVertex(vaddr, numv, vbidx); }
macro gModifyVtx(variable vbidx, variable where, variable val) {; gModifyVertex(vbidx, where, val); }

macro gTextureOff() {; gTexture(0xFFFF, 0xFFFF, 0, 0, 0); }

// possible idea for the future: keeping track of segment addresses in bass defines?
macro gSetSegment0(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x0 * 4, vaddr); }
macro gSetSegment1(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x1 * 4, vaddr); }
macro gSetSegment2(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x2 * 4, vaddr); }
macro gSetSegment3(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x3 * 4, vaddr); }
macro gSetSegment4(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x4 * 4, vaddr); }
macro gSetSegment5(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x5 * 4, vaddr); }
macro gSetSegment6(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x6 * 4, vaddr); }
macro gSetSegment7(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x7 * 4, vaddr); }
macro gSetSegment8(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x8 * 4, vaddr); }
macro gSetSegment9(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0x9 * 4, vaddr); }
macro gSetSegmentA(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0xA * 4, vaddr); }
macro gSetSegmentB(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0xB * 4, vaddr); }
macro gSetSegmentC(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0xC * 4, vaddr); }
macro gSetSegmentD(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0xD * 4, vaddr); }
macro gSetSegmentE(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0xE * 4, vaddr); }
macro gSetSegmentF(variable vaddr) {; gMoveWord(G_MW_SEGMENT, 0xF * 4, vaddr); }

macro gQuadTri(variable v0, variable v1, variable v2, variable v3) {
    gTri2(v0, v1, v2, v2, v3, v0)
}

macro gClipRatio(variable n) {
    // specifies the ratio between the clipping and scissoring boxes.
    // Frustrum Ratio?
    if n < 1 || n > 6 {; error "n out of range"; }
    gMoveWord(G_MW_CLIP, G_MWO_CLIP_RNX, n)
    gMoveWord(G_MW_CLIP, G_MWO_CLIP_RNY, n)
    gMoveWord(G_MW_CLIP, G_MWO_CLIP_RPX, 0x10000 - n)
    gMoveWord(G_MW_CLIP, G_MWO_CLIP_RPY, 0x10000 - n)
}

macro gClearZImage(variable width, variable height, variable imgaddr) {
    gSetCImage(G_IM_FMT_RGBA, G_IM_SIZE_16, width, imgaddr)
    gSetOtherModeH(20, 2, 0x00300000) // TODO: use enums
    gSetOtherModeL(3, 1, 0x00000000) // TODO: use enums
    gSetFillColor(0xFFFCFFFC)
    gFillRect(0, 0, width - 1, height - 1)
}

macro gViewport(variable viewport) {
    gMoveMemory(16, G_MV_VIEWPORT, 0, viewport)
}

macro gPerspNorm(variable norm) {
    if norm < 1 || norm > 0xFFFF {; error "norm out of range"; }
    gMoveWord(G_MW_PERSPNORM, 0, norm)
}

macro gLoadPal256(variable paladdr) {
    gSetTImage(G_IM_FMT_RGBA, G_IM_SIZE_16, 1, paladdr)
    gTileSync()
    gSetTile(0, 0, 0, 256, G_TX_LOADTILE, 0, 0, 0, 0, 0, 0, 0)
    gLoadSync()
    gLoadTLUT(G_TX_LOADTILE, 256)
    gPipeSync()
}

variable result(0)
macro texlog2(variable x) {
    // lol this macro
    if x == 0 {; error "can't let you do that, starfox"; }
    if x == 1 {; global evaluate result(0); }
    if x == 2 {; global evaluate result(1); }
    if x == 4 {; global evaluate result(2); }
    if x == 8 {; global evaluate result(3); }
    if x == 16 {; global evaluate result(4); }
    if x == 32 {; global evaluate result(5); }
    if x == 64 {; global evaluate result(6); }
    if x == 128 {; global evaluate result(7); }
    if x == 256 {; global evaluate result(8); }
    // TODO: default to error.
}

macro gLoadTex(variable addr, variable fmt, variable size, variable width, variable height) {
    // this macro omits the cms, cmt, masks, maskt, shifts, shiftt args,
    // and assumes you want the texture to wrap.
    // TODO: merge fmt and size argument enums? might be less of a headache.

    if fmt == G_IM_SIZE_4 {
        error "unimplemented" // TODO: specialized macro for 4-bit textures.
    }

    variable cm(G_TX_NOMIRROR | G_TX_WRAP)
    texlog2(width)
    variable log2_w({result})
    texlog2(height)
    variable log2_h({result})

    if size == G_IM_SIZE_4 {
        variable incr(3)
        variable shift(2)
        variable bytes(0)
        variable line_bytes(0)
        variable fake_size(G_IM_SIZE_16)
    } else if size == G_IM_SIZE_8 {
        variable incr(1)
        variable shift(1)
        variable bytes(1)
        variable line_bytes(1)
        variable fake_size(G_IM_SIZE_16)
    } else if size == G_IM_SIZE_16 {
        variable incr(0)
        variable shift(0)
        variable bytes(2)
        variable line_bytes(2)
        variable fake_size(G_IM_SIZE_16)
    } else if size == G_IM_SIZE_32 {
        variable incr(0)
        variable shift(0)
        variable bytes(4)
        variable line_bytes(2)
        variable fake_size(G_IM_SIZE_32)
    }

    variable texels((width * height + incr) >> shift)
    variable words(width * bytes / 8)
    if words < 1 {; variable words(1); }
    variable dxt((0x800 + words - 1) / words)
    variable lines(((width * line_bytes) + 7) >> 3)

    gSetTImage(fmt, fake_size, 1, addr)
    gSetTile(fmt, fake_size, 0, 0, G_TX_LOADTILE, 0, 0, 0, 0, 0, 0, 0)
    gLoadSync()

    gLoadBlock(G_TX_LOADTILE, 0, 0, texels - 1, dxt)
    gPipeSync()

    gSetTile(fmt, size, lines, 0, G_TX_RENDERTILE, 0, cm, log2_w, 0, cm, log2_h, 0)
    gSetTileSize(G_TX_RENDERTILE, 0, 0, (width - 1) << 2, (height - 1) << 2)
}

macro gReset() {
    // set some sane values on both RSP and RDP.
    // TODO: remove redundant syncs.
    gPipeSync()
    gLoadSync()
    gTileSync()
    gSetCombine(0,0,0,4,0,0,0,4, 0,0,0,4,0,0,0,4) // G_CC_SHADE
    // G_RM_OPA_SURF
    variable clk1(G_BL_CLR_IN << 12 | G_BL_0 << 8 | G_BL_CLR_IN << 4 | G_BL_1)
    variable clk2(G_BL_CLR_IN << 12 | G_BL_0 << 8 | G_BL_CLR_IN << 4 | G_BL_1)
    variable upper(G_CYC_1CYCLE | G_PM_1PRIMITIVE | G_TL_TILE | G_TT_NONE | G_TD_CLAMP | G_TP_PERSP | G_TF_BILERP | G_TC_FILT | G_CK_NONE | G_CD_MAGICSQ)
    variable lower(G_AC_NONE | CVG_DST_CLAMP | FORCE_BL | ZMODE_OPA | clk1 << 18 | clk2 << 16)
    gSetOtherMode(upper, lower)
    gTextureOff()
    gGeometryMode(0xFFFFFF, G_SHADE | G_SHADING_SMOOTH)
    gPipeSync()
}

// a tool to figure out just what the heck raw gSetCombine commands are doing.
macro gDisasmCombine(variable upper, variable lower) {
    if (upper >> 24) != 0xFC {; error "that's not a gSetCombine command!"; }
    variable a0((upper >> 20) & 0xF)
    variable c0((upper >> 15) & 0x1F)
    variable Aa0((upper >> 12) & 0x7)
    variable Ac0((upper >> 9) & 0x7)
    variable a1((upper >> 5) & 0xF)
    variable c1(upper & 0x1F)
    variable b0((lower >> 28) & 0xF)
    variable b1((lower >> 24) & 0xF)
    variable Aa1((lower >> 21) & 0x7)
    variable Ac1((lower >> 18) & 0x7)
    variable d0((lower >> 15) & 0x7)
    variable Ab0((lower >> 12) & 0x7)
    variable Ad0((lower >> 9) & 0x7)
    variable d1((lower >> 6) & 0x7)
    variable Ab1((lower >> 3) & 0x7)
    variable Ad1(lower & 0x7)
    print "gSetCombine(",a0,",",b0,",",c0,",",d0,", ",Aa0,",",Ab0,",",Ac0,",",Ad0,", ",a1,",",b1,",",c1,",",d1,", ",Aa1,",",Ab1,",",Ac1,",",Ad1,")\n"
}
