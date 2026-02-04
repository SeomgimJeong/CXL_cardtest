
///////////////////////////////////////////////////////////////////////////
// This source code is provided to you (the Licensee) under license by BittWare, a Molex Company.
// To view or use this source code, the Licensee must accept a Software License Agreement (viewable
// at developer.bittware.com), which is commonly provided as a click-through license agreement.
// The terms of the Software License Agreement govern all use and distribution of this file unless
// an alternative superseding license has been executed with BittWare.  This source code and its
// derivatives may not be distributed to third parties in source code form.  Software including or
// derived from this source code, including derivative works thereof created by Licensee, may be
// distributed to third parties with BITTWARE hardware only and in executable form only.
//
// The click-through license is available here: https://developer.bittware.com/software_license.txt
///////////////////////////////////////////////////////////////////////////

module axilite_conversion_44
  (
   // AXI interface
   input             ACLK,
   input             ARESET,

   input      [43:0] mstr_addr, // byte address
   input      [31:0] mstr_wr_data,
   input       [3:0] mstr_wr_byte_en,
   input             mstr_wr_en,
   input             mstr_rd_en,
   output reg        mstr_wr_rdy, // in case the protocol requires it
   output reg [31:0] mstr_rd_data,
   output reg        mstr_rd_rdy,

   output reg [43:0] AWADDR,
   output reg        AWVALID,
   input             AWREADY,

   output reg [31:0] WDATA,
   output reg  [3:0] WSTRB,
   output reg        WVALID,
   input             WREADY,

   input       [1:0] BRESP,
   input             BVALID,
   output reg        BREADY,

   output reg [43:0] ARADDR,
   output reg        ARVALID,
   input             ARREADY,

   input      [31:0] RDATA,
   input       [1:0] RRESP,
   input             RVALID,
   output reg        RREADY,

   output reg  [1:0] resp_err,    // BRESP or RRESP value from latest transfer
   output reg        to_err,      // transaction timeout of 10000 clock cycles
   input             clear_errors // single pulse to clear out all the above errors
   );
   

   enum              {AXI_IDLE,
                      AXI_AW,
                      AXI_B,
                      AXI_AR,
                      AXI_R,
                      AXI_RDY}
                     axi_state;


   localparam XACT_TO = 16'd10000;

   reg [15:0]           to_cnt;
   reg                  timeout;


   always @ (posedge ACLK) begin
      if (ARESET) begin
         axi_state    <= AXI_IDLE;
         resp_err     <= 2'd0;
         AWADDR       <= 44'd0;
         AWVALID      <= 1'b0;
         WDATA        <= 32'd0;
         WSTRB        <= 4'd0;
         WVALID       <= 1'b0;
         BREADY       <= 1'b0;
         ARADDR       <= 44'd0;
         ARVALID      <= 1'b0;
         RREADY       <= 1'b0;
         mstr_rd_data <= 32'd0;
         mstr_rd_rdy  <= 1'b0;
         mstr_wr_rdy  <= 1'b0;
         to_cnt       <= 16'd0;
         timeout      <= 1'b0;
         to_err       <= 1'b0;
      end // if (ARESET)
      else begin

         if (axi_state == AXI_IDLE) begin
            to_cnt  <= XACT_TO;
            timeout <= 1'b0;
         end
         else if (to_cnt != 16'd0) begin
            to_cnt  <= to_cnt - 1'b1;
            timeout <= (to_cnt == 16'd1);
         end

         case (axi_state)
           AXI_IDLE : begin
              AWADDR       <= 44'd0;
              AWVALID      <= 1'b0;
              WDATA        <= 32'd0;
              WSTRB        <= 4'd0;
              WVALID       <= 1'b0;
              BREADY       <= 1'b0;
              ARADDR       <= 44'd0;
              ARVALID      <= 1'b0;
              RREADY       <= 1'b0;
              mstr_rd_data <= 32'd0;
              mstr_rd_rdy  <= 1'b0;
              mstr_wr_rdy  <= 1'b0;

              if (clear_errors) begin
                 resp_err     <= 2'd0;
                 to_err       <= 1'b0;
              end

              if (mstr_wr_en) begin
                 AWADDR    <= mstr_addr;
                 AWVALID   <= 1'b1; // The Subordinate can wait for AWVALID or WVALID, or both before asserting AWREADY
                 WVALID    <= 1'b1; // The Subordinate can wait for AWVALID or WVALID, or both before asserting WREADY
                 WDATA     <= mstr_wr_data;
                 WSTRB     <= mstr_wr_byte_en;
                 axi_state <= AXI_AW;
              end // if (mstr_wr_en)
              else if (mstr_rd_en) begin
                 ARADDR    <= mstr_addr;
                 ARVALID   <= 1'b1;
                 axi_state <= AXI_AR;
              end
           end // case: AXI_IDLE

           AXI_AW : begin
              // no way to know if AWREADY or WREADY comes first
              AWVALID <= AWVALID & ~AWREADY;
              WVALID  <= WVALID  & ~WREADY;
                 
              if (((AWREADY || !AWVALID) && (WREADY || !WVALID)) || timeout) begin
                 BREADY    <= 1'b1;
                 axi_state <= AXI_B;
              end
           end

           AXI_B : begin
              if (BVALID || timeout) begin
                 BREADY    <= 1'b0;

                 if (!timeout)
                   resp_err <= BRESP;

                 mstr_wr_rdy <= 1'b1;

                 to_err    <= timeout;
                 axi_state <= AXI_RDY;
              end
           end // case: AXI_B


           AXI_AR : begin
              if (ARREADY || timeout) begin
                 ARVALID   <= 1'b0;
                 RREADY    <= 1'b1;
                 axi_state <= AXI_R;
              end
           end

           AXI_R : begin
              if (RVALID || timeout) begin
                 RREADY    <= 1'b0;

                 if (!timeout)
                   resp_err <= RRESP;

                 if (timeout) begin
                    mstr_rd_data <= 32'hdead_c0de;
                 end
                 else begin
                    mstr_rd_data <= RDATA;
                 end

                 mstr_rd_rdy <= 1'b1;

                 to_err    <= timeout;
                 axi_state <= AXI_RDY;
              end // if (RVALID)
           end // case: AXI_R

           // Wait for RD_EN/WR_EN to go low - it sometimes takes a while
           // Hold RD_RDY active the entire time
           AXI_RDY : begin
              if ((mstr_rd_rdy && !mstr_rd_en) || (mstr_wr_rdy && !mstr_wr_en)) begin
                 mstr_wr_rdy <= 1'b0;
                 mstr_rd_rdy <= 1'b0;
                 axi_state   <= AXI_IDLE;
              end
           end

           default : begin
              axi_state <= AXI_IDLE;
           end

         endcase // case (axi_state)

      end // else: !if(ARESET)
   end // always @ (posedge ACLK)


endmodule // axi_master_ctrl
