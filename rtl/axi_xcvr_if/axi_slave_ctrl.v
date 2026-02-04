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
// Title       : AXI Slave Control
// Project     : Common Gateware
////////////////////////////////////////////////////////////////////////////////
// Description : Converts the AXI interface to a simpler interface for
//               register map accesses
//
////////////////////////////////////////////////////////////////////////////////
// Known Issues and Omissions:
//
//
////////////////////////////////////////////////////////////////////////////////

module axi_slave_ctrl
  (
   // AXI interface
   input              aclk,
   input              areset,

   input        [7:0] awaddr,
   input              awvalid,
   output reg         awready,

   input       [31:0] wdata,
   input        [3:0] wstrb,
   input              wvalid,
   output reg         wready,

   output       [1:0] bresp,
   output reg         bvalid,
   input              bready,

   input        [7:0] araddr,
   input              arvalid,
   output reg         arready,

   output reg  [31:0] rdata,
   output       [1:0] rresp,
   output reg         rvalid,
   input              rready,

   // register map interface
   output reg   [7:0] wr_addr,
   output reg         wr_en,
   output reg  [31:0] wr_data,
   output reg   [3:0] wr_bten,

   output reg   [7:0] rd_addr,
   output reg         rd_en,    // delayed version can be used to "clear on read"
   input              rd_valid, // Connect directly to rd_en if no additional delay is needed
   input       [31:0] rd_data
   );


   // unused
   assign rresp = 2'b00;
   assign bresp = 2'b00;


   // delay ARVALID to provide time to read BRAM
   // ACLK     __/--\__/--\__/--\__/--\__/--\__/--\__/--\__/--\
   // ARVALID  __/-----\_______________________________________
   // ARREADY  --------\___________________________________/---
   // ARV_D0   ________/-----\_________________________________
   // ARV_D1   ______________/-----\___________________________
   //
   // RD_ADDR  xxxxxxxxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
   // RD_EN    ________/-----\_________________________________
   // RD_VALID ______________/-----\___________________________
   // RD_DATA  xxxxxxxxxxxxxxDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
   //
   // RDATA    xxxxxxxxxxxxxxxxxxxxDDDDDDDDDDDDDDDDDDDDDDDDDDDD
   // RVALID   __________________________/-----------\_________
   // RREADY   ________________________________/-----\_________

   enum {RS_INIT,
         RS_ADDR,
         RS_DATA} rstate;

   reg [1:0]              arvalid_d;
   reg                    rd_valid_hold;

   // Provide read address and enable
   always @(posedge aclk) begin
      if (areset) begin
         arvalid_d <= 2'd0;
         rd_addr   <= 8'd0;
         rd_en     <= 1'b0;
      end
      else begin
         arvalid_d <= {arvalid_d[0],(arready & arvalid)};

         // Initiate read of register map immediately
         if ((arready && arvalid) && !arvalid_d[0]) begin
            rd_addr <= araddr;
            rd_en   <= 1'b1;
         end
         else begin
            rd_en   <= 1'b0;
         end
      end // else: !if(areset)
   end // always @ (posedge aclk)

   // read data capture
   // rd_valid should be connected to rd_en if no further delay is needed
   always @(posedge aclk) begin
      if (areset) begin
         rdata <= 32'd0;
      end
      else begin
         if (rd_valid)
           rdata <= rd_data;
      end
   end

   // Read handshake
   always @(posedge aclk) begin
      if (areset) begin
         arready       <= 1'b0;
         rvalid        <= 1'b0;
         rd_valid_hold <= 1'b0;
         rstate        <= RS_INIT;
      end
      else begin
         case (rstate)
           // Add initial state to ensure ARREADY is 1 before
           //  responding to ARVALID by sending it to 0.
           // Otherwise, we could hang the master by acting upon
           //  ARVALID and never providing ARREADY
           RS_INIT: begin
              arready       <= 1'b1;
              rvalid        <= 1'b0;
              rd_valid_hold <= 1'b0;
              rstate        <= RS_ADDR;
           end

           // enforce a 2 cycle delay to support BRAM reads
           // Not positive this is necessary but it works
           RS_ADDR: begin
              arready       <= ~(arvalid | arvalid_d[0] | arvalid_d[1]);
              rvalid        <= 1'b0;
              rd_valid_hold <= rd_valid | rd_valid_hold; // capture and hold early response

              if (arvalid_d[1])
                rstate      <= RS_DATA;
           end

           // Always in this state for at least 2 cycles
           // The first cycle sets RVALID (or waits for rd_valid)
           // The subsequent cycles wait for RREADY
           RS_DATA: begin
              arready       <= 1'b0;
              rvalid        <= rd_valid | rd_valid_hold;
              rd_valid_hold <= rd_valid | rd_valid_hold; // capture and hold response

              if (rready && rvalid) begin
                 rvalid     <= 1'b0;
                 rstate     <= RS_INIT;
              end
           end
         endcase
      end
   end


   enum {WS_ADDR,
         WS_DATA,
         WS_RESP} wstate;

   // write handshake
   always @(posedge aclk) begin
      if (areset) begin
         awready <= 1'b0;
         bvalid  <= 1'b0;
         wready  <= 1'b0;
         wstate  <= WS_ADDR;
      end
      else begin
         case (wstate)
           WS_ADDR: begin
              // defaults
              awready <= 1'b1;
              wready  <= 1'b0;
              bvalid  <= 1'b0;

              if (awready && awvalid) begin
                 awready <= 1'b0;
                 wready  <= 1'b1;
                 wstate  <= WS_DATA;
              end
           end

           WS_DATA: begin
              // defaults
              awready <= 1'b0;
              wready  <= 1'b1;
              bvalid  <= 1'b0;

              if (wready && wvalid) begin
                 wready  <= 1'b0;
                 bvalid  <= 1'b1;
                 wstate  <= WS_RESP;
              end
           end

           WS_RESP: begin
              // defaults
              awready <= 1'b0;
              wready  <= 1'b0;
              bvalid  <= 1'b1;

              if (bready && bvalid) begin
                 awready <= 1'b1;
                 bvalid  <= 1'b0;
                 wstate  <= WS_ADDR;
              end
           end

           default: begin
              wstate  <= WS_ADDR;
           end
         endcase
      end
   end

   always @(posedge aclk) begin
      if (areset) begin
         wr_addr <= 8'd0;
      end
      else begin
         if (awready && awvalid) begin
            wr_addr <= awaddr;
         end
      end
   end

   always @(posedge aclk) begin
      if (areset) begin
         wr_en   <= 1'b0;
         wr_data <= 32'd0;
         wr_bten <= 4'd0;
      end
      else begin
         // default
         wr_en <= 1'b0;

         if (wready && wvalid) begin
            wr_en   <= 1'b1;
            wr_data <= wdata;
            wr_bten <= wstrb;
         end
      end
   end


endmodule // axi_slave_ctrl
