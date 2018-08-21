constant VI_BASE($A440)         // $04400000..$04400037 Video Interface (VI) Base Register
constant VI_STATUS($00)         // $04400000..$04400003 VI: Status/Control Register
constant VI_ORIGIN($04)         // $04400004..$04400007 VI: Origin Register
constant VI_WIDTH($08)          // $04400008..$0440000B VI: Width Register
constant VI_V_INTR($0C)         // $0440000C..$0440000F VI: Vertical Interrupt Register
constant VI_V_CURRENT_LINE($10) // $04400010..$04400013 VI: Current Vertical Line Register
constant VI_TIMING($14)         // $04400014..$04400017 VI: Video Timing Register
constant VI_V_SYNC($18)         // $04400018..$0440001B VI: Vertical Sync Register
constant VI_H_SYNC($1C)         // $0440001C..$0440001F VI: Horizontal Sync Register
constant VI_H_SYNC_LEAP($20)    // $04400020..$04400023 VI: Horizontal Sync Leap Register
constant VI_H_VIDEO($24)        // $04400024..$04400027 VI: Horizontal Video Register
constant VI_V_VIDEO($28)        // $04400028..$0440002B VI: Vertical Video Register
constant VI_V_BURST($2C)        // $0440002C..$0440002F VI: Vertical Burst Register
constant VI_X_SCALE($30)        // $04400030..$04400033 VI: X-Scale Register
constant VI_Y_SCALE($34)        // $04400034..$04400037 VI: Y-Scale Register

constant BPP0($0000)  // VI Status/Control: Color Depth Blank (No Data Or Sync) (Bit 0..1)
//*RESERVED*($0001)   // VI Status/Control: Color Depth Reserved (Bit 0..1)
constant BPP16($0002) // VI Status/Control: Color Depth 16BPP R5/G5/B5/A1 (Bit 0..1)
constant BPP32($0003) // VI Status/Control: Color Depth 32BPP R8/G8/B8/A8 (Bit 0..1)
constant GAMMA_DITHER_EN($00004) // VI Status/Control: Gamma Dither Enable (Requires: Gamma Enable) (Bit 2)
constant GAMMA_EN($00008)        // VI Status/Control: Gamma Enable (Gamma Boost For YUV Images) (Bit 3)
constant DIVOT_EN($00010)    // VI Status/Control: Divot Enable (Used With Anti-alias) (Bit 4)
constant VBUS_CLK_EN($00020) // VI Status/Control: Video Bus Clock Enable (Bit 5)
constant INTERLACE($00040) // VI Status/Control: Interlace/Serrate (Used With Interlaced Display) (Bit 6)
constant TST_MODE($00080)  // VI Status/Control: Test Mode (Bit 7)
constant AA_MODE_0($00000) // VI Status/Control: AA Mode 0 = Anti­-alias & Resample (Always Fetch Extra Lines) (Bit 8..9)
constant AA_MODE_1($00100) // VI Status/Control: AA Mode 1 = Anti­-alias & Resample (Fetch Extra Lines When Needed) (Bit 8..9)
constant AA_MODE_2($00200) // VI Status/Control: AA Mode 2 = Resample Only (Bit 8..9)
constant AA_MODE_3($00300) // VI Status/Control: AA Mode 3 = Replicate Pixels & No Interpolation (Bit 8..9)
constant DIAG_0($00400) // VI Status/Control: Diagnotic 0 (Bit 10..11)
constant DIAG_1($00800) // VI Status/Control: Diagnotic 1 (Bit 10..11)
constant PIXEL_ADV_0($00000) // VI Status/Control: Pixel Advance 0 (Bit 12..15)
constant PIXEL_ADV_1($01000) // VI Status/Control: Pixel Advance 1 (Bit 12..15)
constant PIXEL_ADV_2($02000) // VI Status/Control: Pixel Advance 2 (Bit 12..15)
constant PIXEL_ADV_3($03000) // VI Status/Control: Pixel Advance 3 (Bit 12..15)
constant PIXEL_ADV_4($04000) // VI Status/Control: Pixel Advance 4 (Bit 12..15)
constant PIXEL_ADV_5($05000) // VI Status/Control: Pixel Advance 5 (Bit 12..15)
constant PIXEL_ADV_6($06000) // VI Status/Control: Pixel Advance 6 (Bit 12..15)
constant PIXEL_ADV_7($07000) // VI Status/Control: Pixel Advance 7 (Bit 12..15)
constant PIXEL_ADV_8($08000) // VI Status/Control: Pixel Advance 8 (Bit 12..15)
constant PIXEL_ADV_9($09000) // VI Status/Control: Pixel Advance 9 (Bit 12..15)
constant PIXEL_ADV_A($0A000) // VI Status/Control: Pixel Advance A (Bit 12..15)
constant PIXEL_ADV_B($0B000) // VI Status/Control: Pixel Advance B (Bit 12..15)
constant PIXEL_ADV_C($0C000) // VI Status/Control: Pixel Advance C (Bit 12..15)
constant PIXEL_ADV_D($0D000) // VI Status/Control: Pixel Advance D (Bit 12..15)
constant PIXEL_ADV_E($0E000) // VI Status/Control: Pixel Advance E (Bit 12..15)
constant PIXEL_ADV_F($0F000) // VI Status/Control: Pixel Advance F (Bit 12..15)
constant DITHER_FILTER_EN($10000) // VI Status/Control: Dither Filter Enable (Used With 16BPP Display) (Bit 16)

constant VI_NTSC_CLOCK(48681812) // NTSC: Hz = 48.681812 MHz
constant VI_PAL_CLOCK(49656530)  // PAL:  Hz = 49.656530 MHz
constant VI_MPAL_CLOCK(48628316) // MPAL: Hz = 48.628316 MHz

macro ScreenNTSC(width,height, status, origin) {
  lui a0,VI_BASE // A0 = VI Base Register ($A4400000)
  li t0,{status}      // T0 = Status/Control
  sw t0,VI_STATUS(a0) // Store Status/Control To VI Status Register ($A4400000)
  la t0,{origin}      // T0 = Origin (Frame Buffer Origin In Bytes)
  sw t0,VI_ORIGIN(a0) // Store Origin To VI Origin Register ($A4400004)
  lli t0,{width}      // T0 = Width (Frame Buffer Line Width In Pixels)
  sw t0,VI_WIDTH(a0)  // Store Width To VI Width Register ($A4400008)
  lli t0,$200         // T0 = Vertical Interrupt (Interrupt When Current Half-Line $200)
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
}

macro ScreenPAL(width,height, status, origin) {
  lui a0,VI_BASE // A0 = VI Base Register ($A4400000)
  la t0,{origin}      // T0 = Origin (Frame Buffer Origin In Bytes)
  sw t0,VI_ORIGIN(a0) // Store Origin To VI Origin Register ($A4400004)
  lli t0,{width}      // T0 = Width (Frame Buffer Line Width In Pixels)
  sw t0,VI_WIDTH(a0)  // Store Width To VI Width Register ($A4400008)
  lli t0,$200         // T0 = Vertical Interrupt (Interrupt When Current Half-Line $200)
//lli t0,2
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

