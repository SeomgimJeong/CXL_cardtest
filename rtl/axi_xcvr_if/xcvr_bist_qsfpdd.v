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
// Title       : Transceiver BIST (8x 25.78125G NRZ) or (8x 10.3125G NRZ)
// Project     : IA-860m
////////////////////////////////////////////////////////////////////////////////
// Description : BIST component for Transceiver 8x testing.
//
//               The Intel SerialLiteIV IP has been implemented to
//               enable the transceivers in the F-Tile.
//
//               To test this channel, a PRBS pattern is transmitted at
//               maximum rate and the received data checked for errors. Bit
//               errors can be injected into the transmitted data. Status
//               registers indicate the received error count and the data
//               transfer rate.
//
//               ============
//               Register Map
//               ============
//
//               Status (offset 0x00)
//               --------------------
//               [00]     tx_link_up          (1 is link up)
//               [01]     rx_link_up          (1 is link up)
//               [31:16]  tx_pll_locked       (FFFF is locked)
//
//               Status2 (offset 0x04)
//               --------------------
//               [15:00]  phy_tx_lanes_stable (FFFF is stable)
//               [31:16]  phy_ehip_ready      (FFFF is ready)
//
//               Status 3 (offset 0x08)
//               --------------------
//               [15:00]  rx_cdr_lock         (FFFF is locked)
//               [31:16]  phy_rx_block_lock   (FFFF is locked)
//
//               Status 4 (offset 0x0C)
//               --------------------
//               [15:00]  phy_rx_pcs_ready    (FFFF is ready)
//               [31:16]  phy_rx_hi_ber
//
//               Status 5 (offset 0x0C)
//               --------------------
//               [15:00]  PRBS Locked (FFFF is locked)
//
//               PHY Control (offset 0x10)
//               ---------------------
//               [00]     PHY reset
//               [04]     Reg Capture
//               [08]     PRBS Enable
//               [09]     PRBS Checker ReSync
//               [16]     TX Re-Init Alignment
//               [20]     RX Re-Init Alignment
//
//               Error Inject (all lanes) (offset 0x14)
//               -------------------------------------
//               [00]     Error Inject
//
//               Error Counts for Lane #0 (offset 0x20)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #1 (offset 0x24)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #2 (offset 0x28)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #3 (offset 0x2C)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #4 (offset 0x30)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #5 (offset 0x34)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #6 (offset 0x38)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #7 (offset 0x3C)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #8 (offset 0x40)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #9 (offset 0x44)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #10 (offset 0x48)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #11 (offset 0x4C)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #12 (offset 0x50)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #13 (offset 0x54)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #14 (offset 0x58)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Error Counts for Lane #15 (offset 0x5C)
//               -------------------------------------
//               [15:00]  Data Word (16-bit)
//
//               Phy Stats(offset 0x60)
//               ----------------------
//               [15:00]  Rx Data Rate (16-bit) (MBytes/sec)
//
//
//
////////////////////////////////////////////////////////////////////////////////
// Known Issues and Omissions:
//
//
////////////////////////////////////////////////////////////////////////////////

module xcvr_bist_qsfpdd
  #(
    parameter RATE             = 0, // 0 = 10G, 1 = 25G, 2 = 53G
//    parameter ADDRESS_OFFSET   = 12'h000,
    parameter CONFIGCLK_PERIOD = 10
    )
   (
    // Clocks
    input              xcvr_refclk,
    input              sysclk,
    // Serial Data
    output       [7:0] tx_serial_data,
    output       [7:0] tx_serial_data_n,
    input        [7:0] rx_serial_data,
    input        [7:0] rx_serial_data_n,
    // Dynamic Reconfig Control
    input              reconfig_write,
    input              reconfig_read,
    input       [20:0] reconfig_address,
    input        [3:0] reconfig_byteenable,
    input       [31:0] reconfig_writedata,
    output      [31:0] reconfig_readdata,
    output             reconfig_waitrequest,
    output             reconfig_readdatavalid,
    input              reconfig_sl_write,
    input              reconfig_sl_read,
    input       [16:0] reconfig_sl_address,
    input        [3:0] reconfig_sl_byteenable,
    input       [31:0] reconfig_sl_writedata,
    output      [31:0] reconfig_sl_readdata,
    output             reconfig_sl_waitrequest,
    output             reconfig_sl_readdatavalid,
    // Host Interface
    input              config_clk,
    input              config_rstn,
    input        [7:0] awaddr,
    input              awvalid,
    output             awready,
    input       [31:0] wdata,
    input        [3:0] wstrb,
    input              wvalid,
    output             wready,
    output       [1:0] bresp,
    output             bvalid,
    input              bready,
    input        [7:0] araddr,
    input              arvalid,
    output             arready,
    output      [31:0] rdata,
    output       [1:0] rresp,
    output             rvalid,
    input              rready
    );

   localparam WM = (RATE==2) ? 2 : 1;

   localparam SAMPLE_PERIOD     = 1000000000/CONFIGCLK_PERIOD;
   localparam LANES_IN_USE = (RATE==2) ? 8'd16 : 8'd8; // Set to the number of lanes used. 8 for 10G NRZ, 25G NRZ, 16 for 53G PAM4

   wire                     tx_avs_ready;
   wire                     tx_avs_valid;
   reg [(WM*512)-1:0]       tx_avs_data;
   wire [(WM*8)-1:0] [63:0] tx_avs_data_i;
   wire                     tx_link_up;
   wire [4:0]               tx_error;

   wire                     rx_avs_ready;
   wire                     rx_avs_valid;
   wire [(WM*512)-1:0]      rx_avs_data;
   wire                     rx_link_up;
   wire [(WM*16)+2:0]       rx_error;

   wire [(WM*8)-1:0]        phy_tx_lanes_stable;
   wire [(WM*8)-1:0]        tx_pll_locked;
   wire [(WM*8)-1:0]        phy_ehip_ready;
   wire [(WM*8)-1:0]        rx_cdr_lock;
   wire [(WM*8)-1:0]        phy_rx_block_lock;
   wire [(WM*8)-1:0]        phy_rx_pcs_ready;
   wire [(WM*8)-1:0]        phy_rx_hi_ber;

   wire                     tx_core_clkout;
   wire                     rx_core_clkout;

   reg                      tx_pcs_fec_phy_reset_override;
   reg                      rx_pcs_fec_phy_reset_override;

   // F-Tile Serial Lite IV Intel FPGA IP User Guide suggests tying the
   //  TX & RX PCS_FEC_PHY_RESET_N signals together to reset the TX & RX
   //  PCS simultaneously
   reg                      pcs_fec_phy_reset_n;
   wire                     pcs_fec_phy_reset_n_tx_sync;
   wire                     pcs_fec_phy_reset_n_rx_sync;

   // combine these as well between XCVR and SL4
   reg                      reconfig_reset;

   reg                      tx_core_rst_override;
   reg                      rx_core_rst_override;

   reg                      tx_core_rst_n;
   reg                      rx_core_rst_n;

   wire                     tx_core_rst_n_sync;
   reg                      tx_core_rst_n_sync2;

   wire                     rx_core_rst_n_sync;
   reg                      rx_core_rst_n_sync2;

   wire                     tx_reset_ack;
   wire                     rx_reset_ack;

   wire                     tx_reset_ack_sync;
   wire                     rx_reset_ack_sync;

   reg [31:0]               rx_lu_cnt;

   wire                     tx_link_up_sync;
   wire                     rx_link_up_sync;
   reg                      rx_link_up_sync2;

   reg [31:0]               sample_count;
   reg                      sample_toggle;

   reg [3:0]                rst_count;
   reg                      rst_pulse;
   reg                      rst_rx_ctrl;
   reg [3:0]                capt_count;
   reg                      capt_pls;
   reg [3:0]                resync_count;
   reg                      resync_pls;
   reg [3:0]                err_inj_count;
   reg                      err_inj_pls;
   reg [15:0]               err_inj_field_tmp;
   wire [(WM*8)-1:0]        err_inj_field;
   reg                      prbs_enab;
   reg                      lpbk_enab;
   reg [3:0]                tx_init_count;
   reg                      tx_init_pulse;
   reg [3:0]                rx_init_count;
   reg                      rx_init_pulse;

   wire [(WM*8)-1:0]        phy_tx_lanes_stable_sync;
   wire [(WM*8)-1:0]        tx_pll_locked_sync;
   wire [(WM*8)-1:0]        phy_ehip_ready_sync;
   wire [(WM*8)-1:0]        rx_cdr_lock_sync;
   wire [(WM*8)-1:0]        phy_rx_block_lock_sync;
   wire [(WM*8)-1:0]        phy_rx_pcs_ready_sync;
   wire [(WM*8)-1:0]        phy_rx_hi_ber_sync;

   wire                     err_inj_pls_sync;
   reg                      err_inj_pls_sync2;
   reg [(WM*8)-1:0]         error_inject;
   reg                      tx_gen_reset;
   reg                      tx_enable;
   wire                     tx_gen_enable;
   wire                     tx_init_pulse_sync;
   reg                      tx_init_pulse_sync2;
   reg                      tx_link_reinit;

   wire                     resync_pls_sync;
   wire                     sample_toggle_rx_sync;
   reg                      sample_toggle_rx_sync2;
   wire                     capt_pls_rx_sync;
   reg                      capt_pls_rx_sync2;
   wire                     prbs_enab_sync;
   wire                     lpbk_enab_sync;
   wire                     rx_init_pulse_sync;
   reg                      rx_init_pulse_sync2;
   reg                      rx_link_reinit;

   reg                      rx_chk_reset;
   reg                      capture;
   reg                      sample_pls;
   reg [(WM*8)-1:0]         counter_rst;
   reg                      prbs_chk_en;
   reg [(WM*512)-1:0]       rx_data_d1;
   reg                      rx_valid_d1;
   reg [(WM*512)-1:0]       gf_data_d1;
   reg                      gf_valid_d1;
   reg [(WM*512)-1:0]       rx_data_d2;
   reg                      rx_enable;
   reg [(WM*8)-1:0]         prbs_lock;
   wire [(WM*8)-1:0]        prbs_chk_lock;
   reg [31:0]               tx_word_count;
   reg [31:0]               tx_word_store;
   reg [31:0]               capt_tx_word_store;
   reg [31:0]               rx_word_count;
   reg [31:0]               rx_word_store;
   reg [31:0]               capt_rx_word_store;
   wire [(WM*8)-1:0] [63:0] prbs_chk_err;
   wire [(WM*8)-1:0] [15:0] prbs_err_count;
   reg [(WM*8)-1:0]  [15:0] capt_prbs_err_count;


   assign rx_avs_ready = rx_link_up;

`define SL4_X8_INST                                           \
   (                                                          \
    // Clocks and reset                                       \
    .tx_core_clkout            (tx_core_clkout),              \
    .tx_core_rst_n             (tx_core_rst_n_sync),          \
    .rx_core_clkout            (rx_core_clkout),              \
    .rx_core_rst_n             (rx_core_rst_n_sync),          \
    .tx_reset_ack              (tx_reset_ack),                \
    .rx_reset_ack              (rx_reset_ack),                \
    .tx_pcs_fec_phy_reset_n    (pcs_fec_phy_reset_n_tx_sync), \
    .rx_pcs_fec_phy_reset_n    (pcs_fec_phy_reset_n_rx_sync), \
    // Source User Interface                                  \
    .tx_avs_data               (tx_avs_data),                 \
    .tx_avs_valid              (tx_avs_valid),                \
    .tx_avs_ready              (tx_avs_ready),                \
    .tx_link_up                (tx_link_up),                  \
    .tx_link_reinit            (tx_link_reinit),              \
    .tx_error                  (tx_error),                    \
    // Sink User Interface                                    \
    .rx_avs_data               (rx_avs_data),                 \
    .rx_avs_valid              (rx_avs_valid),                \
    .rx_avs_ready              (rx_avs_ready),                \
    .rx_link_up                (rx_link_up),                  \
    .rx_link_reinit            (rx_link_reinit),              \
    .rx_error                  (rx_error),                    \
    // Ethernet PHY IP xcvr reconfig interface                \
    .reconfig_clk              (config_clk),                  \
    .reconfig_reset            (reconfig_reset),              \
    .reconfig_write            (reconfig_write),              \
    .reconfig_read             (reconfig_read),               \
    .reconfig_address          (reconfig_address),            \
    .reconfig_byteenable       (reconfig_byteenable),         \
    .reconfig_writedata        (reconfig_writedata),          \
    .reconfig_readdata         (reconfig_readdata),           \
    .reconfig_waitrequest      (reconfig_waitrequest),        \
    .reconfig_readdatavalid    (reconfig_readdatavalid),      \
    .reconfig_sl_clk           (config_clk),                  \
    .reconfig_sl_reset         (reconfig_reset),              \
    .reconfig_sl_write         (reconfig_sl_write),           \
    .reconfig_sl_read          (reconfig_sl_read),            \
    .reconfig_sl_address       (reconfig_sl_address),         \
    .reconfig_sl_byteenable    (reconfig_sl_byteenable),      \
    .reconfig_sl_writedata     (reconfig_sl_writedata),       \
    .reconfig_sl_readdata      (reconfig_sl_readdata),        \
    .reconfig_sl_waitrequest   (reconfig_sl_waitrequest),     \
    .reconfig_sl_readdatavalid (reconfig_sl_readdatavalid),   \
    // Ethernet PHY IP xcvr status                            \
    .phy_ehip_ready            (phy_ehip_ready),              \
    .phy_tx_lanes_stable       (phy_tx_lanes_stable),         \
    .rx_cdr_lock               (rx_cdr_lock),                 \
    .phy_rx_pcs_ready          (phy_rx_pcs_ready),            \
    .phy_rx_block_lock         (phy_rx_block_lock),           \
    .phy_rx_hi_ber             (phy_rx_hi_ber),               \
    // Transceiver clocks and serial data                     \
    .xcvr_ref_clk              (xcvr_refclk),                 \
    .sysclk                    (sysclk),                      \
    .tx_pll_locked             (tx_pll_locked),               \
    .tx_serial_data            (tx_serial_data),              \
    .tx_serial_data_n          (tx_serial_data_n),            \
    .rx_serial_data            (rx_serial_data),              \
    .rx_serial_data_n          (rx_serial_data_n)             \
	  );


   generate
      if (RATE == 0)      begin : ftile_10g
         serialliteiv_x8_10g serialliteiv_x8 `SL4_X8_INST
      end
      else if (RATE == 1) begin : ftile_25g
         serialliteiv_x8_25g serialliteiv_x8 `SL4_X8_INST
      end
      else                begin : ftile_53g
         serialliteiv_x8_53g serialliteiv_x8 `SL4_X8_INST
      end
   endgenerate


   ////////////////////////////////////////////////////////////
   //
   // Memory Map Interface
   //
   // Controls resets to the IP
   // Controls enabling of PRBS checkers, error injection, etc.
   //
   ////////////////////////////////////////////////////////////

   /////////////////
   // AXI Controller
   /////////////////

   wire [ 7:0] wr_addr;
   wire        wr_en;
   wire [31:0] wr_data;
   wire [ 3:0] wr_bten;

   wire [ 7:0] rd_addr;
   wire        rd_en;
   reg         rd_valid;
   reg  [31:0] rd_data;

   axi_slave_ctrl axi_slave_ctrl
     (
      .aclk     (config_clk),
      .areset   (~config_rstn),
      .awaddr   (awaddr),
      .awvalid  (awvalid),
      .awready  (awready),
      .wdata    (wdata),
      .wstrb    (wstrb),
      .wvalid   (wvalid),
      .wready   (wready),
      .bresp    (bresp),
      .bvalid   (bvalid),
      .bready   (bready),
      .araddr   (araddr),
      .arvalid  (arvalid),
      .arready  (arready),
      .rdata    (rdata),
      .rresp    (rresp),
      .rvalid   (rvalid),
      .rready   (rready),
      .wr_addr  (wr_addr),
      .wr_en    (wr_en),
      .wr_data  (wr_data),
      .wr_bten  (wr_bten),
      .rd_addr  (rd_addr),
      .rd_en    (rd_en),    // delayed version can be used to "clear on read"
      .rd_valid (rd_valid), // Connect directly to rd_en if no additional delay is needed
      .rd_data  (rd_data)
      );


   /////////////////
   // Register Map
   /////////////////


   // read mux
   wire [31:0] dout_0;
   wire [31:0] dout_1;
   wire [31:0] dout_2;
   wire [31:0] dout_3;
   wire [31:0] dout_4;
   wire [31:0] dout_5;
   wire [31:0] dout_6;
   wire [31:0] dout_7;
   wire [31:0] dout_8;
   wire [31:0] dout_9;
   wire [31:0] dout_10;
   wire [31:0] dout_11;
   wire [31:0] dout_12;
   wire [31:0] dout_13;
   wire [31:0] dout_14;
   wire [31:0] dout_15;
   wire [31:0] dout_16;
   wire [31:0] dout_17;
   wire [31:0] dout_18;
   wire [31:0] dout_19;
   wire [31:0] dout_20;
   wire [31:0] dout_21;
   wire [31:0] dout_22;
   wire [31:0] dout_23;
   wire [31:0] dout_24;
   wire [31:0] dout_25;
   wire [31:0] dout_26;
   wire [31:0] dout_27;
   wire [31:0] dout_28;
   wire [31:0] dout_29;
   wire [31:0] dout_30;
   wire [31:0] dout_31;

   always @ (posedge config_clk) begin
      if (!config_rstn) begin
         rd_valid       <= 1'b0;
         rd_data        <= 32'hdead_c0de;
      end
      else begin
         rd_valid       <= rd_en;

         if (rd_en) begin
            case (rd_addr)
              8'h00   : rd_data <= dout_0;
              8'h04   : rd_data <= dout_1;
              8'h08   : rd_data <= dout_2;
              8'h0c   : rd_data <= dout_3;
              8'h10   : rd_data <= dout_4;
              8'h14   : rd_data <= dout_5;
              8'h18   : rd_data <= dout_6;
              8'h1c   : rd_data <= dout_7;
              8'h20   : rd_data <= dout_8;
              8'h24   : rd_data <= dout_9;
              8'h28   : rd_data <= dout_10;
              8'h2c   : rd_data <= dout_11;
              8'h30   : rd_data <= dout_12;
              8'h34   : rd_data <= dout_13;
              8'h38   : rd_data <= dout_14;
              8'h3c   : rd_data <= dout_15;
              8'h40   : rd_data <= dout_16;
              8'h44   : rd_data <= dout_17;
              8'h48   : rd_data <= dout_18;
              8'h4c   : rd_data <= dout_19;
              8'h50   : rd_data <= dout_20;
              8'h54   : rd_data <= dout_21;
              8'h58   : rd_data <= dout_22;
              8'h5c   : rd_data <= dout_23;
              8'h60   : rd_data <= dout_24;
              8'h64   : rd_data <= dout_25;
              8'h68   : rd_data <= dout_26;
              8'h6c   : rd_data <= dout_27;
              8'h70   : rd_data <= dout_28;
              8'h74   : rd_data <= dout_29;
              8'h78   : rd_data <= dout_30;
              8'h7c   : rd_data <= dout_31;
              default : rd_data <= 32'hdead_c0de;
            endcase // case (rd_addr)
         end // if (rd_en)
         
      end // else: !if(!config_rstn)
   end // always @ (posedge config_clk)


   // control bits

   always @ (posedge config_clk) begin
      if (!config_rstn) begin
         sample_count                  <= 32'd1;
         sample_toggle                 <= 1'b0;
         rst_count                     <= 4'd0;
         rst_pulse                     <= 1'b1;
         rst_rx_ctrl                   <= 1'b1;
         capt_count                    <= 4'd0;
         capt_pls                      <= 1'b1;
         resync_count                  <= 4'd0;
         resync_pls                    <= 1'b1;
         err_inj_count                 <= 4'd0;
         err_inj_pls                   <= 1'b0;
         err_inj_field_tmp             <= {16{1'b0}};
         prbs_enab                     <= 1'b0;
         lpbk_enab                     <= 1'b0;
         tx_init_count                 <= 4'd0;
         tx_init_pulse                 <= 1'b1;
         rx_init_count                 <= 4'd0;
         rx_init_pulse                 <= 1'b1;
         tx_pcs_fec_phy_reset_override <= 1'b0;
         tx_core_rst_override          <= 1'b0;
         rx_pcs_fec_phy_reset_override <= 1'b0;
         rx_core_rst_override          <= 1'b0;
      end // if (!config_rstn)
      else begin

         // Sample Period for the Received Data Rate measurement
         if (sample_count == SAMPLE_PERIOD) begin
            sample_count  <= 32'd1;
            sample_toggle <= ~sample_toggle;
         end
         else begin
            sample_count  <= sample_count + 1'b1;
         end


         // defaults
         if (rst_count != 4'd15)
           rst_count     <= rst_count + 1'b1;
         else
           rst_pulse     <= 1'b0;

         if (capt_count != 4'd15)
           capt_count    <= capt_count + 1'b1;
         else
           capt_pls      <= 1'b0;

         if (resync_count != 4'd15)
           resync_count  <= resync_count + 1'b1;
         else
           resync_pls    <= 1'b0;

         if (tx_init_count != 4'd15)
           tx_init_count <= tx_init_count + 1'b1;
         else
           tx_init_pulse <= 1'b0;

         if (rx_init_count != 4'd15)
           rx_init_count <= rx_init_count + 1'b1;
         else
           rx_init_pulse <= 1'b0;

         if (err_inj_count != 4'd15)
           err_inj_count <= err_inj_count + 1'b1;
         else
           err_inj_pls   <= 1'b0;


         if (wr_en) begin
            case (wr_addr)
              5'h14 : begin
                 // Reset Pulse for PHYs.
                 if (wr_bten[0] && wr_data[0]) begin
                    rst_count    <= 4'd0;
                    rst_pulse    <= 1'b1;
                 end

                 // Capture Pulse for grabbing counts from rx_clkout domain.
                 if (wr_bten[0] && wr_data[4]) begin
                    capt_count   <= 4'd0;
                    capt_pls     <= 1'b1;
                 end

                 // Control Register bits.
                 if (wr_bten[1]) begin
                    prbs_enab    <= wr_data[8];
                    lpbk_enab    <= wr_data[12];
                 end

                 // PRBS Checker Resync Pulse.
                 if (wr_bten[1] && wr_data[9]) begin
                    resync_count <= 4'd0;
                    resync_pls   <= 1'b1;
                 end

                 // Reset Override Signals
                 if (wr_bten[2]) begin
                    tx_pcs_fec_phy_reset_override <= wr_data[16];
                    tx_core_rst_override          <= wr_data[17];
                    rx_pcs_fec_phy_reset_override <= wr_data[18];
                    rx_core_rst_override          <= wr_data[19];
                 end

                 // TX Link Reinitialization
                 if (wr_bten[2] && wr_data[20]) begin
                    tx_init_count <= 4'd0;
                    tx_init_pulse <= 1'b1;
                 end

                 // RX Link Reinitialization
                 if (wr_bten[2] && wr_data[21]) begin
                    rx_init_count <= 4'd0;
                    rx_init_pulse <= 1'b1;
                 end

              end // case: 5'h14

              5'h18 : begin
                 // Error Injection Pulse.
                 err_inj_count <= 4'd0;
                 err_inj_pls   <= 1'b1;

                 if (wr_bten[0])
                   err_inj_field_tmp[7:0] <= wr_data[7:0];

                 if (wr_bten[1])
                   err_inj_field_tmp[15:8] <= wr_data[15:8];

              end // case: 5'h18

            endcase // case (wr_addr)

         end // if (wr_en)

      end // else: !if(!config_rstn)
   end // always @ (posedge config_clk)

   assign err_inj_field = err_inj_field_tmp[(WM*8)-1:0];


   ////////////////////////////////////////////////////////////
   //
   // Status Synchronization
   //
   // Reset the status signals from the SerialLite IP
   //
   ////////////////////////////////////////////////////////////

   genvar  i;

   generate
      
      for (i=0;i<(WM*8);i=i+1) begin : ftile_retime

         retime retime_phy_tx_lanes_stable (.reset(1'b0), .clock(config_clk), .d(phy_tx_lanes_stable[i]), .q(phy_tx_lanes_stable_sync[i]) );
         retime retime_tx_pll_locked       (.reset(1'b0), .clock(config_clk), .d(tx_pll_locked[i]),       .q(tx_pll_locked_sync[i])       );
         retime retime_phy_ehip_ready      (.reset(1'b0), .clock(config_clk), .d(phy_ehip_ready[i]),      .q(phy_ehip_ready_sync[i])      );
         retime retime_rx_cdr_lock         (.reset(1'b0), .clock(config_clk), .d(rx_cdr_lock[i]),         .q(rx_cdr_lock_sync[i])         );
         retime retime_phy_rx_block_lock   (.reset(1'b0), .clock(config_clk), .d(phy_rx_block_lock[i]),   .q(phy_rx_block_lock_sync[i])   );
         retime retime_phy_rx_pcs_ready    (.reset(1'b0), .clock(config_clk), .d(phy_rx_pcs_ready[i]),    .q(phy_rx_pcs_ready_sync[i])    );
         retime retime_phy_rx_hi_ber       (.reset(1'b0), .clock(config_clk), .d(phy_rx_hi_ber[i]),       .q(phy_rx_hi_ber_sync[i])       );

      end // for (i=0;i<(WM*8);i=i+1)

   endgenerate


   ////////////////////////////////////////////////////////////
   //
   // Reset Sequence
   // Split the RX and TX resets into separate state machines
   // Reconfig Reset also in its own process.
   //
   // From the F-Tile Serial Lite IV FPGA IP User Guide
   // Quartus 23.3, 2023.10.02, IP Version 9.1.0
   // The * points are the ones that have changed from IP Version 8.1.0
   //
   // The TX reset sequence for F-Tile Serial Lite IV Intel FPGA IP is as follows:
   //
   // 1. Assert tx_pcs_fec_phy_reset_n, tx_core_rst_n, reconfig_reset, and
   // reconfig_sl_reset simultaneously to reset the F-Tile hard IP, MAC, and
   // reconfiguration blocks. Release tx_pcs_fec_phy_reset_n and reconfiguration
   // reset after waiting for tx_reset_ack to ensure the blocks are properly reset.
   //
   // 2*. Release the tx_core_rst_n signal after tx_pll_locked signal goes high.
   //
   // 3*. The IP then asserts the phy_tx_lanes_stable and phy_ehip_ready signals
   // after tx_core_rst_n is released, to indicate the TX PHY is ready for
   // transmission.
   //
   // 4. The IP starts transmitting IDLE characters on the MII interface once the MAC is
   // out of reset. There is no requirement for TX lane alignment and skewing because
   // all lanes use the same clock.
   //
   // 5. While transmitting IDLE characters, the MAC asserts the tx_link_up signal.
   //
   // 6. The MAC then starts transmitting ALIGN paired with START/END or END/START
   // CW at a fixed interval to initiate the lane alignment process of the connected
   // receiver.
   //
   //
   // The RX reset sequence for F-Tile Serial Lite IV Intel FPGA IP is as follows:
   //
   // 1. Assert rx_pcs_fec_phy_reset_n, rx_core_rst_n, reconfig_reset, and
   // reconfig_sl_reset simultaneously to reset the F-tile hard IP, MAC, and
   // reconfiguration blocks. Release rx_pcs_fec_phy_reset_n and reconfiguration
   // reset after waiting for rx_reset_ack to ensure the blocks are properly reset.
   //
   // 2. The IP then asserts the phy_rx_pcs_ready signal after the custom PCS reset is
   // released, to indicate RX PHY is ready for transmission.
   //
   // 3. Release the rx_core_rst_n signal after phy_rx_pcs_ready signal goes high.
   //
   // 4. The IP starts the lane alignment process after the RX MAC reset is released and
   // upon receiving ALIGN paired with START/END or END/START CW.
   //
   // 5. The RX deskew block asserts the rx_link_up signal once alignment for all lanes
   // has complete.
   //
   // 6. The IP then asserts the rx_link_up signal to the user logic to indicate that the
   // RX link is ready to start data reception.
   //
   ////////////////////////////////////////////////////////////


   retime retime_tx_link_up   (.reset(~config_rstn), .clock(config_clk), .d(tx_link_up),   .q(tx_link_up_sync)   );
   retime retime_rx_link_up   (.reset(~config_rstn), .clock(config_clk), .d(rx_link_up),   .q(rx_link_up_sync)   );
   retime retime_tx_reset_ack (.reset(~config_rstn), .clock(config_clk), .d(tx_reset_ack), .q(tx_reset_ack_sync) );
   retime retime_rx_reset_ack (.reset(~config_rstn), .clock(config_clk), .d(rx_reset_ack), .q(rx_reset_ack_sync) );

   always @ (posedge config_clk) begin
      if (!config_rstn) begin
         rx_link_up_sync2    <= 1'b0;
         reconfig_reset      <= 1'b1;
         pcs_fec_phy_reset_n <= 1'b0;
         tx_core_rst_n       <= 1'b0;
         rx_core_rst_n       <= 1'b0;
         rx_lu_cnt           <= 32'd0;
      end
      else begin
         rx_link_up_sync2    <= rx_link_up_sync;

         // Count the number of times we get RX LINK UP - DEBUG only
         if (rx_link_up_sync && ~rx_link_up_sync2)
           rx_lu_cnt         <= rx_lu_cnt + 1'b1;

         if (rst_pulse ||
             (tx_core_rst_override || tx_pcs_fec_phy_reset_override) ||
             (rx_core_rst_override || rx_pcs_fec_phy_reset_override)) begin
            reconfig_reset      <= 1'b1;
            pcs_fec_phy_reset_n <= 1'b0;
         end
         else begin

            if (tx_reset_ack_sync && rx_reset_ack_sync) begin
               reconfig_reset      <= 1'b0;
               pcs_fec_phy_reset_n <= 1'b1;
            end

         end // else: !if(rst_pulse ||...


         // In Quartus 23.2 and beyond, F-Tile IP 9.1.0 and beyond,
         //  release TX_CORE_RST_N when TX_PLL_LOCKED goes high
         //  no longer wait for PHY_TX_LANES_STABLE or PHY_EHIP_READY
         if (rst_pulse || tx_core_rst_override)
           tx_core_rst_n       <= 1'b0;
         else if (&tx_pll_locked_sync)
           tx_core_rst_n       <= 1'b1;

         //  Wait on PHY_RX_PCS_READY and pcs_fec_phy_reset_n being deasserted.
         //  This ensures rx_core_rst_n is not released too early, as has been seen with Q24.3 signal tap captures)
         if (rst_pulse || rx_core_rst_override)
           rx_core_rst_n       <= 1'b0;
         else if (&phy_rx_pcs_ready_sync && pcs_fec_phy_reset_n)
           rx_core_rst_n       <= 1'b1;

      end // else: !if(!config_rstn)
   end // always @ (posedge config_clk)


   // Retime signals to TX Clock domain
   
   retime retime_tx_core_rst_n          (.reset(1'b0), .clock(tx_core_clkout), .d(tx_core_rst_n),       .q(tx_core_rst_n_sync)          );
   retime retime_pcs_fec_phy_reset_n_tx (.reset(1'b0), .clock(tx_core_clkout), .d(pcs_fec_phy_reset_n), .q(pcs_fec_phy_reset_n_tx_sync) );
   retime retime_err_inj_pls            (.reset(1'b0), .clock(tx_core_clkout), .d(err_inj_pls),         .q(err_inj_pls_sync)            );
   retime retime_tx_init_pulse          (.reset(1'b0), .clock(tx_core_clkout), .d(tx_init_pulse),       .q(tx_init_pulse_sync)          );

   always @ (posedge tx_core_clkout) begin
      tx_core_rst_n_sync2 <= tx_core_rst_n_sync; // works because flops are 0 after configuration
      err_inj_pls_sync2   <= err_inj_pls_sync;
      tx_init_pulse_sync2 <= tx_init_pulse_sync;
   end

   assign tx_avs_valid  = tx_enable; // no need to negate when READY negates
   assign tx_gen_enable = tx_enable & tx_avs_ready;

   always @ (posedge tx_core_clkout) begin
      if (!tx_core_rst_n_sync2) begin
         tx_gen_reset   <= 1'b1;
         tx_enable      <= 1'b0;
         error_inject   <= {8{1'b0}};
         tx_link_reinit <= 1'b0;
      end
      else begin
         // Keep error inject asserted until data valid to avoid missing on an invalid cycle
         if (err_inj_pls_sync2 && !err_inj_pls_sync) // falling edge
           error_inject <= err_inj_field;
         else if (tx_gen_enable)
           error_inject <= {(WM*8){1'b0}};

         tx_link_reinit <= tx_init_pulse_sync & ~tx_init_pulse_sync2; // rising edge

         // Release Reset and wait for TX Link Up
         tx_gen_reset   <= 1'b0;

         // Enable PRBS when TX Link Up.  May be that RX Link Up will be needed also but won't know until design is being tested.
         if (tx_link_up)
           tx_enable    <= 1'b1;

      end // else: !if(!tx_core_rst_n_sync2)
   end // always @ (posedge tx_core_clkout)


   // PRBS Generation (16x64-bit generators, each set to PRBS31)
   wide_prbs_gen #(.width(31),.data_width(64)) wide_prbs_gen[(WM*8)-1:0]
     (
      .clock            (tx_core_clkout),
      .sync_reset       (tx_gen_reset),
      .enable           (tx_gen_enable),
      .load             (1'b0),
      .prbs_context_in  ({64{1'b1}}),
      .prbs_context_out (),
      .data             (tx_avs_data_i)
      );

   // Error Injection.
   // The design only injects a single error now
   always @ (posedge tx_core_clkout) begin
     if (tx_gen_enable)
       if (RATE==2) begin
          tx_avs_data <= {(tx_avs_data_i[15] ^ {63'd0,error_inject[15]}),
                          (tx_avs_data_i[14] ^ {63'd0,error_inject[14]}),
                          (tx_avs_data_i[13] ^ {63'd0,error_inject[13]}),
                          (tx_avs_data_i[12] ^ {63'd0,error_inject[12]}),
                          (tx_avs_data_i[11] ^ {63'd0,error_inject[11]}),
                          (tx_avs_data_i[10] ^ {63'd0,error_inject[10]}),
                          (tx_avs_data_i[ 9] ^ {63'd0,error_inject[ 9]}),
                          (tx_avs_data_i[ 8] ^ {63'd0,error_inject[ 8]}),
                          (tx_avs_data_i[ 7] ^ {63'd0,error_inject[ 7]}),
                          (tx_avs_data_i[ 6] ^ {63'd0,error_inject[ 6]}),
                          (tx_avs_data_i[ 5] ^ {63'd0,error_inject[ 5]}),
                          (tx_avs_data_i[ 4] ^ {63'd0,error_inject[ 4]}),
                          (tx_avs_data_i[ 3] ^ {63'd0,error_inject[ 3]}),
                          (tx_avs_data_i[ 2] ^ {63'd0,error_inject[ 2]}),
                          (tx_avs_data_i[ 1] ^ {63'd0,error_inject[ 1]}),
                          (tx_avs_data_i[ 0] ^ {63'd0,error_inject[ 0]})};
       end
       else begin
          tx_avs_data <= {(tx_avs_data_i[ 7] ^ {63'd0,error_inject[ 7]}),
                          (tx_avs_data_i[ 6] ^ {63'd0,error_inject[ 6]}),
                          (tx_avs_data_i[ 5] ^ {63'd0,error_inject[ 5]}),
                          (tx_avs_data_i[ 4] ^ {63'd0,error_inject[ 4]}),
                          (tx_avs_data_i[ 3] ^ {63'd0,error_inject[ 3]}),
                          (tx_avs_data_i[ 2] ^ {63'd0,error_inject[ 2]}),
                          (tx_avs_data_i[ 1] ^ {63'd0,error_inject[ 1]}),
                          (tx_avs_data_i[ 0] ^ {63'd0,error_inject[ 0]})};
       end
   end // always @ (posedge tx_core_clkout)



   // loopback FIFO to skip the F-Tile for debug
   wire                gf_empty;
   wire [(WM*512)-1:0] gf_data;

   general_fifo
     #(
       .DWIDTH               ((WM*512)), // FIFO data width (bits)
       .AWIDTH               (5),        // FIFO address width (bits)
       .ALMOST_FULL_THOLD    (20),       // Almost Full Flag (<<2^AWIDTH)
       .RAMTYPE              ("block"),  // RAM type (block or distributed)
       .FIRST_WORD_FALL_THRU (1)         // FIFO behaviour
       )
   general_fifo_debug
     (
      .write_clock   (tx_core_clkout),
      .read_clock    (rx_core_clkout),
      .fifo_flush    (~rx_core_rst_n_sync2),
      .write_enable  (tx_gen_enable),
      .write_data    (tx_avs_data),
      .read_enable   (~gf_empty),
      .read_data     (gf_data),
      .almost_full   (), // out std_logic;
      .depth         (), // out std_logic_vector(AWIDTH-1 downto 0);
      .empty         (gf_empty)
      );


   wire                sample_toggle_tx_sync;
   reg                 sample_toggle_tx_sync2;
   wire                capt_pls_tx_sync;
   reg                 capt_pls_tx_sync2;

   retime retime_sample_toggle_tx (.reset(~tx_core_rst_n_sync2), .clock(tx_core_clkout), .d(sample_toggle), .q(sample_toggle_tx_sync) );
   retime retime_capt_pls_tx      (.reset(~tx_core_rst_n_sync2), .clock(tx_core_clkout), .d(capt_pls),      .q(capt_pls_tx_sync)      );

   always @ (posedge tx_core_clkout) begin
      if (!tx_core_rst_n_sync2) begin
         sample_toggle_tx_sync2 <= 1'b0;
         capt_pls_tx_sync2      <= 1'b0;
         tx_word_count          <= 32'd0;
         tx_word_store          <= 32'd0;
         capt_tx_word_store     <= 32'd0;
      end
      else begin
         sample_toggle_tx_sync2 <= sample_toggle_tx_sync;
         capt_pls_tx_sync2      <= capt_pls_tx_sync;

         if (sample_toggle_tx_sync ^ sample_toggle_tx_sync2) begin // either edge
            tx_word_count <= {31'd0,tx_gen_enable};
            tx_word_store <= tx_word_count;
         end
         else if (tx_word_count != 32'hFFFFFFFF) begin
            tx_word_count <= tx_gen_enable ? tx_word_count + 1'b1 : tx_word_count;
         end

         if (capt_pls_tx_sync && !capt_pls_tx_sync2) // rising edge
           capt_tx_word_store <= tx_word_store;
      end // else: !if(!tx_core_rst_n_sync2)
   end // always @ (posedge tx_core_clkout)


   // RX Clock Retimers
   retime retime_rx_core_rst_n          (.reset(1'b0), .clock(rx_core_clkout), .d(rx_core_rst_n),       .q(rx_core_rst_n_sync)          );
   retime retime_pcs_fec_phy_reset_n_rx (.reset(1'b0), .clock(rx_core_clkout), .d(pcs_fec_phy_reset_n), .q(pcs_fec_phy_reset_n_rx_sync) );
   retime retime_resync_pls             (.reset(1'b0), .clock(rx_core_clkout), .d(resync_pls),          .q(resync_pls_sync)             );
   retime retime_sample_toggle_rx       (.reset(1'b0), .clock(rx_core_clkout), .d(sample_toggle),       .q(sample_toggle_rx_sync)       );
   retime retime_capt_pls_rx            (.reset(1'b0), .clock(rx_core_clkout), .d(capt_pls),            .q(capt_pls_rx_sync)            );
   retime retime_prbs_enab              (.reset(1'b0), .clock(rx_core_clkout), .d(prbs_enab),           .q(prbs_enab_sync)              );
   retime retime_lpbk_enab              (.reset(1'b0), .clock(rx_core_clkout), .d(lpbk_enab),           .q(lpbk_enab_sync)              );
   retime retime_rx_init_pulse          (.reset(1'b0), .clock(rx_core_clkout), .d(rx_init_pulse),       .q(rx_init_pulse_sync)          );

   always @ (posedge rx_core_clkout) begin
      rx_core_rst_n_sync2    <= rx_core_rst_n_sync;
      sample_toggle_rx_sync2 <= sample_toggle_rx_sync;
      capt_pls_rx_sync2      <= capt_pls_rx_sync;
      rx_init_pulse_sync2    <= rx_init_pulse_sync;
   end

   integer j;

   always @ (posedge rx_core_clkout) begin
      if (!rx_core_rst_n_sync2) begin
         rx_link_reinit      <= 1'b0;
         rx_chk_reset        <= 1'b1;
         capture             <= 1'b0;
         sample_pls          <= 1'b0;
         counter_rst         <= {(WM*8){1'b1}};
         prbs_chk_en         <= 1'b0;
         rx_data_d1          <= {(WM*512){1'b0}};
         rx_valid_d1         <= 1'b0;
         gf_data_d1          <= {(WM*512){1'b0}};
         gf_valid_d1         <= 1'b0;
         rx_data_d2          <= {(WM*512){1'b0}};
         rx_enable           <= 1'b0;
         prbs_lock           <= {(WM*8){1'b0}};
         rx_word_count       <= 32'd0;
         rx_word_store       <= 32'd0;
         capt_rx_word_store  <= 32'd0;
         capt_prbs_err_count <= {(WM*8){16'd0}};
      end // if (!rx_core_rst_n_sync2)
      else begin
         rx_link_reinit <= rx_init_pulse_sync    & ~rx_init_pulse_sync2;    // rising edge
         rx_chk_reset   <= resync_pls_sync;                                 // delay
         capture        <= capt_pls_rx_sync      & ~capt_pls_rx_sync2;      // rising edge
         sample_pls     <= sample_toggle_rx_sync ^  sample_toggle_rx_sync2; // either edge

         // clear the counters on resync and restart them individually as PRBS checkers lock
         //  keep the counters running even if prbs_chk_lock clears later
         if (rx_chk_reset) // an extended pulse, long enough for PRBS_CHK_LOCK to clear
           counter_rst <= {(WM*8){1'b1}};
         else
           counter_rst <= ~prbs_chk_lock & counter_rst; // bit-wise AND

         // Determine enables for Checkers.
         if (rx_link_up && prbs_enab_sync)
           prbs_chk_en <= 1'b1;
         else
           prbs_chk_en <= 1'b0;

         // Pipeline Data and Control.
         rx_data_d1     <= rx_avs_data;
         rx_valid_d1    <= rx_avs_valid;

         gf_data_d1     <=  gf_data;
         gf_valid_d1    <= ~gf_empty;

         rx_data_d2     <= lpbk_enab_sync ? gf_data_d1                : rx_data_d1;
         rx_enable      <= lpbk_enab_sync ? gf_valid_d1 & prbs_chk_en : rx_valid_d1 & prbs_chk_en;

         // Combine PRBS Locked status.
         if (rx_chk_reset)
           prbs_lock    <= {(WM*8){1'b0}};
         else
           prbs_lock    <= prbs_chk_lock;

         // Continually measure the received data rate.
         // RX_CORE_CLK is at the line rate divided by 64. In this case, it
         //  is expected to operate at
         // 25Gbps * 66/64 (PCS) * 34/33 (FEC) / 64b/cycle = 415.039 MHz
         //
         // This counter increments when actually transferring data, removing
         //  the FEC encoding, PCS encoding and lane alignment/ID code words.
         //
         // The encoding transfer rates are
         //  - FEC encoding     = 34/33
         //  - PCS encoding     = 33/32
         //  - lane alignemt/ID = 16384/16383
         //
         // This reduces the effective data rate to
         //  415.039 * 33/34 * 32/33 * 16383/16384 = 390.601 MHz
         //
         // After 1 second, the counter is 390601158 = 0x1748196c
         // Only the 16 MSBs are transferred to S/W or 0x1748
         //
         // S/W can return this to a data rate by multiplying by 0x10000
         //  or 65536, then by 64 bits/cycle (for a total shift left of 22 bits)
         //  0x1748 * 0x10000 * 0x40 = 5,960 * 65,536 * 64 = 24,998 Gbps
         if (sample_pls) begin
            rx_word_count <= {31'd0,rx_valid_d1};
            rx_word_store <= rx_word_count;
         end
         else if (!rx_chk_reset & (rx_word_count != 32'hFFFFFFFF)) begin
            rx_word_count <= rx_valid_d1 ? rx_word_count + 1'b1 : rx_word_count;
         end

         // Capture the line rate values for reading from the config_clk domain.
         if (rx_chk_reset)
           capt_rx_word_store <= 32'd0;
         else if (capture)
           capt_rx_word_store <= rx_word_store;

         for (j=0;j<(WM*8);j=j+1) begin

            // Capture the count values for reading from the config_clk domain.
            if (rx_chk_reset)
              capt_prbs_err_count[j] <= 16'd0;
            else if (capture)
              capt_prbs_err_count[j] <= prbs_err_count[j];

         end // for (i=0;i<16;i=i+1)

      end // else: !if(!rx_core_rst_n_sync2)
   end // always @ (posedge rx_core_clkout)


   wide_prbs_checker #(.width(31),.data_width(64),.lock_width(4)) wide_prbs_checker[(WM*8)-1:0]
     (
      .clock            (rx_core_clkout),
      .sync_reset       (rx_chk_reset),
      .enable           (rx_enable),
      .load             (1'b0),
      .prbs_context_in  ({68{1'b1}}), // lock_width + data_width
      .prbs_context_out (),
      .prbs             (rx_data_d2),
      .data             (prbs_chk_err),
      .match            (),
      .prbs_lock        (prbs_chk_lock)
      );

   err_count_64 err_count_64[(WM*8)-1:0]
     (
      .clock      (rx_core_clkout),
      .sync_reset (counter_rst),
      .enable     (rx_enable),
      .data       (prbs_chk_err),
      .count      (prbs_err_count)
      );

   wire [15:0] tx_pll_locked_sync_tmp;
   wire [15:0] phy_ehip_ready_sync_tmp;
   wire [15:0] phy_tx_lanes_stable_sync_tmp;
   wire [15:0] phy_rx_block_lock_sync_tmp;
   wire [15:0] rx_cdr_lock_sync_tmp;
   wire [15:0] phy_rx_hi_ber_sync_tmp;
   wire [15:0] phy_rx_pcs_ready_sync_tmp;
   wire [15:0] prbs_lock_tmp;

   assign tx_pll_locked_sync_tmp       = (RATE==2) ? tx_pll_locked_sync       : {8'd0,tx_pll_locked_sync};
   assign phy_ehip_ready_sync_tmp      = (RATE==2) ? phy_ehip_ready_sync      : {8'd0,phy_ehip_ready_sync};
   assign phy_tx_lanes_stable_sync_tmp = (RATE==2) ? phy_tx_lanes_stable_sync : {8'd0,phy_tx_lanes_stable_sync};
   assign phy_rx_block_lock_sync_tmp   = (RATE==2) ? phy_rx_block_lock_sync   : {8'd0,phy_rx_block_lock_sync};
   assign rx_cdr_lock_sync_tmp         = (RATE==2) ? rx_cdr_lock_sync         : {8'd0,rx_cdr_lock_sync};
   assign phy_rx_hi_ber_sync_tmp       = (RATE==2) ? phy_rx_hi_ber_sync       : {8'd0,phy_rx_hi_ber_sync};
   assign phy_rx_pcs_ready_sync_tmp    = (RATE==2) ? phy_rx_pcs_ready_sync    : {8'd0,phy_rx_pcs_ready_sync};
   assign prbs_lock_tmp                = (RATE==2) ? prbs_lock                : {8'd0,prbs_lock};

   assign dout_0 = {tx_pll_locked_sync_tmp,        // [31:16]
                     LANES_IN_USE,                  // [15: 8]
                     pcs_fec_phy_reset_n,           // [    7]
                     reconfig_reset,                // [    6]
                     tx_reset_ack_sync,             // [    5]
                     rx_reset_ack_sync,             // [    4]
                     tx_core_rst_n,                 // [    3]
                     rx_core_rst_n,                 // [    2]
                     rx_link_up_sync,               // [    1]
                     tx_link_up_sync};              // [    0]

   assign dout_1 = {phy_ehip_ready_sync_tmp,       // [31:16]
                     phy_tx_lanes_stable_sync_tmp}; // [15: 0]
   assign dout_2 = {phy_rx_block_lock_sync_tmp,    // [31:16]
                     rx_cdr_lock_sync_tmp};         // [15: 0]
   assign dout_3 = {phy_rx_hi_ber_sync_tmp,        // [31:16]
                     phy_rx_pcs_ready_sync_tmp};    // [15: 0]
   assign dout_4 = {16'd0,                         // [31:16]
                     prbs_lock_tmp};                // [15: 0]
   assign dout_5 = {12'd0,                         // [31:20]
                     rx_core_rst_override,          // [   19]
                     rx_pcs_fec_phy_reset_override, // [   18]
                     tx_core_rst_override,          // [   17]
                     tx_pcs_fec_phy_reset_override, // [   16]
                     3'd0,                          // [15:13]
                     lpbk_enab,                     // [   12]
                     3'd0,                          // [11: 9]
                     prbs_enab,                     // [    8]
                     8'd0};                         // [ 7: 0]
   assign dout_6 = {16'd0,err_inj_field_tmp};
   assign dout_7 = 32'd0; // unused
   assign dout_8 = capt_tx_word_store;
   assign dout_9 = capt_rx_word_store;
   assign dout_10 = rx_lu_cnt;
   assign dout_11 = 32'd0; // unused
   assign dout_12 = 32'd0; // unused
   assign dout_13 = 32'd0; // unused
   assign dout_14 = 32'd0; // unused
   assign dout_15 = 32'd0; // unused
   assign dout_16 =             {16'd0,capt_prbs_err_count[ 0]};
   assign dout_17 =             {16'd0,capt_prbs_err_count[ 1]};
   assign dout_18 =             {16'd0,capt_prbs_err_count[ 2]};
   assign dout_19 =             {16'd0,capt_prbs_err_count[ 3]};
   assign dout_20 =             {16'd0,capt_prbs_err_count[ 4]};
   assign dout_21 =             {16'd0,capt_prbs_err_count[ 5]};
   assign dout_22 =             {16'd0,capt_prbs_err_count[ 6]};
   assign dout_23 =             {16'd0,capt_prbs_err_count[ 7]};
   assign dout_24 = (RATE==2) ? {16'd0,capt_prbs_err_count[ 8]} : {32'd0};
   assign dout_25 = (RATE==2) ? {16'd0,capt_prbs_err_count[ 9]} : {32'd0};
   assign dout_26 = (RATE==2) ? {16'd0,capt_prbs_err_count[10]} : {32'd0};
   assign dout_27 = (RATE==2) ? {16'd0,capt_prbs_err_count[11]} : {32'd0};
   assign dout_28 = (RATE==2) ? {16'd0,capt_prbs_err_count[12]} : {32'd0};
   assign dout_29 = (RATE==2) ? {16'd0,capt_prbs_err_count[13]} : {32'd0};
   assign dout_30 = (RATE==2) ? {16'd0,capt_prbs_err_count[14]} : {32'd0};
   assign dout_31 = (RATE==2) ? {16'd0,capt_prbs_err_count[15]} : {32'd0};

endmodule // xcvr_bist_qsfpdd
