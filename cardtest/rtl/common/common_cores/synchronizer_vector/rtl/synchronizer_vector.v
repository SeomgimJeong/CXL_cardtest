/**------------------------------------------------------------------------------
**
**      This source code is provided to you (the Licensee) under license
**      by BittWare, a Molex Company. To view or use this source code,
**      the Licensee must accept a Software License Agreement (viewable
**      at developer.bittware.com), which is commonly provided as a click-
**      through license agreement. The terms of the Software License
**      Agreement govern all use and distribution of this file unless an
**      alternative superseding license has been executed with BittWare.
**      This source code and its derivatives may not be distributed to
**      third parties in source code form. Software including or derived
**      from this source code, including derivative works thereof created
**      by Licensee, may be distributed to third parties with BittWare
**      hardware only and in executable form only.
**
**      The click-through license is available here:
**        https://developer.bittware.com/software_license.txt
**
**------------------------------------------------------------------------------
**      UNCLASSIFIED//FOR OFFICIAL USE ONLY
**-------------------------------------------------------------------------
** Title       : synchronizer_vector
** Project     : Common Gateware
*******************************************************************************/
//
// This module changes a data vector from one clock domain to another, safely.
// It holds the data in the old clock domain when a change in the data value
// is detected, then sends a synchronization signal across to the new clock
// domain (using two flops in the new clock domain for metastability).  When
// the synchronization signal has been seen by the second flop, the held data
// is clocked once in the new clock domain and is ready to use.
//
// This method delays the data by several clocks into the new domain, and can miss
// intermediate values of the data, if the data changes every clock in the old
// domain, for instance.  However, for data that only accumulates, such as status
// bits, or for configuration instructions from software that changes infrequently,
// there will be no problems using this method.
//

`timescale 1ps / 1ps

module synchronizer_vector #
(
   parameter DATA_WIDTH = 1
)
(
   input                        old_clk,
   input       [DATA_WIDTH-1:0] data_in,
   input                        new_clk,
   output wire [DATA_WIDTH-1:0] data_out
);

reg change_sync_1reg, change_sync_2reg, change_sync_3reg;
reg done_sync_1reg, done_sync_2reg;
reg [DATA_WIDTH-1:0] hold_reg = 'h0; //initially
wire data_changed;
reg  [DATA_WIDTH-1:0] data_reg = 'h0; //initially

localparam IDLE = 0, HOLD = 1;
reg state = IDLE;  //initially in IDLE


always @(posedge old_clk)
begin
  case (state)
  
    IDLE: if (data_changed)
            state <= HOLD;
    HOLD: if (done_sync_2reg)
            state <= IDLE;
  endcase
end

// Register input data to detect change in incoming data, hold when
// change is detected.
always @(posedge old_clk)
begin
  if (state == IDLE)
    hold_reg <= data_in;
end

assign data_changed = (data_in !== hold_reg) ? 1'b1 : 1'b0;

// Register enable signal twice for metastability crossing into new clock domain
always @(posedge new_clk)
begin
  change_sync_1reg <= (state == HOLD);
  change_sync_2reg <= change_sync_1reg;
  change_sync_3reg <= change_sync_2reg;
end

// Register twice for metastability, done signal back to old clock domain
always @(posedge old_clk)
begin
  // hold for at least two clocks for change from faster clock to slower clock
  done_sync_1reg <= change_sync_2reg || change_sync_3reg;
  done_sync_2reg <= done_sync_1reg;
end


// When change signal has been registered twice, allow data to cross from old
// clock domain to new clock domain.  The data should not have changed for 
// two of the new clock cycles, so should be quite stable.
always @(posedge new_clk)
begin
  if (change_sync_2reg)
    data_reg <= hold_reg; 
end

assign data_out = data_reg;

endmodule

