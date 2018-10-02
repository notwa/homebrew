constant VI_BASE($A440)         // $04400000 Video Interface (VI) Base
constant VI_STATUS($00)         // $04400000 Status/Control
constant VI_ORIGIN($04)         // $04400004 Origin
constant VI_WIDTH($08)          // $04400008 Width
constant VI_V_INTR($0C)         // $0440000C Vertical Interrupt
constant VI_V_CURRENT_LINE($10) // $04400010 Current Vertical Line
constant VI_TIMING($14)         // $04400014 Video Timing
constant VI_V_SYNC($18)         // $04400018 Vertical Sync
constant VI_H_SYNC($1C)         // $0440001C Horizontal Sync
constant VI_H_SYNC_LEAP($20)    // $04400020 Horizontal Sync Leap
constant VI_H_VIDEO($24)        // $04400024 Horizontal Video
constant VI_V_VIDEO($28)        // $04400028 Vertical Video
constant VI_V_BURST($2C)        // $0440002C Vertical Burst
constant VI_X_SCALE($30)        // $04400030 X-Scale
constant VI_Y_SCALE($34)        // $04400034 Y-Scale

// VI Status Flags (lower halfword)
constant BPP0($0000)  // Color Depth Blank (No Data Or Sync)
//*RESERVED*($0001)   // Color Depth Reserved
constant BPP16($0002) // Color Depth 16BPP R5/G5/B5/A1
constant BPP32($0003) // Color Depth 32BPP R8/G8/B8/A8
constant GAMMA_DITHER_EN($0004) // Gamma Dither Enable (Requires: Gamma Enable)
constant GAMMA_EN($0008) // Gamma Enable (Gamma Boost For YUV Images)
constant DIVOT_EN($0010) // Divot Enable (Used With Anti-alias)
constant VBUS_CLK_EN($0020) // Video Bus Clock Enable
constant INTERLACE($0040) // Interlace/Serrate (Used With Interlaced Display)
constant TST_MODE($0080)  // Test Mode
constant AA_MODE_0($0000) // AA Mode 0 = Anti­alias & Resample (Always Fetch Extra Lines)
constant AA_MODE_1($0100) // AA Mode 1 = Anti­alias & Resample (Fetch Extra Lines When Needed)
constant AA_MODE_2($0200) // AA Mode 2 = Resample Only
constant AA_MODE_3($0300) // AA Mode 3 = Replicate Pixels & No Interpolation
constant DIAG_0($0400) // Diagnotic 0
constant DIAG_1($0800) // Diagnotic 1
constant PIXEL_ADV_0($0000) // Pixel Advance 0
constant PIXEL_ADV_1($1000) // Pixel Advance 1
constant PIXEL_ADV_2($2000) // Pixel Advance 2
constant PIXEL_ADV_3($3000) // Pixel Advance 3
constant PIXEL_ADV_4($4000) // Pixel Advance 4
constant PIXEL_ADV_5($5000) // Pixel Advance 5
constant PIXEL_ADV_6($6000) // Pixel Advance 6
constant PIXEL_ADV_7($7000) // Pixel Advance 7
constant PIXEL_ADV_8($8000) // Pixel Advance 8
constant PIXEL_ADV_9($9000) // Pixel Advance 9
constant PIXEL_ADV_A($A000) // Pixel Advance A
constant PIXEL_ADV_B($B000) // Pixel Advance B
constant PIXEL_ADV_C($C000) // Pixel Advance C
constant PIXEL_ADV_D($D000) // Pixel Advance D
constant PIXEL_ADV_E($E000) // Pixel Advance E
constant PIXEL_ADV_F($F000) // Pixel Advance F

// VI Status Flags (upper halfword)
constant DITHER_FILTER_EN($10000) // Dither Filter Enable (Used With 16BPP Display)

constant VI_NTSC_CLOCK(48681812) // NTSC: Hz = 48.681812 MHz
constant VI_PAL_CLOCK(49656530)  // PAL:  Hz = 49.656530 MHz
constant VI_MPAL_CLOCK(48628316) // MPAL: Hz = 48.628316 MHz

macro ScreenNTSC(width,height, status, origin) {
  lui a0,VI_BASE // A0 = VI Base Register ($A4400000)
  la t0,{origin}      // T0 = Origin (Frame Buffer Origin In Bytes)
  sw t0,VI_ORIGIN(a0) // Store Origin To VI Origin Register ($A4400004)
  lli t0,{width}      // T0 = Width (Frame Buffer Line Width In Pixels)
  sw t0,VI_WIDTH(a0)  // Store Width To VI Width Register ($A4400008)
  lli t0,$2           // T0 = Vertical Interrupt (Interrupt When Current Half-Line $2)
  sw t0,VI_V_INTR(a0) // Store Vertical Interrupt To VI Interrupt Register ($A440000C)
  lli t0,0                    // T0 = Current Vertical Line (Current Half-Line, Sampled Once Per Line = 0)
  sw t0,VI_V_CURRENT_LINE(a0) // Store Current Vertical Line To VI Current Register ($A4400010)
  li t0,$3E52239      // T0 = Video Timing (Start Of Color Burst In Pixels from H-Sync = 3, Vertical Sync Width In Half Lines = 229, Color Burst Width In Pixels = 34, Horizontal Sync Width In Pixels = 57)
  sw t0,VI_TIMING(a0) // Store Video Timing To VI Burst Register ($A4400014)
  lli t0,$20D         // T0 = Vertical Sync (Number Of Half-Lines Per Field = 525)
  sw t0,VI_V_SYNC(a0) // Store Vertical Sync To VI V Sync Register ($A4400018)
  lli t0,$C15         // T0 = Horizontal Sync (5-bit Leap Pattern Used For PAL only = 0, Total Duration Of A Line In 1/4 Pixel = 3093)
  sw t0,VI_H_SYNC(a0) // Store Horizontal Sync To VI H Sync Register ($A440001C)
  li t0,$C150C15           // T0 = Horizontal Sync Leap (Identical To H Sync = 3093, Identical To H Sync = 3093)
  sw t0,VI_H_SYNC_LEAP(a0) // Store Horizontal Sync Leap To VI Leap Register ($A4400020)
  li t0,$6C02EC        // T0 = Horizontal Video (Start Of Active Video In Screen Pixels = 108, End Of Active Video In Screen Pixels = 748)
  sw t0,VI_H_VIDEO(a0) // Store Horizontal Video To VI H Start Register ($A4400024)
  li t0,$2501FF        // T0 = Vertical Video (Start Of Active Video In Screen Half-Lines = 37, End Of Active Video In Screen Half-Lines = 511)
  sw t0,VI_V_VIDEO(a0) // Store Vertical Video To VI V Start Register ($A4400028)
  li t0,$E0204         // T0 = Vertical Burst (Start Of Color Burst Enable In Half-Lines = 14, End Of Color Burst Enable In Half-Lines = 516)
  sw t0,VI_V_BURST(a0) // Store Vertical Burst To VI V Burst Register ($A440002C)
  lli t0,($100*({width}/160)) // T0 = X-Scale (Horizontal Subpixel Offset In 2.10 Format = 0, 1/Horizontal Scale Up Factor In 2.10 Format)
  sw t0,VI_X_SCALE(a0)        // Store X-Scale To VI X Scale Register ($A4400030)
  lli t0,($100*({height}/60)) // T0 = Y-Scale (Vertical Subpixel Offset In 2.10 Format = 0, 1/Vertical Scale Up Factor In 2.10 Format)
  sw t0,VI_Y_SCALE(a0)        // Store Y-Scale To VI Y Scale Register ($A4400034)
  li t0,{status}      // T0 = Status/Control
  sw t0,VI_STATUS(a0) // Store Status/Control To VI Status Register ($A4400000)
}

macro ScreenPAL(width,height, status, origin) {
  lui a0,VI_BASE // A0 = VI Base Register ($A4400000)
  la t0,{origin}      // T0 = Origin (Frame Buffer Origin In Bytes)
  sw t0,VI_ORIGIN(a0) // Store Origin To VI Origin Register ($A4400004)
  lli t0,{width}      // T0 = Width (Frame Buffer Line Width In Pixels)
  sw t0,VI_WIDTH(a0)  // Store Width To VI Width Register ($A4400008)
  lli t0,$2           // T0 = Vertical Interrupt (Interrupt When Current Half-Line $2)
  sw t0,VI_V_INTR(a0) // Store Vertical Interrupt To VI Interrupt Register ($A440000C)
  lli t0,0            // T0 = Current Vertical Line (Current Half-Line, Sampled Once Per Line = 0)
  sw t0,VI_V_CURRENT_LINE(a0) // Store Current Vertical Line To VI Current Register ($A4400010)
  li t0,$404233A      // T0 = Video Timing (Start Of Color Burst In Pixels from H-Sync = 4, Vertical Sync Width In Half Lines = 04, Color Burst Width In Pixels = 35, Horizontal Sync Width In Pixels = 58)
  sw t0,VI_TIMING(a0) // Store Video Timing To VI Burst Register ($A4400014)
  lli t0,$271         // T0 = Vertical Sync (Number Of Half-Lines Per Field = 625)
  sw t0,VI_V_SYNC(a0) // Store Vertical Sync To VI V Sync Register ($A4400018)
  li t0,$150C69       // T0 = Horizontal Sync (5-bit Leap Pattern Used For PAL only = 21: %10101, Total Duration Of A Line In 1/4 Pixel = 3177)
  sw t0,VI_H_SYNC(a0) // Store Horizontal Sync To VI H Sync Register ($A440001C)
  li t0,$C6F0C6E           // T0 = Horizontal Sync Leap (Identical To H Sync = 3183, Identical To H Sync = 3182)
  sw t0,VI_H_SYNC_LEAP(a0) // Store Horizontal Sync Leap To VI Leap Register ($A4400020)
  li t0,$800300        // T0 = Horizontal Video (Start Of Active Video In Screen Pixels = 128, End Of Active Video In Screen Pixels = 768)
  sw t0,VI_H_VIDEO(a0) // Store Horizontal Video To VI H Start Register ($A4400024)
  li t0,$5F0239        // T0 = Vertical Video (Start Of Active Video In Screen Half-Lines = 95, End Of Active Video In Screen Half-Lines = 569)
  sw t0,VI_V_VIDEO(a0) // Store Vertical Video To VI V Start Register ($A4400028)
  li t0,$9026B         // T0 = Vertical Burst (Start Of Color Burst Enable In Half-Lines = 9, End Of Color Burst Enable In Half-Lines = 619)
  sw t0,VI_V_BURST(a0) // Store Vertical Burst To VI V Burst Register ($A440002C)
  lli t0,($100*({width}/160)) // T0 = X-Scale (Horizontal Subpixel Offset In 2.10 Format = 0, 1/Horizontal Scale Up Factor In 2.10 Format)
  sw t0,VI_X_SCALE(a0)        // Store X-Scale To VI X Scale Register ($A4400030)
  lli t0,($100*({height}/60)) // T0 = Y-Scale (Vertical Subpixel Offset In 2.10 Format = 0, 1/Vertical Scale Up Factor In 2.10 Format)
  sw t0,VI_Y_SCALE(a0)        // Store Y-Scale To VI Y Scale Register ($A4400034)
  li t0,{status}      // T0 = Status/Control
  sw t0,VI_STATUS(a0) // Store Status/Control To VI Status Register ($A4400000)
}

macro WaitScanline(scanline) { // Wait For RDP To Reach Scanline
  lui a0,VI_BASE // A0 = VI Base Register ($A4400000)
  lli t0,{scanline} // T0 = Scan Line
  -
    lw t1,VI_V_CURRENT_LINE(a0) // T1 = Current Scan Line
    bne t1,t0,- // IF (Current Scan Line != Scan Line) Wait
    nop // ELSE Continue (Delay Slot)
}
