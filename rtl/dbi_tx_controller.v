module dbi_tx_controller 
#(
    // AXI4 Interface
    // -- DMA
    parameter DMA_DATA_W        = 256,
    parameter ADDR_W            = 32,
    // -- Master Configuration BUS 
    parameter MC_DATA_W         = 8,
    // -- Common
    parameter MST_ID_W          = 5,
    parameter TRANS_DATA_LEN_W  = 8,
    parameter TRANS_DATA_SIZE_W = 3,
    parameter TRANS_RESP_W      = 2,
    // DBI Interface
    parameter DBI_IF_D_W        = 8
    
) (
    // Input declaration
    input                       clk,
    input                       rst_n,
    // -- AXI4 Master DMA
    // -- -- AW channel
    input   [MST_ID_W-1:0]      m_awid_i,
    input   [ADDR_W-1:0]        m_awaddr_i,
    input                       m_awvalid_i,
    // -- -- W channel
    input   [DMA_DATA_W-1:0]    m_wdata_i,
    input                       m_wlast_i,
    input                       m_wvalid_i,
    // -- -- B channel
    input                       m_bready_i,
    // -- AXI4 Master configuration line (master)
    // -- -- AW channel
    input   [MST_ID_W-1:0]      mc_awid_i,
    input   [ADDR_W-1:0]        mc_awaddr_i,
    input                       mc_awvalid_i,
    // -- -- W channel
    input   [MC_DATA_W-1:0]     mc_wdata_i,
    input                       mc_wlast_i,
    input                       mc_wvalid_i,
    // -- -- B channel
    input                       mc_bready_i,
    
    // Output declaration
    // -- AXI4 DMA (master)
    // -- -- AW channel
    output                      m_awready_o,
    // -- -- W channel
    output                      m_wready_o,
    // -- -- B channel
    output  [MST_ID_W-1:0]      m_bid_o,
    output  [TRANS_RESP_W-1:0]  m_bresp_o,
    output                      m_bvalid_o,
    // -- AXI4 Master configuration line
    // -- -- AW channel
    output                      mc_awready_o,
    // -- -- W channel
    output                      mc_wready_o,
    // -- -- B channel
    output  [TRANS_RESP_W-1:0]  mc_bresp_o,
    output                      mc_bvalid_o,

    // -- DBI TX interface
    output                      dbi_csx_o,
    output                      dbi_resx_o,
    output                      dbi_rdx_o,
    output                      dbi_wrx_o,
    inout   [DBI_IF_D_W-1:0]    dbi_d_o 
);

    // Internal module
    // -- AXI4 configuration registers file
    axi4_config_reg #(

    ) acr (

    );

    axi4_fifo #(

    ) af (

    );

    dbi_tx_fsm #(

    ) dtf (

    );

    dbi_tx_phy #(

    ) dtp (

    );

endmodule