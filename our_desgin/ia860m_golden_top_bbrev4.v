
//------------------------------------------------------------------------------
//      UNCLASSIFIED//FOR OFFICIAL USE ONLY
//------------------------------------------------------------------------------
// Title       : IA-860m (top level)
// Project     : IA-860m
//------------------------------------------------------------------------------
// Description:
//   This is the top level of the IA-860m.
//   It contains no architecture therefore will error if a full compilation is
//   attempted.
//   Example uses for the golden top include as a reference project that
//   contains the FPGA pins, associated I/O constraints and required Quartus
//   settings, as an empty project starting point or for configuring IP from
//   Intels IP Catalog with the correct device.
//
// Main interfaces / groupings:
//   PCIe Gen5x16 (R-tile)
//   General Clocks
//   F-Tile Clocking, used for the QSFP-DDs, MCIO and M.2 SSD
//   HBM2e & NoC Clocking
//   Board Management Controller (BMC) Interface
//   LEDs, GPIO, Other
//   QSFP-DDs (F-tile)
//   MCIO (F-Tile)
//   M.2 SSD (F-Tile)
//   1 x 4GB component DDR4 bank (for HPS)
//   HPS
//------------------------------------------------------------------------------
// Known Issues and Omissions:
//
//------------------------------------------------------------------------------

module ia860m_golden_top_bbrev4
  (
  //---------------------------------------------------------------------------
  // PCIe Gen5 x16
  //---------------------------------------------------------------------------
  input          PERST_L,
  input          PCIE_REFCLK0,
  input          PCIE_REFCLK1,
  input   [15:0] PCIE_RX_P,
  input   [15:0] PCIE_RX_N,
  output  [15:0] PCIE_TX_P,
  output  [15:0] PCIE_TX_N,

  //---------------------------------------------------------------------------
  // General Clocks
  //---------------------------------------------------------------------------
  input          USER_CLK0,           // 100 MHz (fabric_lite_clock)

  //---------------------------------------------------------------------------
  // HBM2e & NoC Clocking (현재 lower만 사용)
  //---------------------------------------------------------------------------
  input          HBM_REFCLK0,         // Lower HBM2e Reference Clock
  input          HBM_FBR_REFCLK0,     // Lower HBM2e Fabric Clock
  input          HBM_CATTRIP0,
  input    [2:0] HBM_TEMP0,
  input          NOC_CLK0,            // Lower NoC Reference Clock

  //---------------------------------------------------------------------------
  // Board Management Controller (BMC) reset / presence
  //---------------------------------------------------------------------------
  input          BMC_FPGA_RST_L,
  output         BMC_IF_PRESENT_L,

  //---------------------------------------------------------------------------
  // Buffer Enables (본문에서 상수로 구동 중)
  //---------------------------------------------------------------------------
  output         MCIO_GPIO_EN_L,
  output         MCIO_I2C_EN,
  output         EXT_GPIO_EN_L,

  //---------------------------------------------------------------------------
  // HPS (본문에서 NAND/UART/OSC만 사용)
  //---------------------------------------------------------------------------
  input          HPS_CLK,
  output         HPS_UART_TXD,
  input          HPS_UART_RXD,

  inout    [7:0] HPS_NAND_D,
  output         HPS_NAND_CE_L,
  output         HPS_NAND_CLE,
  output         HPS_NAND_ALE,
  output         HPS_NAND_WE_L,
  output         HPS_NAND_RE_L,
  output         HPS_NAND_WP_L,
  input          HPS_NAND_RB_L
  );
  
// MCIO_GPIO_EN_L must be driven LOW and MCIO_I2C_EN must be driven HIGH when MCIO is in design.
// EXT_GPIO_EN_L must be driven LOW when the GPIO is in design.
// Otherwise can be removed/ignored.
assign MCIO_GPIO_EN_L = 1'b0;
assign MCIO_I2C_EN    = 1'b1;
assign EXT_GPIO_EN_L  = 1'b0;

// The BMC_IF_PRESENT_L must be driven to ensure proper BMC operation.
// When the Bittware BMC FPGA IP is integrated into the design, comment out the statement below (and connect BMC_IF_PRESENT_L to the IP).
assign BMC_IF_PRESENT_L = 1'b1;

wire 	sys_clk;
wire 	pll_locked;
wire 	ninit_done;
wire 	pcie_reset;

// reset_top outputs
wire   [0:0] sys_reset_vec;
wire   [0:0] sys_reset_n_vec;

// reset_top inputs (active-high)
wire   bmc_reset_ah  = ~BMC_FPGA_RST_L; // BMC_FPGA_RST_L : active-low
wire   pcie_reset_ah = ~pcie_reset;     // pcie_reset : active low


reset_release u000 (
	.ninit_done (ninit_done)  //  output,  width = 1, ninit_done.reset
);
user_clk0_pll u001 (
	.refclk   (USER_CLK0),   //   input,  width = 1,  refclk.clk
	.locked   (pll_locked),   //  output,  width = 1,  locked.export
	.rst      (ninit_done),      //   input,  width = 1,   reset.reset
	.outclk_0 (sys_clk)  //  output,  width = 1, outclk0.clk
);	
	
	platform u002 (
    .hbm_cattrip_i_conduit                          (HBM_CATTRIP0),
    .hbm_temp_i_conduit                             (HBM_TEMP0),
    .hbm_ref_clock_in_in_clk_1_clk                  (HBM_FBR_REFCLK0),  // HBM fabric clk
    .hbm_ref_clock_in_in_clk_clk                    (HBM_REFCLK0),      // HBM ref clk
		
    .intel_agilex_hps_0_hps_io_NAND_ALE             (HPS_NAND_ALE),
    .intel_agilex_hps_0_hps_io_NAND_CE_N            (HPS_NAND_CE_L),
    .intel_agilex_hps_0_hps_io_NAND_CLE             (HPS_NAND_CLE),
    .intel_agilex_hps_0_hps_io_NAND_RE_N            (HPS_NAND_RE_L),
    .intel_agilex_hps_0_hps_io_NAND_RB              (HPS_NAND_RB_L),
    .intel_agilex_hps_0_hps_io_NAND_ADQ0            (HPS_NAND_D[0]),
    .intel_agilex_hps_0_hps_io_NAND_ADQ1            (HPS_NAND_D[1]),
    .intel_agilex_hps_0_hps_io_NAND_ADQ2            (HPS_NAND_D[2]),
    .intel_agilex_hps_0_hps_io_NAND_ADQ3            (HPS_NAND_D[3]),
    .intel_agilex_hps_0_hps_io_NAND_ADQ4            (HPS_NAND_D[4]),
    .intel_agilex_hps_0_hps_io_NAND_ADQ5            (HPS_NAND_D[5]),
    .intel_agilex_hps_0_hps_io_NAND_ADQ6            (HPS_NAND_D[6]),
    .intel_agilex_hps_0_hps_io_NAND_ADQ7            (HPS_NAND_D[7]),
    .intel_agilex_hps_0_hps_io_NAND_WP_N            (HPS_NAND_WP_L),
    .intel_agilex_hps_0_hps_io_NAND_WE_N            (HPS_NAND_WE_L),

    .intel_agilex_hps_0_hps_io_UART0_RX             (HPS_UART_RXD),
    .intel_agilex_hps_0_hps_io_UART0_TX             (HPS_UART_TXD),

    .intel_agilex_hps_0_hps_io_hps_osc_clk          (HPS_CLK),
		
		.ninit_done_out_1_reset                         (ninit_done),                         //   input,  width = 1,                    ninit_done_out_1.reset

    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in0    (PCIE_RX_N[0]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in1    (PCIE_RX_N[1]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in2    (PCIE_RX_N[2]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in3    (PCIE_RX_N[3]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in4    (PCIE_RX_N[4]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in5    (PCIE_RX_N[5]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in6    (PCIE_RX_N[6]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in7    (PCIE_RX_N[7]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in8    (PCIE_RX_N[8]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in9    (PCIE_RX_N[9]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in10   (PCIE_RX_N[10]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in11   (PCIE_RX_N[11]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in12   (PCIE_RX_N[12]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in13   (PCIE_RX_N[13]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in14   (PCIE_RX_N[14]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_n_in15   (PCIE_RX_N[15]),

    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in0    (PCIE_RX_P[0]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in1    (PCIE_RX_P[1]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in2    (PCIE_RX_P[2]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in3    (PCIE_RX_P[3]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in4    (PCIE_RX_P[4]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in5    (PCIE_RX_P[5]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in6    (PCIE_RX_P[6]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in7    (PCIE_RX_P[7]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in8    (PCIE_RX_P[8]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in9    (PCIE_RX_P[9]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in10   (PCIE_RX_P[10]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in11   (PCIE_RX_P[11]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in12   (PCIE_RX_P[12]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in13   (PCIE_RX_P[13]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in14   (PCIE_RX_P[14]),
    .intel_pcie_rtile_mcdma_0_hip_serial_rx_p_in15   (PCIE_RX_P[15]),

    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out0   (PCIE_TX_N[0]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out1   (PCIE_TX_N[1]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out2   (PCIE_TX_N[2]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out3   (PCIE_TX_N[3]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out4   (PCIE_TX_N[4]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out5   (PCIE_TX_N[5]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out6   (PCIE_TX_N[6]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out7   (PCIE_TX_N[7]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out8   (PCIE_TX_N[8]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out9   (PCIE_TX_N[9]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out10  (PCIE_TX_N[10]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out11  (PCIE_TX_N[11]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out12  (PCIE_TX_N[12]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out13  (PCIE_TX_N[13]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out14  (PCIE_TX_N[14]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_n_out15  (PCIE_TX_N[15]),

    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out0   (PCIE_TX_P[0]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out1   (PCIE_TX_P[1]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out2   (PCIE_TX_P[2]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out3   (PCIE_TX_P[3]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out4   (PCIE_TX_P[4]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out5   (PCIE_TX_P[5]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out6   (PCIE_TX_P[6]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out7   (PCIE_TX_P[7]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out8   (PCIE_TX_P[8]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out9   (PCIE_TX_P[9]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out10  (PCIE_TX_P[10]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out11  (PCIE_TX_P[11]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out12  (PCIE_TX_P[12]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out13  (PCIE_TX_P[13]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out14  (PCIE_TX_P[14]),
    .intel_pcie_rtile_mcdma_0_hip_serial_tx_p_out15  (PCIE_TX_P[15]),
	
	 .intel_pcie_rtile_mcdma_0_pin_perst_reset_n     (PERST_L),
		.noc_clock_ref_in_in_clk_clk                    (NOC_CLK0),                    //   input,  width = 1,             noc_clock_ref_in_in_clk.clk
		.pcie_ref0_clock_in_in_clk_clk                  (PCIE_REFCLK0),          
		.pcie_ref1_clock_in_in_clk_clk                  (PCIE_REFCLK1),
		.reset_bridge_0_out_reset_reset_n               (pcie_reset),               //  output,  width = 1,            reset_bridge_0_out_reset.reset_n
		.sys_reset_h_in_reset                           (sys_reset_vec[0]),                           //   input,  width = 1,                      sys_reset_h_in.reset
		.sys_reset_n_in_reset_n                         (sys_reset_n_vec[0]),                         //   input,  width = 1,                      sys_reset_n_in.reset_n
		.sysclk_in_clk                                  (sys_clk)                                   //   input,  width = 1,                           sysclk_in.clk
	);


/* --------------------------------------------------------------------------------
-- Description : Top Level for system reset network
--               Generates a number of independent resets synchronous with the
--               system clock. Reset outputs are asserted until a period of time
--               (specified by NUM_SYS_CLK_CYCLES) after the FPGA fabric has
--               been configured and once all reset inputs are deasserted.
--
--               When an input reset is asserted then reset outputs are
--               de-asserted synchronously with sys_clk.
--
--               sys_clk:    System clock
--               pll_locked: Assert when the system clock is stable
--               ninit_done: Output from Intel reset release IP. Asserted until
--                           all the FPGA fabric has been configured.
--               bmc_reset:  Reset input, intended to be the inverted reset
--                           from the BMC
--               pcie_reset: Reset input, intended to be the inverted reset
--                           from the PCIe core. This reset is connected to
--                           a glitch filter within this module.
--
--               sys_reset:   System reset output(s) Active high
--               sys_reset_n: System reset output(s) Active low
--
--               SYS_CLK_RST_CYCLES
--                 The number of system clock cycles the reset it held once all
--                 reset inputs have been deasserted.
--                 The Power On Reset time is:
--                   Period of 'sys_clk' * NUM_SYS_CLK_CYCLES (32-bit)
--               RST_FAN_OUT
--                 The number of system resets generated
--
--               Includes:
--                 * reset_filter
--                 * glitch_filter
--                 * pwr_on_rst_init_dist
--                 * reset_synchronise
*/

// ninit_done : active low
// 

reset_top #(
    .NUM_SYS_CLK_CYCLES(32'h00000100),
    .RST_FAN_OUT(1)
) u_reset_top (
    .sys_clk     (sys_clk),
    .pll_locked  (pll_locked),
    .ninit_done  (ninit_done),
    .bmc_reset   (bmc_reset_ah),
    .pcie_reset  (pcie_reset_ah),
    .sys_reset   (sys_reset_vec),
    .sys_reset_n (sys_reset_n_vec)
);

endmodule // ia860m_golden_top

