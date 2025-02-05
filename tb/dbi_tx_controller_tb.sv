`timescale 1ns / 1ps

`define DUT_CLK_PERIOD  2
`define RST_DLY_START   3
`define RST_DUR         9

`define END_TIME        1800000

module dbi_tx_controller_tb;
    parameter INTERNAL_CLK          = 125000000;
    parameter DMA_DATA_W            = 256;
    parameter ADDR_W                = 32;
    parameter MC_DATA_W             = 8;
    parameter MST_ID_W              = 5;
    parameter TRANS_DATA_LEN_W      = 8;
    parameter TRANS_DATA_SIZE_W     = 3;
    parameter TRANS_RESP_W          = 2;
    parameter IP_DATA_BASE_ADDR     = 32'h2000_0000;
    parameter IP_CONF_BASE_ADDR     = 32'h3000_0000;
    parameter IP_CONF_OFFSET_ADDR   = 32'h01;
    parameter DBI_IF_D_W            = 8;
    logic                      clk;
    logic                      rst_n;
    logic  [MST_ID_W-1:0]      m_awid_i;
    logic  [ADDR_W-1:0]        m_awaddr_i;
    logic                      m_awvalid_i;
    logic  [DMA_DATA_W-1:0]    m_wdata_i;
    logic                      m_wlast_i;
    logic                      m_wvalid_i;
    logic                      m_bready_i;
    logic  [MST_ID_W-1:0]      mc_awid_i;
    logic  [ADDR_W-1:0]        mc_awaddr_i;
    logic  [TRANS_DATA_LEN_W-1:0]  mc_awlen_i;
    logic                      mc_awvalid_i;
    logic  [MC_DATA_W-1:0]     mc_wdata_i;
    logic                      mc_wlast_i;
    logic                      mc_wvalid_i;
    logic                      mc_bready_i;
    logic  [MST_ID_W-1:0]      mc_arid_i;
    logic  [ADDR_W-1:0]        mc_araddr_i;
    logic                      mc_arvalid_i;
    logic  [TRANS_DATA_LEN_W-1:0]  mc_arlen_i;
    logic                      mc_rready_i;
    logic                      m_awready_o;
    logic                      m_wready_o;
    logic  [MST_ID_W-1:0]      m_bid_o;
    logic  [TRANS_RESP_W-1:0]  m_bresp_o;
    logic                      m_bvalid_o;
    logic                      mc_awready_o;
    logic                      mc_wready_o;
    logic  [MST_ID_W-1:0]      mc_bid_o;
    logic  [TRANS_RESP_W-1:0]  mc_bresp_o;
    logic                      mc_bvalid_o;
    logic                      mc_arready_o;
    logic  [MST_ID_W-1:0]      mc_rid_o;
    logic  [MC_DATA_W-1:0]     mc_rdata_o;
    logic  [TRANS_RESP_W-1:0]  mc_rresp_o;
    logic                      mc_rlast_o;
    logic                      mc_rvalid_o;
    logic                      dbi_dcx_o;
    logic                      dbi_csx_o;
    logic                      dbi_resx_o;
    logic                      dbi_rdx_o;
    logic                      dbi_wrx_o;
    wire  [DBI_IF_D_W-1:0]     dbi_d_o;

    dbi_tx_controller #(

    ) dut (
        .*
    );

    initial begin
        clk             <= 0;
        rst_n           <= 1;

        m_awid_i        <= 0;
        m_awaddr_i      <= 0;
        m_awvalid_i     <= 0;
        
        m_wdata_i       <= 0;
        m_wlast_i       <= 0;
        m_wvalid_i      <= 0;
        
        m_bready_i      <= 1'b1;
        
        mc_awid_i       <= 0;
        mc_awaddr_i     <= 0;
        mc_awlen_i      <= 0;
        mc_awvalid_i    <= 0;
        
        mc_wdata_i      <= 0;
        mc_wlast_i      <= 1'b1;
        mc_wvalid_i     <= 0;
        
        mc_bready_i     <= 1'b1;
        
        mc_arid_i       <= 0;
        mc_araddr_i     <= 0;
        mc_arlen_i      <= 0;
        mc_arvalid_i    <= 0;

        mc_rready_i     <= 1'b1;

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
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0001), .mc_awlen(8'h00));   // 1st
                mc_aw_transfer(.mc_awid(5'h01), .mc_awaddr(32'h3100_0000), .mc_awlen(8'h04));   // 2nd
                mc_aw_transfer(.mc_awid(5'h02), .mc_awaddr(32'h3100_0001), .mc_awlen(8'h03));   // 3rd
                mc_aw_transfer(.mc_awid(5'h03), .mc_awaddr(32'h3100_0002), .mc_awlen(8'h06));   // 4th
                aclk_cl;
                mc_awvalid_i <= 1'b0;

                repeat(20) aclk_cl;

                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0000), .mc_awlen(8'h00));   // 5th
                aclk_cl;
                mc_awvalid_i <= 1'b0;

                repeat(2_200_000) aclk_cl;

                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0000), .mc_awlen(8'h00));   // 6th
                aclk_cl;
                mc_awvalid_i <= 1'b0;
            end
            begin   : W_chn
                // 1st
                mc_w_transfer(.mc_wdata(8'h2C), .mc_wlast(1'b1));
                // 2nd
                mc_w_transfer(.mc_wdata(8'b0000_0010), .mc_wlast(1'b0));    // HW_RST
                mc_w_transfer(.mc_wdata(8'b0001_0000), .mc_wlast(1'b0));    // 1 CMD - 4 DAT
                mc_w_transfer(.mc_wdata(8'b0000_0100), .mc_wlast(1'b0));    // 1 CMD - 1 DAT
                mc_w_transfer(.mc_wdata(8'b0000_1000), .mc_wlast(1'b0));    // 1 CMD - 2 DAT
                mc_w_transfer(.mc_wdata(8'b0000_0000), .mc_wlast(1'b1));    // 1 CMD - 0 DAT
                // 3rd
                mc_w_transfer(.mc_wdata(8'h11), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h22), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h33), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h44), .mc_wlast(1'b1));
                // 4th                
                mc_w_transfer(.mc_wdata(8'h10), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h11), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h12), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h13), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h20), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h30), .mc_wlast(1'b0));
                mc_w_transfer(.mc_wdata(8'h31), .mc_wlast(1'b1));
                // 5th
                mc_w_transfer(.mc_wdata(8'b0000_0001), .mc_wlast(1'b1));    // Turn into CONF mode
                // 6th
                mc_w_transfer(.mc_wdata(8'b0000_0010), .mc_wlast(1'b1));    // Turn into CONF mode
                aclk_cl;
                mc_wvalid_i <= 1'b0;
            end
            begin   : AR_chn
                repeat(20) begin
                    aclk_cl;
                end
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3100_0000), .mc_arlen(8'h02));
                aclk_cl;
                mc_arvalid_i <= 1'b0;
            end
        join_none
    end
    initial begin : DMA_AXI4
        localparam TX_PER_TXN = 2400;
        int tx_cnt;
        int byte_cnt;
        bit [DMA_DATA_W-1:0] dma_wdata;
        #(`RST_DLY_START + `RST_DUR + 1);
        fork
            begin : DMA_AW
                m_aw_transfer(.m_awid(5'h00), .m_awaddr(32'h2000_0000));
                aclk_cl;
                m_awvalid_i <= 1'b0;
            end
            begin : DMA_W
                for (tx_cnt=0; tx_cnt < TX_PER_TXN; tx_cnt++) begin
                    for (byte_cnt = 0; byte_cnt < (DMA_DATA_W/8); byte_cnt++) begin
                        dma_wdata[8*(byte_cnt+1)-1-:8] = (byte_cnt%2 == 0) ? '1 : '0;
                    end
                    m_w_transfer(.m_wdata(dma_wdata), .m_wlast((tx_cnt==(TX_PER_TXN-1))));
                end
                aclk_cl;
                m_wvalid_i <= 1'b0;
            end
        join_none
    end

    /* DeepCode */
    task automatic mc_aw_transfer(
        input [MST_ID_W-1:0]            mc_awid,
        input [ADDR_W-1:0]              mc_awaddr,
        input [TRANS_DATA_LEN_W-1:0]    mc_awlen
    );
        aclk_cl;
        mc_awid_i            <= mc_awid;
        mc_awaddr_i          <= mc_awaddr;
        mc_awlen_i           <= mc_awlen;
        mc_awvalid_i         <= 1'b1;
        // Handshake occur
        wait(mc_awready_o == 1'b1); #0.1;
    endtask
    task automatic mc_w_transfer (
        input [MC_DATA_W-1:0]   mc_wdata,
        input                   mc_wlast
    );
        aclk_cl;
        mc_wdata_i          <= mc_wdata;
        mc_wlast_i          <= mc_wlast;
        mc_wvalid_i         <= 1'b1;
        // Handshake occur
        wait(mc_wready_o == 1'b1); #0.1;
    endtask
    task automatic mc_ar_transfer(
        input [MST_ID_W-1:0]            mc_arid,
        input [ADDR_W-1:0]              mc_araddr,
        input [TRANS_DATA_LEN_W-1:0]    mc_arlen
    );
        aclk_cl;
        mc_arid_i            <= mc_arid;
        mc_araddr_i          <= mc_araddr;
        mc_arlen_i           <= mc_arlen;
        mc_arvalid_i         <= 1'b1;
        // Handshake occur
        wait(mc_arready_o == 1'b1); #0.1;
    endtask

    /* DMA task */
    task automatic m_aw_transfer(
        input [MST_ID_W-1:0]    m_awid,
        input [ADDR_W-1:0]      m_awaddr
    );
        aclk_cl;
        m_awid_i            <= m_awid;
        m_awaddr_i          <= m_awaddr;
        m_awvalid_i         <= 1'b1;
        // Handshake occur
        wait(m_awready_o == 1'b1); #0.1;
    endtask
    task automatic m_w_transfer (
        input [DMA_DATA_W-1:0]  m_wdata,
        input                   m_wlast
    );
        aclk_cl;
        m_wdata_i           <= m_wdata;
        m_wvalid_i          <= 1'b1;
        m_wlast_i           <= m_wlast;
        // Handshake occur
        wait(m_wready_o == 1'b1); #0.1;
    endtask

    task automatic aclk_cl;
        @(posedge clk);
        #0.05; 
    endtask
endmodule