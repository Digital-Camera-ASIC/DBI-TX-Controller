`timescale 1ns / 1ps

`define DUT_CLK_PERIOD  2
`define RST_DLY_START   3
`define RST_DUR         9

`define END_TIME        18000000

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
    logic                      mc_awvalid_i;
    logic  [MC_DATA_W-1:0]     mc_wdata_i;
    logic                      mc_wvalid_i;
    logic                      mc_bready_i;
    logic  [MST_ID_W-1:0]      mc_arid_i;
    logic  [ADDR_W-1:0]        mc_araddr_i;
    logic                      mc_arvalid_i;
    logic                      mc_rready_i;
    logic                      m_awready_o;
    logic                      m_wready_o;
    logic  [MST_ID_W-1:0]      m_bid_o;
    logic  [TRANS_RESP_W-1:0]  m_bresp_o;
    logic                      m_bvalid_o;
    logic                      mc_awready_o;
    logic                      mc_wready_o;
    logic  [TRANS_RESP_W-1:0]  mc_bresp_o;
    logic                      mc_bvalid_o;
    logic                      mc_arready_o;
    logic  [MC_DATA_W-1:0]     mc_rdata_o;
    logic  [TRANS_RESP_W-1:0]  mc_rresp_o;
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
        mc_awvalid_i    <= 0;
        
        mc_wdata_i      <= 0;
        mc_wvalid_i     <= 0;
        
        mc_bready_i     <= 1'b1;
        
        mc_arid_i       <= 0;
        mc_araddr_i     <= 0;
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
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0001));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0002));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0003));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0004));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0005));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0006));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0007));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0008));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0009));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_000A));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_000B));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_000C));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_000D));
                mc_aw_transfer(.mc_awid(5'h00), .mc_awaddr(32'h3000_0000));
                aclk_cl;
                mc_awvalid_i <= 1'b0;
            end
            begin   : W_chn
                mc_w_transfer(.mc_wdata(8'h01));
                mc_w_transfer(.mc_wdata(8'h02));
                mc_w_transfer(.mc_wdata(8'h03));
                mc_w_transfer(.mc_wdata(8'h04));
                mc_w_transfer(.mc_wdata(8'h05));
                mc_w_transfer(.mc_wdata(8'h06));
                mc_w_transfer(.mc_wdata(8'h07));
                mc_w_transfer(.mc_wdata(8'h08));
                mc_w_transfer(.mc_wdata(8'h09));
                mc_w_transfer(.mc_wdata(8'h0A));
                mc_w_transfer(.mc_wdata(8'h0B));
                mc_w_transfer(.mc_wdata(8'h0C));
                mc_w_transfer(.mc_wdata(8'h0D));
                mc_w_transfer(.mc_wdata(8'h01));
                aclk_cl;
                mc_wvalid_i <= 1'b0;
            end
            begin   : AR_chn
                repeat(20) begin
                    aclk_cl;
                end
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0005));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0004));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0003));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0002));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0001));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_000D));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_000C));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_000B));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_000A));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0009));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0008));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0007));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0006));
                mc_ar_transfer(.mc_arid(5'h00), .mc_araddr(32'h3000_0000));
                aclk_cl;
                mc_arvalid_i <= 1'b0;
            end
        join_none
    end


    /* DeepCode */
    task automatic mc_aw_transfer(
        input [MST_ID_W-1:0]    mc_awid,
        input [ADDR_W-1:0]      mc_awaddr
    );
        aclk_cl;
        mc_awid_i            <= mc_awid;
        mc_awaddr_i          <= mc_awaddr;
        mc_awvalid_i         <= 1'b1;
        // Handshake occur
        wait(mc_awready_o == 1'b1); #0.1;
    endtask
    task automatic mc_w_transfer (
        input [MC_DATA_W-1:0]   mc_wdata
    );
        aclk_cl;
        mc_wdata_i          <= mc_wdata;
        mc_wvalid_i         <= 1'b1;
        // Handshake occur
        wait(mc_wready_o == 1'b1); #0.1;
    endtask
    task automatic mc_ar_transfer(
        input [MST_ID_W-1:0]    mc_arid,
        input [ADDR_W-1:0]      mc_araddr
    );
        aclk_cl;
        mc_arid_i            <= mc_arid;
        mc_araddr_i          <= mc_araddr;
        mc_arvalid_i         <= 1'b1;
        // Handshake occur
        wait(mc_arready_o == 1'b1); #0.1;
    endtask
    task automatic aclk_cl;
        @(posedge clk);
        #0.05; 
    endtask
endmodule