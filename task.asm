PushVideoTask:
    // a0: Task RDRAM Pointer (size: 0x40) (should probably be row-aligned)
    subiu   sp, sp, 0x18
    sw      ra, 0x10(sp)

    lli     t0, 1 // mode: video
    lli     t1, TASK_DP_WAIT // flags
    li      t2, UCODE_BOOT // does not need masking (not actually used?)
    li      t3, UCODE_BOOT.size
    li      t4, F3DZEX_IMEM & ADDR_MASK
    li      t5, F3DZEX_IMEM.size
    li      t6, F3DZEX_DMEM & ADDR_MASK
    li      t7, F3DZEX_DMEM.size
    sw      t0, 0x00(a0)
    sw      t1, 0x04(a0)
    sw      t2, 0x08(a0)
    sw      t3, 0x0C(a0)
    sw      t4, 0x10(a0)
    sw      t5, 0x14(a0)
    sw      t6, 0x18(a0)
    sw      t7, 0x1C(a0)

    li      t0, VIDEO_STACK & ADDR_MASK // used for DList calls and returns?
    li      t1, VIDEO_STACK_SIZE
    li      t2, VIDEO_OUTPUT & ADDR_MASK
    // most commercial games re-use the yield pointer, so i assume it's fine:
    li      t3, VIDEO_YIELD & ADDR_MASK // stores output buffer size
    li      t4, ((MAIN_BASE << 16) | MAIN_DLIST_JUMPER) & ADDR_MASK // initial DList
    lli     t5, 8 // size of one jump command. this is ignored and 0xA8 is used instead
    li      t6, VIDEO_YIELD & ADDR_MASK
    li      t7, VIDEO_YIELD_SIZE
    sw      t0, 0x20(a0)
    sw      t1, 0x24(a0)
    sw      t2, 0x28(a0)
    sw      t3, 0x2C(a0)
    sw      t4, 0x30(a0)
    sw      t5, 0x34(a0)
    sw      t6, 0x38(a0)
    sw      t7, 0x3C(a0)

    // tell data cache to write itself out
    cache   0x19, 0x00(a0)
    cache   0x19, 0x10(a0)
    cache   0x19, 0x20(a0)
    cache   0x19, 0x30(a0)

    li      t9, ADDR_MASK
    jal     PushRSPTask
    and     a0, a0, t9

    lw      ra, 0x10(sp)
    jr      ra
    addiu   sp, sp, 0x18

PushRSPTask:
    lli     t3, 0x40 - 1 // DMA quirk
    or      t4, a0, r0
    SP_DMA_WAIT() // clobbers t0, a0
    la      t1, 0xA4000FC0
    sw      t1, SP_MEM_ADDR(a0)
    sw      t4, SP_DRAM_ADDR(a0)
    sw      t3, SP_RD_LEN(a0) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

LoadRSPBoot:
    la      t2, UCODE_BOOT & ADDR_MASK
    li      t3, UCODE_BOOT.size
    subiu   t3, t3, 1 // DMA quirk
    SP_DMA_WAIT() // clobbers t0, a0
    la      t1, 0xA4001000
    sw      t1, SP_MEM_ADDR(a0)
    sw      t2, SP_DRAM_ADDR(a0)
    sw      t3, SP_RD_LEN(a0) // pull data from RDRAM into DMEM/IMEM
    jr      ra
    nop

align(16); insert UCODE_BOOT, "bin/common.boot.bin"
align(16); insert F3DZEX_IMEM, "bin/F3DZEX2.bin"
align(16); insert F3DZEX_DMEM, "bin/F3DZEX2.data.bin"
