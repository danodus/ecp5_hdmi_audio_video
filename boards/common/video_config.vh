// SPDX-License-Identifier: MIT
// CEA-861 timing + clock constants per VIC (selected by Makefile -DVIC_<n>)

`ifdef VIC_0
  // Custom 1024x600 @ ~61 Hz (50 MHz pixel) — AVI VIC 0 (non-CEA)
  `define HDMI_VIC              0
  `define CLK_HZ                50000000
  `define FRAME_WIDTH           1312
  `define FRAME_HEIGHT          624
  `define SCREEN_WIDTH          1024
  `define SCREEN_HEIGHT         600
  `define HSYNC_PULSE_START     48
  `define HSYNC_PULSE_SIZE      96
  `define VSYNC_PULSE_START     3
  `define VSYNC_PULSE_SIZE      10
  `define INVERT_POLARITY       0
`elsif VIC_4
  `define HDMI_VIC              4
  `define CLK_HZ                74000000
  `define FRAME_WIDTH           1650
  `define FRAME_HEIGHT          750
  `define SCREEN_WIDTH          1280
  `define SCREEN_HEIGHT         720
  `define HSYNC_PULSE_START     110
  `define HSYNC_PULSE_SIZE      40
  `define VSYNC_PULSE_START     5
  `define VSYNC_PULSE_SIZE      5
  `define INVERT_POLARITY       0
`elsif VIC_34
  `define HDMI_VIC              34
  `define CLK_HZ                74000000
  `define FRAME_WIDTH           2200
  `define FRAME_HEIGHT          1125
  `define SCREEN_WIDTH          1920
  `define SCREEN_HEIGHT         1080
  `define HSYNC_PULSE_START     88
  `define HSYNC_PULSE_SIZE      44
  `define VSYNC_PULSE_START     4
  `define VSYNC_PULSE_SIZE      5
  `define INVERT_POLARITY       0
`else
  // VIC 1 — 640x480p @ 60 Hz (25.2 MHz pixel)
  `define HDMI_VIC              1
  `define CLK_HZ                25200000
  `define FRAME_WIDTH           800
  `define FRAME_HEIGHT          525
  `define SCREEN_WIDTH          640
  `define SCREEN_HEIGHT         480
  `define HSYNC_PULSE_START     16
  `define HSYNC_PULSE_SIZE      96
  `define VSYNC_PULSE_START     10
  `define VSYNC_PULSE_SIZE      2
  `define INVERT_POLARITY       1
`endif

`ifndef COUNTER_WIDTH
  `define COUNTER_WIDTH         12
`endif
