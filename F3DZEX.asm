// this file implements the bootloader and main program for:
// RSP Gfx ucode F3DZEX.NoN  fifo 2.08J Yoshitaka Yasumoto/Kawasedo 1999
// assemble with bass: https://github.com/ARM9/bass

arch n64.rsp
endian msb

constant r0(0); constant at(1); constant v0(2); constant v1(3)
constant a0(4); constant a1(5); constant a2(6); constant a3(7)
constant t0(8); constant t1(9); constant t2(10); constant t3(11)
constant t4(12); constant t5(13); constant t6(14); constant t7(15)
constant s0(16); constant s1(17); constant s2(18); constant s3(19)
constant s4(20); constant s5(21); constant s6(22); constant s7(23)
constant t8(24); constant t9(25); constant k0(26); constant k1(27)
constant gp(28); constant sp(29); constant fp(30); constant ra(31)

// n64-rsp.arch asserts that registers are preceeded by the letter "v",
// so this makes the most of it without colliding with the existing v0 and v1.
constant ec0(0); constant ec1(1); constant ec2(2); constant ec3(3)
constant ec4(4); constant ec5(5); constant ec6(6); constant ec7(7)
constant ec8(8); constant ec9(9); constant ec10(10); constant ec11(11)
constant ec12(12); constant ec13(13); constant ec14(14); constant ec15(15)
constant ec16(16); constant ec17(17); constant ec18(18); constant ec19(19)
constant ec20(20); constant ec21(21); constant ec22(22); constant ec23(23)
constant ec24(24); constant ec25(25); constant ec26(26); constant ec27(27)
constant ec28(28); constant ec29(29); constant ec30(30); constant ec31(31)

macro nops(new_pc) {
    while (pc() < {new_pc}) {
        nop
    }
}

// when we're in the RSP, the registers accessible by mtc0/mfc0
// are the ones associated with the RSP. they are memory-mapped as well.
constant SP_COP_MEM_ADDR(0)         // 0x04040000
constant SP_COP_DRAM_ADDR(1)        // 0x04040004
constant SP_COP_RD_LEN(2)           // 0x04040008
constant SP_COP_WR_LEN(3)           // 0x0404000C
constant SP_COP_STATUS(4)           // 0x04040010
constant SP_COP_DMA_FULL(5)         // 0x04040014
constant SP_COP_DMA_BUSY(6)         // 0x04040018
constant SP_COP_SEMAPHORE(7)        // 0x0404001C
// RDP registers:
constant SP_COP_COMMAND_START(8)    // 0x04100000
constant SP_COP_COMMAND_END(9)      // 0x04100004
constant SP_COP_COMMAND_CURRENT(10) // 0x04100008
constant SP_COP_RDP_STATUS(11)      // 0x0410000C
constant SP_COP_COUNT(12)           // 0x04100010
constant SP_COP_COMMAND_BUSY(13)    // 0x04100014
constant SP_COP_PIPE_BUSY(14)       // 0x04100018
constant SP_COP_TMEM_BUSY(15)       // 0x0410001C

output "bin/F3DZEX2.boot.bin", create
fill 0xD0

origin 0x00000000
base 0x04001000

    j       label_1054
    addi    at, r0, 0x0FC0 // Task data, tells us where the main program is

label_1008:
    lw      v0, 0x10(at) // TASK_UCODE
    addi    v1, r0, 0x0F7F // copy 0xF80 bytes
    addi    a3, r0, 0x1080 // to 0xA4001080
    mtc0    a3, SP_COP_MEM_ADDR
    mtc0    v0, SP_COP_DRAM_ADDR
    mtc0    v1, SP_COP_RD_LEN // start the DMA

label_1020:
-
    mfc0    a0, SP_COP_DMA_BUSY // wait until it finishes
    bnez    a0,-
    nop
    jal     func_103C // check error status
    nop
    jr      a3 // jump to the new code we just loaded
    mtc0    r0, SP_COP_SEMAPHORE

func_103C:
    mfc0    t0, SP_COP_STATUS
label_1040:
    andi    t0, t0, 1<<7 // check flag 7: signal 0 set
    bnez    t1,+ // branch if signal 0 is set
    nop
    jr      ra
+
    mtc0    r0, SP_COP_SEMAPHORE
    ori     t0, r0, 1<<9|1<<12|1<<14 // clear signal 0, set signal 1, set signal 2
    mtc0    t0, SP_COP_STATUS
    break   0
    nop

label_1054:
    lw      v0, 0x04(at) // load TASK_FLAGS
    andi    v0, v0, 2 // check flag 1
    beqz    v0,+
    nop
    jal     func_103C
    nop
    mfc0    v0, SP_COP_RDP_STATUS

// note: this marks 0x80, meaning everything below gets overwritten later.
    andi    v0, v0, 0x0100
    bgtz    v0,func_103C
    nop
+
    lw      v0, 0x18(at) // load TASK_UCODE_DATA
    lw      v1, 0x1C(at) // load TASK_UCODE_DATA_SIZE
    subi    v1, v1, 1 // subtract 1 for DMA quirk
-
    mfc0    fp, SP_COP_DMA_FULL
    bnez    fp,- // wait until the last DMA is finished?
    nop
    mtc0    r0, SP_COP_MEM_ADDR // target: A4000000 (DMEM)
    mtc0    v0, SP_COP_DRAM_ADDR
    mtc0    v1, SP_COP_RD_LEN // start the DMA
-
    mfc0    a0, SP_COP_DMA_BUSY // wait until it finishes
    bnez    a0,-
    nop
    jal     func_103C // check error status
    nop
    j       label_1008
    nop
    nop

output "bin/F3DZEX2.bin", create
fill 0xF80

origin 0x00000000
base 0x04001080

// be careful here, the "v" prefix in n64-rsp.arch is tricky

    vxor    vec0,vec0,vec0 // clear vector 0
    lqv     vec31[e0], 0x1B0(r0) // read some? data from DMEM+1B0
func_1088:
    lqv     vec30[e0], 0x1C0(r0) // read the next row, too
    addi    s7, r0, 0xBA8
    vadd    vec1,vec0,vec0 // multiply vector 0 by 2
    addi    s6, r0, 0xD00
    vsub    vec1,vec0,vec31[e8]
    lw      t3, 0xF0(r0)
    lw      t4, 0xFC4(r0)
    addi    at, r0, 0x2800
    beqz    t3,+
    mtc0    at, SP_COP_STATUS

    andi    t4, t4, 1
    beqz    t4,label_1130
    sw      r0, 0xFC4(r0)

    j       func_1168 & 0x1FFF
    lw      k0, 0xBF8(r0)

+
    mfc0    t3, SP_COP_RDP_STATUS
    andi    t3, t3, 1
    bnez    t3,+
    mfc0    v0, SP_COP_COMMAND_END

    lw      v1, 0xFE8(r0)
    sub     t3, v1, v0
    bgtz    t3,+
    mfc0    at, SP_COP_COMMAND_CURRENT

    lw      a0, 0xFEC(r0)
    beqz    at,+
    sub     t3,at,a0

    bgez    t3,+
    nop

    bne     at, v0,++
+
-
    mfc0    t3, SP_COP_RDP_STATUS

    andi    t3, t3, 0x0400
    bnez    t3,-
    addi    t3, r0, 1

    mtc0    t3, SP_COP_RDP_STATUS
    lw      v0, 0xFEC(r0)
    mtc0    v0, SP_COP_COMMAND_START
    mtc0    v0, SP_COP_COMMAND_END
+
    sw      v0, 0xF0(r0)
    lw      t3, 0xF4(r0)
    bnez    t3, label_1130
    lw      t3, 0xFE0(r0)

    sw      t3, 0xF4(r0)
label_1130:
    lw      at, 0xFD0(r0)
    lw      v0, 0x2E0(r0)
    lw      v1, 0x2E8(r0)
    lw      a0, 0x410(r0)
    lw      a1, 0x418(r0)
    add     v0, v0, at
    add     v1, v1, at
    sw      v0, 0x2E0(r0)
    sw      v1, 0x2E8(r0)
    add     a0, a0, at
    add     a1, a1, at
    sw      a0, 0x410(r0)
    sw      a1, 0x418(r0)
    lw      k0, 0xFF0(r0)
func_1168:
    addi    t3, r0, 0x2E8
    nop
    jal     func_1FB4 & 0x1FFF
    ori     t4, ra, 0

-
    addi    s3, r0, 0xA7
    ori     t8, k0, 0

    jal     func_1FD8 & 0x1FFF
    addiu   s4, r0, 0x0920

    addiu   k0, k0, 0x00A8
    addi    k1, r0, 0xFF58
    jal     func_1FC8 & 0x1FFF
func_1194:
    mfc0    at, SP_COP_STATUS
    lw      t9, 0x09C8(k1)
    beqz    k1,-
    andi    at, at, 0x0080

    sra     t4, t9, 24
    sll     t3, t4, 1
    lhu     t3, 0x036E(t3)
    bnez    at, label_1FAC
    lw      t8, 0x09CC(k1)

    jr      t3
    addiu   k1, k1, SP_COP_COMMAND_START
    jal     func_1224 & 0x1FFF
    lh      s4, 0x09C1(k1)

    andi    s3, t9, 0x0FF8
    sra     s4, s4, 2
    j       func_1FD8 & 0x1FFF
    addi    ra, r0, 0x1190

    lw      t3, 0x01EC(r0)
    and     t3, t3, t9
    or      t3, t3, t8
    j       func_1194 & 0x1FFF
    sw      t3, 0x01EC(r0)

label_11EC:
    lbu     at, 0x00DE(r0)
    beqz    at, label_1FAC
    addi    at, at, 0xFFFC

    j       label_1020 & 0x1FFF
    lw      k0, 0x0138(at)

    ldv     vec29[e0], 0xD0(r0)
    lw      t9, 0x00D8(r0)
    addi    s7, s7, SP_COP_COMMAND_START
    sdv     vec29[e0], 0x3F8(s7)
func_1210:
    sw      t8, 0x4(s7)
    sw      t9, 0x0(s7)
    j       label_1258 & 0x1FFF
    addi    s7, s7, SP_COP_COMMAND_START

    addi    ra, r0, 0x1210
func_1224:
    srl     t3, t8, 22
    andi    t3, t3, 0x003C
    lw      t3, 0x00F8(t3)
    sll     t8, t8, 8
    srl     t8, t8, 8
    jr      ra
    add     t8, t8, t3
    sw      t9, 0x00C8(r0)
    j       func_1210 & 0x1FFF
    sw      t8, 0x00CC(r0)

    sw      t9, 0x00C0(r0)
    j       func_1210 & 0x1FFF
    sw      t8, 0x00C4(r0)

label_1258:
    addi    ra, r0, 0x1194
label_125C:
    sub     t3, s7, s6
    blez    t3, label_1FD4
-
    mfc0    t4, SP_COP_DMA_BUSY

    lw      t8, 0x00F0(r0)
    addiu   s3, t3, 0x0158
    bnez    t4,-
    lw      t4, 0x0FEC(r0)

    mtc0    t8, SP_COP_COMMAND_END
    add     t3, t8, s3
    sub     t4, t4, t3
    bgez    t4,+
-
    mfc0    t3, SP_COP_RDP_STATUS

    andi    t3, t3, 0x0400
    bnez    t3,-
    lw      t8, 0x0FE8(r0)
-
    mfc0    t3, SP_COP_COMMAND_CURRENT
    beq     t3, t8,-
    nop

    mtc0    t8, SP_COP_COMMAND_START
+
-
    mfc0    t3, SP_COP_COMMAND_CURRENT
    sub     t3, t3, t8
    blez    t3,+

    sub     t3, t3, s3
    blez    t3,-

+
    add     t3, t8, s3
    sw      t3, 0x00F0(r0)
    addi    s3, s3, 0xFFFF
    addi    s4, s6, 0xDEA8
    xori    s6, s6, 0x0208
    j       func_1FD8 & 0x1FFF
    addi    s7, s6, 0xFEA8
label_12D8:
    addi    t3, r0, 0x0410
    j       func_1FB4 & 0x1FFF
    addi    t4, r0, 0x12D8
label_12E4:
    ori     fp, ra, 0x0
    addiu   a1, r0, 0x0014
    addiu   s2, r0, 0x6
    addiu   t7, r0, 0x09C8
    sh      at, 0x03CA(s2)
    sh      v0, 0x03CC(s2)
    sh      v1, 0x03CE(s2)
    sh      r0, 0x03D0(s2)
    lw      sp, 0x03CC(r0)
label_1308:
    lw      t1, 0x03F8(a1)
    lw      s0, 0x0024(v1)
    and     s0, s0, t1
    addi    s1, s2, 0xFFFA
    xori    s2, s2, 0x001C
    addi    s5, s2, 0xFFFA
func_1320:
    lhu     v0, 0x03D0(s1)
    addi    s1, s1, 0x2
    beqz    v0, label_14A8
    lw      t3, 0x0024(v0)

    and     t3, t3, t1
    beq     t3, s0, label_1494
    ori     s0, t3, 0x0

    beqz    s0,+
    ori     s3, v0, 0x0

    ori     s3, v1, 0x0
    ori     v1, v0, 0x0
+
    sll     t3, a1, 1

    ldv     vec2[e0], 0x180(t3)
    ldv     vec4[e0], 0x8(s3)
    ldv     vec5[e0], 0x0(s3)
    ldv     vec6[e0], 0x8(v1)
    ldv     vec7[e0], 0x0(v1)
    vmudh   vec3,vec2,vec31[e8]
    vmudn   vec8,vec4,vec2[e0]
    vmadh   vec9,vec5,vec2[e0]
    vmadn   vec10,vec6,vec3[e0]
    vmadh   vec11,vec7,vec3[e0]
    vaddc   vec8,vec8,vec8[e2]
    lqv     vec25[e0], 0x1D0(r0)
    vadd    vec9,vec9,vec9[e2]
    vaddc   vec10,vec10,vec10[e2]
    vadd    vec11,vec11,vec11[e2]
    vaddc   vec8,vec8,vec8[e5]
    vadd    vec9,vec9,vec9[e5]
    vaddc   vec10,vec10,vec10[e5]
    vadd    vec11,vec11,vec11[e5]
    vor     vec29,vec11,vec1[e8]
    vrcph   vec3[e11],vec11[e11]
    vrcpl   vec2[e11],vec10[e11]
    vrcph   vec3[e11],vec0[e8]
    vabs    vec29,vec29,vec25[e11]
    vmudn   vec2,vec2,vec29[e11]
    vmadh   vec3,vec3,vec29[e11]
    veq     vec3,vec3,vec0[e8]
    vmrg    vec2,vec2,vec31[e8]
    vmudl   vec29,vec10,vec2[e11]
    vmadm   vec11,vec11,vec2[e11]
    vmadn   vec10,vec0,vec0[e8]
    vrcph   vec13[e11],vec11[e11]
    vrcpl   vec12[e11],vec10[e11]
    vrcph   vec13[e11],vec0[e8]
label_13D8:
    vmudl   vec29,vec12,vec10[e0]
    vmadm   vec29,vec13,vec10[e0]
    vmadn   vec10,vec12,vec11[e0]
    vmadh   vec11,vec13,vec11[e0]
    vmudh   vec29,vec1,vec31[e9]
    vmadn   vec10,vec10,vec31[e12]
    vmadh   vec11,vec11,vec31[e12]
    vmudl   vec29,vec12,vec10[e0]
    vmadm   vec29,vec13,vec10[e0]
    vmadn   vec12,vec12,vec11[e0]
    vmadh   vec13,vec13,vec11[e0]
    vmudl   vec29,vec8,vec12[e0]
    luv     vec26[e0], 0x10(v1)
    vmadm   vec29,vec9,vec12[e0]
    llv     vec26[e8], 0x14(v1)
    vmadn   vec10,vec8,vec13[e0]
    luv     vec25[e0], 0x10(s3)
    vmadh   vec11,vec9,vec13[e0]
    llv     vec25[e8], 0x14(s3)
    vmudl   vec29,vec10,vec2[e11]
    vmadm   vec11,vec11,vec2[e11]
    vmadn   vec10,vec10,vec0[e8]
    vlt     vec11,vec11,vec1[e8]
    vmrg    vec10,vec10,vec31[e8]
    vsubc   vec29,vec10,vec1[e8]
    vge     vec11,vec11,vec0[e8]
    vmrg    vec10,vec10,vec1[e8]
    vmudn   vec2,vec10,vec31[e8]
    vmudl   vec29,vec6,vec10[e11]
    vmadm   vec29,vec7,vec10[e11]
    vmadl   vec29,vec4,vec2[e11]
    vmadm   vec24,vec5,vec2[e11]
    vmadn   vec23,vec0,vec0[e8]
    vmudm   vec29,vec26,vec10[e11]
    vmadm   vec22,vec25,vec2[e11]

    addi    a3, r0, 0x0
    addi    at, r0, 0x2
    sh      t7, 0x03D0(s5)
    j       func_19F4 & 0x1FFF
    addi    ra, r0, 0x9870

label_1478:
    slv     vec25[e0], 0x1C8(t7)
    ssv     vec26[e4], 0xCE(t7)
    suv     vec22[e0], 0x3C0(t7)
    slv     vec22[e8], 0x1C4(t7)
    ssv     vec3[e4], 0xCC(t7)
    addi    t7, t7, 0xFFD8
    addi    s5, s5, 0x2

label_1494:
    bnez    s0, func_1320
    ori     v1, v0, 0x0

    sh      v1, 0x03D0(s5)
    j       func_1320 & 0x1FFF
    addi    s5, s5, 0x2

label_14A8:
    sub     t3, s5, s2
    bltz    t3,+
    sh      r0, 0x03D0(s5)
    lhu     v1, 0x03CE(s5)
    bnez    a1, label_1308
    addi    a1, a1, 0xFFFC
    sw      r0, 0x03CC(r0)

-
    lhu     at, 0x03CA(s2)
    lhu     v0, 0x03CC(s2)
    lhu     v1, 0x03CE(s5)
    mtc2    at,vec2[e10]
    vor     vec3,vec0,vec31[e13]
    mtc2    v0,vec4[e12]
    jal     func_1A7C & 0x1FFF
    mtc2    v1,vec2[e14]
    bne     s5, s2,-
    addi    s2, s2, 0x2

+
    jr      fp
    sw      sp, 0x03CC(r0)

    nops(0x4001780)

    lhu     s4, 0x0380(t9)
    jal     func_1224 & 0x1FFF
    lhu     at, 0x09C1(k1)

    sub     s4, s4, at
    jal     func_1FD8 & 0x1FFF
    addi    s3, at, 0xFFFF

    lhu     a1, 0x01EC(r0)
    srl     at, at, 3
    sub     t7, t9, at
    lhu     t7, 0x0380(t7)
    ori     t6, s4, 0x0
    lbu     t0, 0x01D9(r0)
    andi    a2, a1, 0x2
    bnez    a2, label_12D8
    andi    a3, a1, 0x1

    bnez    t0,+
    sll     a3, a3, 3

    sb      t9, 0x01D9(r0)
    addi    s5, r0, 0x0040
    addi    s4, r0, 0x0
    jal     func_1088 & 0x1FFF
    addi    s3, r0, 0x0080

+
    lqv     vec8[e0], 0x80(r0)
    lqv     vec10[e0], 0x90(r0)
    lqv     vec12[e0], 0xA0(r0)
    lqv     vec14[e0], 0xB0(r0)
    vadd    vec9,vec8,vec0[e8]
    ldv     vec9[e0], 0x88(r0)
    vadd    vec11,vec10,vec0[e8]
    ldv     vec11[e0], 0x98(r0)
    vadd    vec13,vec12,vec0[e8]
    ldv     vec13[e0], 0xA8(r0)
    vadd    vec15,vec14,vec0[e8]
    ldv     vec15[e0], 0xB8(r0)
    ldv     vec8[e8], 0x80(r0)
    ldv     vec10[e8], 0x90(r0)
    jal     func_19F4 & 0x1FFF
    ldv     vec12[e8], 0xA0(r0)

    jal     func_1FC8 & 0x1FFF
    ldv     vec14[e8], 0xB0(r0)

    ldv     vec20[e0], 0x0(t6)
    vmov    vec16[e13],vec21[e9]
    ldv     vec20[e8], 0x10(t6)
label_182C:
    vmudn   vec29,vec15,vec1[e8]
    lw      t3, 0x001C(t6)
    vmadh   vec29,vec11,vec1[e8]
    llv     vec22[e12], 0x8(t6)
    vmadn   vec29,vec12,vec20[e4]
    ori     t1, a2, 0x0
    vmadh   vec29,vec8,vec20[e4]
    lpv     vec2[e0], 0xB0(t1)
    vmadn   vec29,vec13,vec20[e5]
    sw      t3, 0x8(t6)
    vmadh   vec29,vec9,vec20[e5]
    lpv     vec7[e0], 0x8(t6)
    vmadn   vec23,vec14,vec20[e6]
    bnez    a2, label_13D8
    vmadh   vec24,vec10,vec20[e6]

    vge     vec27,vec25,vec31[e11]
    llv     vec22[e4], 0x18(t6)
    vge     vec3,vec25,vec0[e8]
    addi    at, at, 0xFFFC
    vmudl   vec29,vec23,vec18[e12]
    sub     t3, t0, a3
    vmadm   vec2,vec24,vec18[e12]
    sbv     vec27[e15], 0x73(t3)
    vmadn   vec21,vec0,vec0[e8]
    sbv     vec27[e7], 0x4B(t3)
    vmov    vec26[e9],vec3[e10]
    ssv     vec3[e12], 0xF4(t0)
    vmudn   vec7,vec23,vec18[e13]
    slv     vec25[e8], 0x1F0(t0)
    vmadh   vec6,vec24,vec18[e13]
    sdv     vec25[e0], 0x3C8(t0)
    vrcph   vec29[e8],vec2[e11]
    ssv     vec26[e12], 0xF6(t0)
    vrcpl   vec5[e11],vec21[e11]
    slv     vec26[e2], 0x1CC(t0)
    vrcph   vec4[e11],vec2[e15]
    ldv     vec3[e0], 0x8(t6)
    vrcpl   vec5[e15],vec21[e15]
    sra     t3, at, 31
    vrcph   vec4[e15],vec0[e8]
    andi    t3, t3, 0x0028
    vch     vec29,vec24,vec24[e7]
    addi    t7, t7, 0x0050
    vcl     vec29,vec23,vec23[e7]
    sub     t0, t7, t3
    vmudl   vec29,vec21,vec5[e0]
    dw      0x484A0800 // TODO: unknown instruction. similar to mfc2/mtc2
    vmadm   vec29,vec2,vec5[e0]
    sdv     vec23[e8], 0x3E0(t0)
    vmadn   vec21,vec21,vec4[e0]
    ldv     vec20[e0], 0x20(t6)
    vmadh   vec2,vec2,vec4[e0]
    sdv     vec23[e0], 0x3B8(t7)
    vge     vec29,vec24,vec0[e8]
    lsv     vec23[e14], 0xE4(t0)
    vmudh   vec29,vec1,vec31[e9]
    sdv     vec24[e8], 0x3D8(t0)
    vmadn   vec26,vec21,vec31[e12]
    lsv     vec23[e6], 0xBC(t7)
    vmadh   vec25,vec2,vec31[e12]
    sdv     vec24[e0], 0x3B0(t7)
    vmrg    vec2,vec0,vec31[e15]
    ldv     vec20[e8], 0x30(t6)
    vch     vec29,vec24,vec6[e7]
    slv     vec3[e0], 0x1E8(t0)
    vmudl   vec29,vec26,vec5[e0]
    lsv     vec24[e14], 0xDC(t0)
    vmadm   vec29,vec25,vec5[e0]
    slv     vec3[e4], 0x1C0(t7)
    vmadn   vec5,vec26,vec4[e0]
    lsv     vec24[e6], 0xB4(t7)
    vmadh   vec4,vec25,vec4[e0]
    sh      t2, 0xFFFE(t0)
    vmadh   vec2,vec2,vec31[e15]
    sll     t3, t2, 4
    vcl     vec29,vec23,vec7[e7]
    dw      0x484A0800 // TODO: unknown instruction. similar to mfc2/mtc2
    vmudl   vec29,vec23,vec5[e7]
    ssv     vec5[e14], 0xFA(t0)
    vmadm   vec29,vec24,vec5[e7]
    addi    t6, t6, 0x0020
    vmadn   vec26,vec23,vec2[e7]
    sh      t2, 0xFFFC(t0)
    vmadh   vec25,vec24,vec2[e7]
    sll     t2, t2, 4
    vmudm   vec3,vec22,vec18[e0]
    sh      t3, 0xFFD6(t7)
    sh      t2, 0xFFD4(t7)
    vmudl   vec29,vec26,vec18[e12]
    ssv     vec5[e6], 0xD2(t7)
    vmadm   vec25,vec25,vec18[e12]
    ssv     vec4[e14], 0xF8(t0)
    vmadn   vec26,vec0,vec0[e8]
    ssv     vec4[e6], 0xD0(t7)
    slv     vec3[e4], 0x1EC(t0)
    vmudh   vec29,vec17,vec1[e8]
    slv     vec3[e12], 0x1C4(t7)
    vmadh   vec29,vec19,vec31[e11]
    vmadn   vec26,vec26,vec16[e0]
    bgtz    at, label_182C
    vmadh   vec25,vec25,vec16[e0]

    bltz    ra, label_1478
    vge     vec3,vec25,vec0[e8]

    slv     vec25[e8], 0x1F0(t0)
    vge     vec27,vec25,vec31[e11]
    slv     vec25[e0], 0x1C8(t7)
    ssv     vec26[e12], 0xF6(t0)
    ssv     vec26[e4], 0xCE(t7)
    ssv     vec3[e12], 0xF4(t0)
    beqz    a3, func_1194
    ssv     vec3[e4], 0xCC(t7)

    sbv     vec27[e15], 0x6B(t0)
    j       func_1194 & 0x1FFF
    sbv     vec27[e7], 0x43(t7)

func_19F4:
    addi    t5, r0, 0x0180
    ldv     vec16[e0], 0xE0(r0)
    ldv     vec16[e8], 0xE0(r0)
    llv     vec29[e0], 0x60(t5)
    ldv     vec17[e0], 0xE8(r0)
    ldv     vec17[e8], 0xE8(r0)
    vlt     vec19,vec31,vec31[e11]
    vsub    vec21,vec0,vec16[e0]
    llv     vec18[e4], 0x68(t5)
    vmrg    vec16,vec16,vec29[e8]
    llv     vec18[e12], 0x68(t5)
    vmrg    vec19,vec0,vec1[e8]
    llv     vec18[e8], 0xDC(r0)
    vmrg    vec17,vec17,vec29[e9]
    lsv     vec18[e10], 0x6(t5)
    vmov    vec16[e9],vec21[e9]
    jr      ra
    addi    t0, s7, 0x0050
    jal     func_1A4C & 0x1FFF
    sw      t8, 0x4(s7)

    addi    ra, r0, 0x1194
    sw      t9, 0x4(s7)
func_1A4C:
    lpv     vec2[e0], 0x0(s7)
    lbu     at, 0x5(s7)
    lbu     v0, 0x6(s7)
    lbu     v1, 0x7(s7)
    vor     vec3,vec0,vec31[e13]
    lhu     at, 0x0380(at)
    vmudn   vec4,vec1,vec31[e14]
    lhu     v0, 0x0380(v0)
    vmadl   vec2,vec2,vec30[e9]
    lhu     v1, 0x0380(v1)
    vmadn   vec4,vec0,vec0[e8]
    ori     a0, at, 0x0
func_1A7C:
    vnxor   vec5,vec0,vec31[e15]
    llv     vec6[e0], 0x18(at)
    vnxor   vec7,vec0,vec31[e15]
    llv     vec4[e0], 0x18(v0)
    vmov    vec6[e14],vec2[e13]
    llv     vec8[e0], 0x18(v1)
    vnxor   vec9,vec0,vec31[e15]
    lw      a1, 0x0024(at)
    vmov    vec8[e14],vec2[e15]
    lw      a2, 0x0024(v0)
    vadd    vec2,vec0,vec6[e9]
    lw      a3, 0x0024(v1)
    vsub    vec10,vec6,vec4[e0]
    andi    t3, a1, 0x70B0
    vsub    vec11,vec4,vec6[e0]
    and     t3, a2, t3
    vsub    vec12,vec6,vec8[e0]
    and     t3, a3, t3
    vlt     vec13,vec2,vec4[e9]
    vmrg    vec14,vec6,vec4[e0]
    bnez    t3, label_1FD4
    lbu     t3, 0x01EE(r0)

    vmudh   vec29,vec10,vec12[e9]
    lw      t4, 0x03CC(r0)
    vmadh   vec29,vec12,vec11[e9]
    or      a1, a1, a2
    vge     vec2,vec2,vec4[e9]
    or      a1, a1, a3
    vmrg    vec10,vec6,vec4[e0]
    lw      t3, 0x03C2(t3)
    vge     vec6,vec13,vec8[e9]
    mfc2    a2,vec29[e0]
    vmrg    vec4,vec14,vec8[e0]
    and     a1, a1, t4
    vmrg    vec14,vec8,vec14[e0]
    bnez    a1, label_12E4
    add     t3, a2, t3

    vlt     vec6,vec6,vec2[e0]
    bgez    t3, label_1FD4
    vmrg    vec2,vec4,vec10[e0]

    vmrg    vec10,vec10,vec4[e0]

    mfc2    at,vec14[e12]
    vmudn   vec4,vec14,vec31[e13]
    beqz    a2, label_1FD4
    vsub    vec6,vec2,vec14[e0]

    mfc2    v0,vec2[e12]
    vsub    vec8,vec10,vec14[e0]
    mfc2    v1,vec10[e12]
    vsub    vec11,vec14,vec2[e0]
    lw      a2, 0x01EC(r0)
    vsub    vec12,vec14,vec10[e0]
    llv     vec13[e0], 0x20(at)
    vsub    vec15,vec10,vec2[e0]
    llv     vec13[e8], 0x20(v0)
    vmudh   vec16,vec6,vec8[e8]
    llv     vec13[e12], 0x20(v1)
    vmadh   vec16,vec8,vec11[e8]
    sll     t3, a2, 10
    vsar    vec17,vec17,vec17[e8]
    bgez    t3,+
    vsar    vec16,vec16,vec16[e9]

    lpv     vec18[e0], 0x10(at)
    vmov    vec15[e10],vec6[e8]
    lpv     vec19[e0], 0x10(v0)
    vrcp    vec20[e8],vec15[e9]
    lpv     vec21[e0], 0x10(v1)
    vrcph   vec22[e8],vec17[e9]
    vrcpl   vec23[e9],vec16[e9]
    j       func_1BC0 & 0x1FFF
    vrcph   vec24[e9],vec0[e8]

+
    lpv     vec18[e0], 0x10(a0)
    vrcp    vec20[e8],vec15[e9]
    lbv     vec18[e6], 0x13(at)
    vrcph   vec22[e8],vec17[e9]
    lpv     vec19[e0], 0x10(a0)
    vrcpl   vec23[e9],vec16[e9]
    lbv     vec19[e6], 0x13(v0)
    vrcph   vec24[e9],vec0[e8]
    lpv     vec21[e0], 0x10(a0)
    vmov    vec15[e10],vec6[e8]
    lbv     vec21[e6], 0x13(v1)
func_1BC0:
    vrcp    vec20[e10],vec6[e9]
    vrcph   vec22[e10],vec6[e9]
    lw      a1, 0x0020(at)
    vrcp    vec20[e11],vec8[e9]
    lw      a3, 0x0020(v0)
    vrcph   vec22[e11],vec8[e9]
    lw      t0, 0x0020(v1)
    vmudl   vec18,vec18,vec30[e11]
    lbu     t1, 0x01E7(r0)
    vmudl   vec19,vec19,vec30[e11]
    sub     t3, a1, a3
    vmudl   vec21,vec21,vec30[e11]
    sra     t4, t3, 31
    vmov    vec15[e11],vec8[e8]
    and     t3, t3, t4
    vmudl   vec29,vec20,vec30[e15]
    sub     a1, a1, t3
    vmadm   vec22,vec22,vec30[e15]
    sub     t3, a1, t0
    vmadn   vec20,vec0,vec0[e8]
    sra     t4, t3, 31
    vmudm   vec25,vec15,vec30[e10]
    and     t3, t3, t4
    vmadn   vec15,vec0,vec0[e8]
    sub     a1, a1, t3
    vsubc   vec4,vec0,vec4[e0]
    sw      a1, 0x0010(s7)
    vsub    vec26,vec0,vec0[e0]
    llv     vec27[e0], 0x10(s7)
    vmudm   vec29,vec25,vec20[e0]
    dw      0x48058880
    vmadl   vec29,vec15,vec20[e0]
    lbu     a3, 0x01E6(r0)
    vmadn   vec20,vec15,vec22[e0]
    lsv     vec19[e14], 0x1C(v0)
    vmadh   vec15,vec25,vec22[e0]
    lsv     vec21[e14], 0x1C(v1)
    vmudl   vec29,vec23,vec16[e0]
    lsv     vec7[e14], 0x1E(v0)
    vmadm   vec29,vec24,vec16[e0]
    lsv     vec9[e14], 0x1E(v1)
    vmadn   vec16,vec23,vec17[e0]
    ori     t3, a2, 0x00C8
    vmadh   vec17,vec24,vec17[e0]
    or      t3, t3, t1
    vand    vec22,vec20,vec30[e13]
    vcr     vec15,vec15,vec30[e11]
    sb      t3, 0x0(s7)
    vmudh   vec29,vec1,vec30[e14]
    ssv     vec10[e2], 0x2(s7)
    vmadn   vec16,vec16,vec30[e12]
    ssv     vec2[e2], 0x4(s7)
    vmadh   vec17,vec17,vec30[e12]
    ssv     vec14[e2], 0x6(s7)
    vmudn   vec29,vec3,vec14[e8]
    andi    t4, a1, 0x0080
    vmadl   vec29,vec22,vec4[e9]
    or      t4, t4, a3
    vmadm   vec29,vec15,vec4[e9]
    sb      t4, 0x1(s7)
    vmadn   vec2,vec22,vec26[e9]
    beqz    t1,+
    vmadh   vec3,vec15,vec26[e9]

    vrcph   vec29[e8],vec27[e8]
    vrcpl   vec10[e8],vec27[e9]
    vadd    vec14,vec0,vec13[e3]
    vrcph   vec27[e8],vec0[e8]
    vor     vec22,vec0,vec31[e15]
    vmudm   vec29,vec13,vec10[e8]
    vmadl   vec29,vec14,vec10[e8]
    llv     vec22[e0], 0x14(at)
    vmadn   vec14,vec14,vec27[e8]
    llv     vec22[e8], 0x14(v0)
    vmadh   vec13,vec13,vec27[e8]
    vor     vec10,vec0,vec31[e15]
    vge     vec29,vec30,vec30[e15]
    llv     vec10[e8], 0x14(v1)
    vmudm   vec29,vec22,vec14[e4]
    vmadh   vec22,vec22,vec13[e4]
    vmadn   vec25,vec0,vec0[e8]
    vmudm   vec29,vec10,vec14[e14]
    vmadh   vec10,vec10,vec13[e14]
    vmadn   vec13,vec0,vec0[e8]
    sdv     vec22[e0], 0x20(s7)
    vmrg    vec19,vec19,vec22[e0]
    sdv     vec25[e0], 0x28(s7)
    vmrg    vec7,vec7,vec25[e0]
    ldv     vec18[e8], 0x20(s7)

    vmrg    vec21,vec21,vec10[e0]
    ldv     vec5[e8], 0x28(s7)
    vmrg    vec9,vec9,vec13[e0]

+
    vmudl   vec29,vec16,vec23[e0]
    lsv     vec5[e14], 0x1E(at)
    vmadm   vec29,vec17,vec23[e0]
    lsv     vec18[e14], 0x1C(at)
    vmadn   vec23,vec16,vec24[e0]
    lh      at, 0x0018(v0)
    vmadh   vec24,vec17,vec24[e0]
    addiu   v0, s7, 0x0020
    vsubc   vec10,vec9,vec5[e0]
    andi    v1, a2, 0x4
    vsub    vec9,vec21,vec18[e0]
    sll     at, at, 14
    vsubc   vec13,vec7,vec5[e0]
    sw      at, 0x8(s7)
    vsub    vec7,vec19,vec18[e0]
    ssv     vec3[e6], 0x10(s7)
    vmudn   vec29,vec10,vec6[e9]
    ssv     vec2[e6], 0x12(s7)
    vmadh   vec29,vec9,vec6[e9]
    ssv     vec3[e4], 0x18(s7)
    vmadn   vec29,vec13,vec12[e9]
    ssv     vec2[e4], 0x1A(s7)
    vmadh   vec29,vec7,vec12[e9]
    ssv     vec15[e0], 0xC(s7)
    vsar    vec2,vec2,vec2[e9]
    ssv     vec20[e0], 0xE(s7)
    vsar    vec3,vec3,vec3[e8]
    ssv     vec15[e6], 0x14(s7)
    vmudn   vec29,vec13,vec8[e8]
    ssv     vec20[e6], 0x16(s7)
    vmadh   vec29,vec7,vec8[e8]
    ssv     vec15[e4], 0x1C(s7)
    vmadn   vec29,vec10,vec11[e8]
    ssv     vec20[e4], 0x1E(s7)
    vmadh   vec29,vec9,vec11[e8]
    sll     t3, v1, 4
    vsar    vec6,vec6,vec6[e9]
    add     at, v0, t3
    vsar    vec7,vec7,vec7[e8]
    sll     t3, t1, 5
    vmudl   vec29,vec2,vec23[e9]
    add     s7, at, t3
    vmadm   vec29,vec3,vec23[e9]
    andi    a2, a2, 0x1
    vmadn   vec2,vec2,vec24[e9]
    sll     t3, a2, 4
    vmadh   vec3,vec3,vec24[e9]
    add     s7, s7, t3
    vmudl   vec29,vec6,vec23[e9]
    vmadm   vec29,vec7,vec23[e9]
    vmadn   vec6,vec6,vec24[e9]
    sdv     vec2[e0], 0x18(v0)
    vmadh   vec7,vec7,vec24[e9]
    sdv     vec3[e0], 0x8(v0)
    vmadl   vec29,vec2,vec20[e11]
    sdv     vec2[e8], 0x18(at)
    vmadm   vec29,vec3,vec20[e11]
    sdv     vec3[e8], 0x8(at)
    vmadn   vec8,vec2,vec15[e11]
    sdv     vec6[e0], 0x38(v0)
    vmadh   vec9,vec3,vec15[e11]
    sdv     vec7[e0], 0x28(v0)
    vmudn   vec29,vec5,vec1[e8]
    sdv     vec6[e8], 0x38(at)
    vmadh   vec29,vec18,vec1[e8]
    sdv     vec7[e8], 0x28(at)
    vmadl   vec29,vec8,vec4[e9]
    sdv     vec8[e0], 0x30(v0)
    vmadm   vec29,vec9,vec4[e9]
    sdv     vec9[e0], 0x20(v0)
    vmadn   vec5,vec8,vec26[e9]
    sdv     vec8[e8], 0x30(at)
    vmadh   vec18,vec9,vec26[e9]
    sdv     vec9[e8], 0x20(at)
    vmudn   vec10,vec8,vec4[e9]
    beqz    a2,+
    vmudn   vec8,vec8,vec30[e15]

    vmadh   vec9,vec9,vec30[e15]
    sdv     vec5[e0], 0x10(v0)
    vmudn   vec2,vec2,vec30[e15]
    sdv     vec18[e0], 0x0(v0)
    vmadh   vec3,vec3,vec30[e15]
    sdv     vec5[e8], 0x10(at)
    vmudn   vec6,vec6,vec30[e15]
    sdv     vec18[e8], 0x0(at)
    vmadh   vec7,vec7,vec30[e15]
    ssv     vec8[e14], 0xFA(s7)
    vmudl   vec29,vec10,vec30[e15]
    ssv     vec9[e14], 0xF8(s7)
    vmadn   vec5,vec5,vec30[e15]
    ssv     vec2[e14], 0xF6(s7)
    vmadh   vec18,vec18,vec30[e15]
    ssv     vec3[e14], 0xF4(s7)
    ssv     vec6[e14], 0xFE(s7)
    ssv     vec7[e14], 0xFC(s7)
    ssv     vec5[e14], 0xF2(s7)
    j       label_125C & 0x1FFF
    ssv     vec18[e14], 0xF0(s7)

+
    sdv     vec5[e0], 0x10(v0)
    sdv     vec18[e0], 0x0(v0)
    sdv     vec5[e8], 0x10(at)
    j       label_125C & 0x1FFF
    sdv     vec18[e8], 0x0(at)

    lhu     t9, 0x380(t9)
    lhu     t8, 0x380(t8)
    addiu   at, r0, 0x70B0
    lw      t3, 0x24(t9)
-
    and     at, at, t3
    beqz    at, func_1194
    lw      t3, 0x4C(t9)
    bne     t9, t8,-
    addiu   t9, t9, 0x0028
    j       label_11EC & 0x1FFF
    lhu     t9, 0x380(t9)

    lh      t9, 6(t9)
    sub     v0, t9, t8
    bgez    v0, func_1194
    lw      t8, 0x00D8(r0)
    j       label_1008 & 0x1FFF
    lbu     at, 0x09C1(k1)
    j       label_1040 & 0x1FFF
    lhu     t9, 0x0380(t9)

    nops(0x4001FAC)

label_1FAC:
    addi    t4, r0, 0x1000
    addi    t3, r0, 0x02E0
func_1FB4:
    lw      t8, 0x0(t3)
    lhu     s3, 0x4(t3)
    jal     func_1FD8 & 0x1FFF
    lhu     s4, 0x6(t3)
    ori     ra, t4, 0x0
func_1FC8:
    mfc0    t3, SP_COP_DMA_BUSY
-
    bnez    t3,-
    mfc0    t3, SP_COP_DMA_BUSY
label_1FD4:
    jr      ra
func_1FD8:
    mfc0    t3, SP_COP_DMA_FULL
-
    bnez    t3,-
    mfc0    t3, SP_COP_DMA_FULL
    mtc0    s4, SP_COP_MEM_ADDR
    bltz    s4,+
    mtc0    t8, SP_COP_DRAM_ADDR
    jr      ra
    mtc0    s3, SP_COP_RD_LEN
+
    jr      ra
    mtc0    s3, SP_COP_WR_LEN
