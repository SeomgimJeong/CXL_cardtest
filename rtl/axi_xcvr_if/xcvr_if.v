////////////////////////////////////////////////////////////////////////////////
//
//      This source code is provided to you (the Licensee) under license
//      by BittWare, a Molex Company. To view or use this source code,
//      the Licensee must accept a Software License Agreement (viewable
//      at developer.bittware.com), which is commonly provided as a click-
//      through license agreement. The terms of the Software License
//      Agreement govern all use and distribution of this file unless an
//      alternative superseding license has been executed with BittWare.
//      This source code and its derivatives may not be distributed to
//      third parties in source code form. Software including or derived
//      from this source code, including derivative works thereof created
//      by Licensee, may be distributed to third parties with BittWare
//      hardware only and in executable form only.
//
//      The click-through license is available here:
//        https://developer.bittware.com/software_license.txt
//
////////////////////////////////////////////////////////////////////////////////
//      UNCLASSIFIED//FOR OFFICIAL USE ONLY
////////////////////////////////////////////////////////////////////////////////
// Title       : XCVR Interface
// Project     : IA-860m
////////////////////////////////////////////////////////////////////////////////
// Description : Wrapper for transceiver tests and IP.
//
//
////////////////////////////////////////////////////////////////////////////////
// Known Issues and Omissions:
//
//
////////////////////////////////////////////////////////////////////////////////

module xcvr_if
  #(
    parameter RATE0            = 0, // 0 = 10G, 1 = 25G, 2 = 53G
//    parameter ADDRESS_OFFSET_0 = 12'h000,
    parameter CONFIGCLK_PERIOD = 10
    )
   (
    // Clocks
    input         refclk_fgt_2,            // 100.00 MHz
    input         refclk_fgt_5,            // 156.25 MHz
    output        coreclk_fgt_2,           // 100.00 MHz
    output        coreclk_fgt_5,           // 156.25 MHz
    output        systempll_synthlock_322, // 322 MHz
    output        systempll_synthlock_805, // 805 MHz
    output        systempll_synthlock_830, // 830 MHz

    // QSFP0
    output  [7:0] tx_serial_data_0,
    output  [7:0] tx_serial_data_0_n,
    input   [7:0] rx_serial_data_0,
    input   [7:0] rx_serial_data_0_n,
    input         reconfig_0_write,
    input         reconfig_0_read,
    input  [20:0] reconfig_0_address,
    input   [3:0] reconfig_0_byteenable,
    input  [31:0] reconfig_0_writedata,
    output [31:0] reconfig_0_readdata,
    output        reconfig_0_waitrequest,
    output        reconfig_0_readdatavalid,
    input         reconfig_sl_0_write,
    input         reconfig_sl_0_read,
    input  [16:0] reconfig_sl_0_address,
    input   [3:0] reconfig_sl_0_byteenable,
    input  [31:0] reconfig_sl_0_writedata,
    output [31:0] reconfig_sl_0_readdata,
    output        reconfig_sl_0_waitrequest,
    output        reconfig_sl_0_readdatavalid,

    // Host Interface
    input         config_clk,
    input         config_rstn,
    input   [7:0] awaddr,
    input         awvalid,
    output        awready,
    input  [31:0] wdata,
    input   [3:0] wstrb,
    input         wvalid,
    output        wready,
    output  [1:0] bresp,
    output        bvalid,
    input         bready,
    input   [7:0] araddr,
    input         arvalid,
    output        arready,
    output [31:0] rdata,
    output  [1:0] rresp,
    output        rvalid,
    input         rready
    );


   // RATE0 can be 0 (10G), 1 (25G) or 2 (53G)
   // RATE1 can only be 0 (10G or 1 (25G) - 53G is not supported on this interface
   wire           xcvr_refclk_156;
   wire           sysclk_322;
   wire           sysclk_805;
   wire           sysclk_830;

   generate
      if (RATE0 == 0) begin : system_pll_10g

         serialliteiv_system_pll_10g serialliteiv_system_pll
           (
              .in_refclk_fgt_2           (refclk_fgt_2),
              .in_refclk_fgt_5           (refclk_fgt_5),
              .out_refclk_fgt_5          (xcvr_refclk_156),
              .out_coreclk_2             (coreclk_fgt_2),
              .out_coreclk_5             (coreclk_fgt_5),
              .out_systempll_synthlock_0 (systempll_synthlock_322),
              .out_systempll_clk_0       (sysclk_322)
          );

         assign sysclk_805 = 1'b0;
         assign sysclk_830 = 1'b0;
         assign systempll_synthlock_805 = 1'b0;
         assign systempll_synthlock_830 = 1'b0;

      end // if (RATE0 == 0)

      else if (RATE0 == 1) begin : system_pll_25g

         serialliteiv_system_pll_25g serialliteiv_system_pll
           (
              .in_refclk_fgt_2           (refclk_fgt_2),
              .in_refclk_fgt_5           (refclk_fgt_5),
              .out_refclk_fgt_5          (xcvr_refclk_156),
              .out_coreclk_2             (coreclk_fgt_2),
              .out_coreclk_5             (coreclk_fgt_5),
              .out_systempll_synthlock_1 (systempll_synthlock_805),
              .out_systempll_clk_1       (sysclk_805)
            );

         assign sysclk_322 = 1'b0;
         assign sysclk_830 = 1'b0;
         assign systempll_synthlock_322 = 1'b0;
         assign systempll_synthlock_830 = 1'b0;

      end // if (RATE0 == 1)

      else begin : system_pll_53g
      // if (RATE0 == 2) begin

         serialliteiv_system_pll_53g serialliteiv_system_pll
           (
             .in_refclk_fgt_2           (refclk_fgt_2),
             .in_refclk_fgt_5           (refclk_fgt_5),
             .out_refclk_fgt_5          (xcvr_refclk_156),
             .out_coreclk_2             (coreclk_fgt_2),
             .out_coreclk_5             (coreclk_fgt_5),
             .out_systempll_synthlock_2 (systempll_synthlock_830),
             .out_systempll_clk_2       (sysclk_830)
           );

         assign sysclk_322 = 1'b0;
         assign sysclk_805 = 1'b0;
         assign systempll_synthlock_322 = 1'b0;
         assign systempll_synthlock_805 = 1'b0;

      end //else: if (RATE0 == 2) begin

   endgenerate


   //////////
   // QSFPDD0
   //////////
   xcvr_bist_qsfpdd
     #(
       .RATE             (RATE0),
//       .ADDRESS_OFFSET   (ADDRESS_OFFSET_0),
       .CONFIGCLK_PERIOD (CONFIGCLK_PERIOD)
       )
   xcvr_bist_qsfpdd_0
     (
      .xcvr_refclk               (xcvr_refclk_156),
      .sysclk                    (RATE0==0 ? sysclk_322 : RATE0==1 ? sysclk_805 : sysclk_830),
      // Serial Data
      .tx_serial_data            (tx_serial_data_0),
      .tx_serial_data_n          (tx_serial_data_0_n),
      .rx_serial_data            (rx_serial_data_0),
      .rx_serial_data_n          (rx_serial_data_0_n),
      // Dynamic Reconfig Control
      .reconfig_write            (reconfig_0_write),
      .reconfig_read             (reconfig_0_read),
      .reconfig_address          (reconfig_0_address),
      .reconfig_byteenable       (reconfig_0_byteenable),
      .reconfig_writedata        (reconfig_0_writedata),
      .reconfig_readdata         (reconfig_0_readdata),
      .reconfig_waitrequest      (reconfig_0_waitrequest),
      .reconfig_readdatavalid    (reconfig_0_readdatavalid),
      .reconfig_sl_write         (reconfig_sl_0_write),
      .reconfig_sl_read          (reconfig_sl_0_read),
      .reconfig_sl_address       (reconfig_sl_0_address),
      .reconfig_sl_byteenable    (reconfig_sl_0_byteenable),
      .reconfig_sl_writedata     (reconfig_sl_0_writedata),
      .reconfig_sl_readdata      (reconfig_sl_0_readdata),
      .reconfig_sl_waitrequest   (reconfig_sl_0_waitrequest),
      .reconfig_sl_readdatavalid (reconfig_sl_0_readdatavalid),
      // Host Interface
      .config_clk                (config_clk),
      .config_rstn               (config_rstn),
      .awaddr                    (awaddr),
      .awvalid                   (awvalid),
      .awready                   (awready),
      .wdata                     (wdata),
      .wstrb                     (wstrb),
      .wvalid                    (wvalid),
      .wready                    (wready),
      .bresp                     (bresp),
      .bvalid                    (bvalid),
      .bready                    (bready),
      .araddr                    (araddr),
      .arvalid                   (arvalid),
      .arready                   (arready),
      .rdata                     (rdata),
      .rresp                     (rresp),
      .rvalid                    (rvalid),
      .rready                    (rready)
      );

endmodule // xcvr_if
