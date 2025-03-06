`timescale 1ns / 1ps

`define DUT_CLK_PERIOD  2
`define RST_DLY_START   3
`define RST_DUR         9

`define END_TIME        1800000

module dbi_tx_controller_tb;
    parameter INTERNAL_CLK          = 125000000;
    parameter DBI_IF_D_W            = 8;
    parameter TID_W                 = 2;
    parameter TDEST_W               = 2;
    parameter TDATA_W               = 256;
    parameter TKEEP_W               = TDATA_W/8;
    parameter TSTRB_W               = TDATA_W/8;
    parameter AXIS_FIFO_D           = 2;    // AXI-Stream FIFO depth (width: 256)
    parameter ATX_ID_W              = 5;
    parameter ATX_ADDR_W            = 32;
    parameter ATX_DATA_W            = 32;
    parameter ATX_LEN_W             = 8;
    parameter ATX_SIZE_W            = 3;
    parameter ATX_RESP_W            = 2;
    parameter ATX_BASE_ADDR         = 32'h1000_0000;    // AXI4 Address map
    parameter TDEST_MASK            = 2'b00;            // AXIS Destination map
    parameter IN_PXL_TYPE           = "GRAY";   // "GRAY": Gray pixel || "RGB": RGB565 pixel
    parameter OUT_PXL_TYPE          = "RGB";    // Always "RGB" - RGB565 pixel
    parameter FRM_COL_NUM           = 640;      // Maximum number of columns in 1 frame
    parameter FRM_ROW_NUM           = 480;       // Maximum number of rows in 1 frame
    logic                      clk;
    logic                      rst_n;
    
    // AXI-Stream interface
    logic   [TID_W-1:0]             s_tid_i;    
    logic   [TDEST_W-1:0]           s_tdest_i;
    logic   [TDATA_W-1:0]           s_tdata_i;
    logic   [TKEEP_W-1:0]           s_tkeep_i;
    logic   [TSTRB_W-1:0]           s_tstrb_i;
    logic                           s_tlast_i;
    logic                           s_tvalid_i;
    logic                           s_tready_o;
    logic  [MST_ID_W-1:0]      s_awid_i;
    logic  [ADDR_W-1:0]        s_awaddr_i;
    logic  [TRANS_DATA_LEN_W-1:0]  s_awlen_i;
    logic                      s_awvalid_i;
    logic  [s_DATA_W-1:0]     s_wdata_i;
    logic                      s_wlast_i;
    logic                      s_wvalid_i;
    logic                      s_bready_i;
    logic  [MST_ID_W-1:0]      s_arid_i;
    logic  [ADDR_W-1:0]        s_araddr_i;
    logic                      s_arvalid_i;
    logic  [TRANS_DATA_LEN_W-1:0]  s_arlen_i;
    logic                      s_rready_i;

    logic                      s_awready_o;
    logic                      s_wready_o;
    logic  [MST_ID_W-1:0]      s_bid_o;
    logic  [TRANS_RESP_W-1:0]  s_bresp_o;
    logic                      s_bvalid_o;
    logic                      s_arready_o;
    logic  [MST_ID_W-1:0]      s_rid_o;
    logic  [s_DATA_W-1:0]     s_rdata_o;
    logic  [TRANS_RESP_W-1:0]  s_rresp_o;
    logic                      s_rlast_o;
    logic                      s_rvalid_o;
    logic                      dbi_dcx_o;
    logic                      dbi_csx_o;
    logic                      dbi_resx_o;
    logic                      dbi_rdx_o;
    logic                      dbi_wrx_o;
    wire  [DBI_IF_D_W-1:0]     dbi_d_o;

    dbi_tx_controller #(
        .INTERNAL_CLK   (INTERNAL_CLK),
        .DBI_IF_D_W     (DBI_IF_D_W),
        .TID_W          (TID_W),
        .TDEST_W        (TDEST_W),
        .TDATA_W        (TDATA_W),
        .TKEEP_W        (TKEEP_W),
        .TSTRB_W        (TSTRB_W),
        .AXIS_FIFO_D    (AXIS_FIFO_D),
        .ATX_ID_W       (ATX_ID_W),
        .ATX_ADDR_W     (ATX_ADDR_W),
        .ATX_DATA_W     (ATX_DATA_W),
        .ATX_LEN_W      (ATX_LEN_W),
        .ATX_SIZE_W     (ATX_SIZE_W),
        .ATX_RESP_W     (ATX_RESP_W),
        .ATX_BASE_ADDR  (ATX_BASE_ADDR),
        .TDEST_MASK     (TDEST_MASK),
        .IN_PXL_TYPE    (IN_PXL_TYPE),
        .OUT_PXL_TYPE   (OUT_PXL_TYPE),
        .FRM_COL_NUM    (FRM_COL_NUM),
        .FRM_ROW_NUM    (FRM_ROW_NUM),
    ) dut (
        .*
    );

    initial begin
        clk             <= 0;
        rst_n           <= 1;
        
        s_awid_i       <= 0;
        s_awaddr_i     <= 0;
        s_awlen_i      <= 0;
        s_awvalid_i    <= 0;
        
        s_wdata_i      <= 0;
        s_wlast_i      <= 1'b1;
        s_wvalid_i     <= 0;
        
        s_bready_i     <= 1'b1;
        
        s_arid_i       <= 0;
        s_araddr_i     <= 0;
        s_arlen_i      <= 0;
        s_arvalid_i    <= 0;

        s_rready_i     <= 1'b1;

        #(`RST_DLY_START)   rst_n <= 0;
        #(`RST_DUR)         rst_n <= 1;
    end

    initial begin
        forever #(`DUT_CLK_PERIOD/2) clk <= ~clk;
    end

    initial begin   // Configure register
        #(`RST_DLY_START + `RST_DUR + 1);
        fork 
            begin   : AW_chn
                s_aw_transfer(.s_awid(5'h00), .s_awaddr(32'h3000_0001), .s_awlen(8'h00));   // 1st
                s_aw_transfer(.s_awid(5'h01), .s_awaddr(32'h3100_0000), .s_awlen(8'h04));   // 2nd
                s_aw_transfer(.s_awid(5'h02), .s_awaddr(32'h3100_0001), .s_awlen(8'h03));   // 3rd
                s_aw_transfer(.s_awid(5'h03), .s_awaddr(32'h3100_0002), .s_awlen(8'h06));   // 4th
                aclk_cl;
                s_awvalid_i <= 1'b0;

                repeat(20) aclk_cl;

                s_aw_transfer(.s_awid(5'h00), .s_awaddr(32'h3000_0000), .s_awlen(8'h00));   // 5th
                aclk_cl;
                s_awvalid_i <= 1'b0;

                repeat(2_200_000) aclk_cl;

                s_aw_transfer(.s_awid(5'h00), .s_awaddr(32'h3000_0000), .s_awlen(8'h00));   // 6th
                aclk_cl;
                s_awvalid_i <= 1'b0;
            end
            begin   : W_chn
                // 1st
                s_w_transfer(.s_wdata(8'h2C), .s_wlast(1'b1));
                // 2nd
                s_w_transfer(.s_wdata(8'b0000_0010), .s_wlast(1'b0));    // HW_RST
                s_w_transfer(.s_wdata(8'b0001_0000), .s_wlast(1'b0));    // 1 CMD - 4 DAT
                s_w_transfer(.s_wdata(8'b0000_0100), .s_wlast(1'b0));    // 1 CMD - 1 DAT
                s_w_transfer(.s_wdata(8'b0000_1000), .s_wlast(1'b0));    // 1 CMD - 2 DAT
                s_w_transfer(.s_wdata(8'b0000_0000), .s_wlast(1'b1));    // 1 CMD - 0 DAT
                // 3rd
                s_w_transfer(.s_wdata(8'h11), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h22), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h33), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h44), .s_wlast(1'b1));
                // 4th                
                s_w_transfer(.s_wdata(8'h10), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h11), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h12), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h13), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h20), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h30), .s_wlast(1'b0));
                s_w_transfer(.s_wdata(8'h31), .s_wlast(1'b1));
                // 5th
                s_w_transfer(.s_wdata(8'b0000_0001), .s_wlast(1'b1));    // Turn into CONF mode
                // 6th
                s_w_transfer(.s_wdata(8'b0000_0010), .s_wlast(1'b1));    // Turn into CONF mode
                aclk_cl;
                s_wvalid_i <= 1'b0;
            end
            begin   : AR_chn
                repeat(20) begin
                    aclk_cl;
                end
                s_ar_transfer(.s_arid(5'h00), .s_araddr(32'h3100_0000), .s_arlen(8'h02));
                aclk_cl;
                s_arvalid_i <= 1'b0;
            end
        join_none
    end
    initial begin : DMA_AXI
        localparam TX_PER_TXN = 2400;
        int tx_cnt;
        int byte_cnt;
        bit [DMA_DATA_W-1:0] dma_wdata;
        #(`RST_DLY_START + `RST_DUR + 1);
        fork
            begin : DMA_W
                for (tx_cnt=0; tx_cnt < TX_PER_TXN; tx_cnt++) begin
                    for (byte_cnt = 0; byte_cnt < (DMA_DATA_W/8); byte_cnt++) begin
                        dma_wdata[8*(byte_cnt+1)-1-:8] = (byte_cnt%2 == 0) ? '1 : '0;
                    end
                    axis_transfer(.s_tdest(TDEST_MASK), .s_tdata(dma_wdata), .s_tlast((tx_cnt==(TX_PER_TXN-1))));
                end
                aclk_cl;
                s_tvalid_i <= 1'b0;
            end
        join_none
    end

    /* DeepCode */
    task automatic s_aw_transfer(
        input [ATX_ID_W-1:0]    s_awid,
        input [ATX_ADDR_W-1:0]  s_awaddr,
        input [ATX_LEN_W-1:0]   s_awlen
    );
        aclk_cl;
        s_awid_i            <= s_awid;
        s_awaddr_i          <= s_awaddr;
        s_awlen_i           <= s_awlen;
        s_awvalid_i         <= 1'b1;
        // Handshake occur
        wait(s_awready_o == 1'b1); #0.1;
    endtask
    task automatic s_w_transfer (
        input [ATX_DATA_W-1:0]  s_wdata,
        input                   s_wlast
    );
        aclk_cl;
        s_wdata_i          <= s_wdata;
        s_wlast_i          <= s_wlast;
        s_wvalid_i         <= 1'b1;
        // Handshake occur
        wait(s_wready_o == 1'b1); #0.1;
    endtask
    task automatic s_ar_transfer(
        input [ATX_ID_W-1:0]    s_arid,
        input [ATX_ADDR_W-1:0]  s_araddr,
        input [ATX_LEN_W-1:0]   s_arlen
    );
        aclk_cl;
        s_arid_i            <= s_arid;
        s_araddr_i          <= s_araddr;
        s_arlen_i           <= s_arlen;
        s_arvalid_i         <= 1'b1;
        // Handshake occur
        wait(s_arready_o == 1'b1); #0.1;
    endtask

    /* DMA task */
    task automatic axis_transfer (
        input [TDEST_W-1:0]     s_tdest,
        input [TDATA_W-1:0]     s_tdata,
        input                   s_tlast
    );
        aclk_cl;
        s_tdest_i           <= s_tdest;
        s_tdata_i           <= s_tdata;
        s_tlast_i           <= s_tlast;
        s_tvalid_i          <= 1'b1;
        // Handshake occur
        wait(s_tready_o == 1'b1); #0.1;
    endtask

    task automatic aclk_cl;
        @(posedge clk);
        #0.05; 
    endtask
endmodule