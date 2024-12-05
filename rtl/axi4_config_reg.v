// Address region
//      Register name           |       Adress
// -----------------------------|----------------
// DBI STATUS REG               |   32'h3000_0000
// START COLUMN REG             |   32'h3000_0004
// END COLUMN REG               |   32'h3000_0008
// START ROW REG                |   32'h3000_000C
// END ROW REG                  |   32'h3000_000F
module axi4_config_reg
#(
    // AXI4 Interface
    parameter BASE_ADDR         = 32'h3000_0000,    // Memory mapping - BASE
    parameter CONF_OFFSET       = 32'h04,           // Memory mapping - OFFSET
    parameter DATA_W            = 8,
    parameter ADDR_W            = 32,
    parameter MST_ID_W          = 5,
    parameter TRANS_DATA_LEN_W  = 8,
    parameter TRANS_DATA_SIZE_W = 3,
    parameter TRANS_RESP_W      = 2,
    // IP Configuration
    parameter CONF_ADDR_W       = 4,
    parameter CONF_DATA_W       = 8
)
(   
    // Input declaration
    // -- Global 
    input                       clk,
    input                       rst_n,
    
    // -- to AXI4 Master
    // -- -- AW channel
    input   [MST_ID_W-1:0]      m_awid_i,
    input   [ADDR_W-1:0]        m_awaddr_i,
    input                       m_awvalid_i,
    // -- -- W channel
    input   [DATA_W-1:0]        m_wdata_i,
    input                       m_wvalid_i,
    // -- -- B channel
    input                       m_bready_i,
    // -- -- AR channel
    input   [MST_ID_W-1:0]      m_arid_i,
    input   [ADDR_W-1:0]        m_araddr_i,
    input                       m_arvalid_i,
    // -- -- R channel
    input                       m_rready_i,
    // Output declaration
    // -- -- AW channel
    output                      m_awready_o,
    // -- -- W channel
    output                      m_wready_o,
    // -- -- B channel
    output  [TRANS_RESP_W-1:0]  m_bresp_o,
    output                      m_bvalid_o,
    // -- -- AR channel
    output                      m_arready_o,
    // -- -- R channel 
    output  [DATA_W-1:0]        m_rdata_o,
    output  [TRANS_RESP_W-1:0]  m_rresp_o,
    output                      m_rvalid_o,
    // -- -- Configuration 
    output  [CONF_DATA_W-1:0]   addr_soft_rst_o,
    output  [CONF_DATA_W-1:0]   addr_disp_on_o,
    output  [CONF_DATA_W-1:0]   addr_col_o,
    output  [CONF_DATA_W-1:0]   addr_row_o,
    output  [CONF_DATA_W-1:0]   addr_mem_wr_o,
    output  [CONF_DATA_W-1:0]   status_o,
    output  [CONF_DATA_W-1:0]   cmd_s_col_o,
    output  [CONF_DATA_W-1:0]   cmd_e_col_o,
    output  [CONF_DATA_W-1:0]   cmd_s_row_o,
    output  [CONF_DATA_W-1:0]   cmd_e_row_o
);
    // Local parameters 
    localparam CONF_ADDR_NUM    = CONF_ADDR_W<<1;
    localparam CONF_OFFSET_W    = $clog2(CONF_OFFSET);
    localparam AW_INFO_W        = MST_ID_W + ADDR_W;
    localparam W_INFO_W         = DATA_W;
    localparam B_INFO_W         = TRANS_RESP_W;
    localparam AR_INFO_W        = MST_ID_W + ADDR_W;
    localparam R_INFO_W         = DATA_W + TRANS_RESP_W;
    
    // Internal variables 
    genvar conf_idx;
    // Internal signal
    // -- wire
    // -- -- AXI4 interface
    wire [AW_INFO_W-1:0]        bwd_aw_info;
    
    wire [R_INFO_W-1:0]         bwd_r_info;
    wire [DATA_W-1:0]           bwd_rdata;
    wire [TRANS_RESP_W-1:0]     bwd_rresp;
    wire                        bwd_r_rdy;
    wire [R_INFO_W-1:0]         fwd_r_info;
    
    wire [B_INFO_W-1:0]         bwd_b_info;
    wire                        bwd_b_vld;
    wire                        bwd_b_rdy;
    
    wire [AW_INFO_W-1:0]        bwd_ar_info;
    wire [AW_INFO_W-1:0]        fwd_ar_info;
    wire [MST_ID_W-1:0]         fwd_arid;
    wire [ADDR_W-1:0]           fwd_araddr;
    wire                        fwd_ar_vld;
    
    wire [AW_INFO_W-1:0]        fwd_aw_info;
    wire [MST_ID_W-1:0]         fwd_awid;
    wire [ADDR_W-1:0]           fwd_awaddr;
    wire                        fwd_aw_vld;
    wire                        fwd_aw_rdy;
    
    wire [W_INFO_W-1:0]         fwd_wdata;
    wire                        fwd_w_vld;
    wire                        fwd_w_rdy;
    // -- -- Config function
    wire [CONF_ADDR_NUM-1:0]    awaddr_map_vld;
    wire [CONF_ADDR_NUM-1:0]    araddr_map_vld;
    wire                        config_wr_en;
    // -- reg
    reg  [DATA_W-1:0]           ip_config_reg       [0:CONF_ADDR_NUM-1];
    
    // Internal module
    // -- AW channel buffer 
    skid_buffer #(
        .SBUF_TYPE(2),          // Light-weight
        .DATA_WIDTH(AW_INFO_W)
    ) aw_chn_buf (
        .clk        (clk),
        .rst_n      (rst_n),
        .bwd_data_i (bwd_aw_info),
        .bwd_valid_i(m_awvalid_i), 
        .fwd_ready_i(fwd_aw_rdy), 
        .fwd_data_o (fwd_aw_info),
        .bwd_ready_o(m_awready_o), 
        .fwd_valid_o(fwd_aw_vld)
    );
    // -- W channel buffer 
    skid_buffer #(
        .SBUF_TYPE(2),          // Light-weight
        .DATA_WIDTH(W_INFO_W)
    ) w_chn_buf (
        .clk        (clk),
        .rst_n      (rst_n),
        .bwd_data_i (m_wdata_i),
        .bwd_valid_i(m_wvalid_i), 
        .fwd_ready_i(fwd_w_rdy), 
        .fwd_data_o (fwd_wdata),
        .bwd_ready_o(m_wready_o), 
        .fwd_valid_o(fwd_w_vld)
    );
    // -- B channel buffer 
    skid_buffer #(
        .SBUF_TYPE(2),          // Light-weight
        .DATA_WIDTH(B_INFO_W)
    ) b_chn_buf (
        .clk        (clk),
        .rst_n      (rst_n),
        .bwd_data_i (bwd_b_info),
        .bwd_valid_i(bwd_b_vld), 
        .fwd_ready_i(m_bready_i), 
        .fwd_data_o (m_bresp_o),
        .bwd_ready_o(bwd_b_rdy), 
        .fwd_valid_o(m_bvalid_o)
    );
    // -- AR channel buffer 
    skid_buffer #(
        .SBUF_TYPE(2),          // Light-weight
        .DATA_WIDTH(AR_INFO_W)
    ) ar_chn_buf (
        .clk        (clk),
        .rst_n      (rst_n),
        .bwd_data_i (bwd_ar_info),
        .bwd_valid_i(m_arvalid_i), 
        .fwd_ready_i(bwd_r_rdy), 
        .fwd_data_o (fwd_ar_info),
        .bwd_ready_o(m_arready_o), 
        .fwd_valid_o(fwd_ar_vld)
    );
    // -- R channel buffer 
    skid_buffer #(
        .SBUF_TYPE(2),          // Light-weight
        .DATA_WIDTH(R_INFO_W)
    ) r_chn_buf (
        .clk        (clk),
        .rst_n      (rst_n),
        .bwd_data_i (bwd_r_info),
        .bwd_valid_i(fwd_ar_vld), 
        .fwd_ready_i(m_rready_i), 
        .fwd_data_o (fwd_r_info),
        .bwd_ready_o(bwd_r_rdy), 
        .fwd_valid_o(m_rvalid_o)
    );
    
    // Combination logic
    
    output  [CONF_DATA_W-1:0]   addr_soft_rst_o,
    output  [CONF_DATA_W-1:0]   addr_disp_on_o,
    output  [CONF_DATA_W-1:0]   addr_col_o,
    output  [CONF_DATA_W-1:0]   addr_row_o,
    output  [CONF_DATA_W-1:0]   addr_mem_wr_o,
    output  [CONF_DATA_W-1:0]   status_o,
    output  [CONF_DATA_W-1:0]   cmd_s_col_o,
    output  [CONF_DATA_W-1:0]   cmd_e_col_o,
    output  [CONF_DATA_W-1:0]   cmd_s_row_o,
    output  [CONF_DATA_W-1:0]   cmd_e_row_o
    assign addr_soft_rst_o  = ip_config_reg[8'h00];
    assign addr_disp_on_o   = ip_config_reg[8'h01];
    assign addr_col_o       = ip_config_reg[8'h02];
    assign addr_row_o       = ip_config_reg[8'h03];
    assign addr_mem_wr_o    = ip_config_reg[8'h04];
    assign status_o         = ip_config_reg[8'h05];
    assign cmd_s_col_o      = ip_config_reg[8'h06];
    assign cmd_e_col_o      = ip_config_reg[8'h07];
    assign cmd_s_row_o      = ip_config_reg[8'h08];
    assign cmd_e_row_o      = ip_config_reg[8'h09];
    assign {m_rresp_o, m_rdata_o} = fwd_r_info;
    generate 
    for(conf_idx = 0; conf_idx < CONF_ADDR_NUM; conf_idx = conf_idx + 1) begin
        assign awaddr_map_vld[conf_idx] = ~|(fwd_awaddr ^ (BASE_ADDR+conf_idx*CONF_OFFSET));
        assign araddr_map_vld[conf_idx] = ~|(fwd_araddr ^ (BASE_ADDR+conf_idx*CONF_OFFSET));
    end
    endgenerate
    assign config_wr_en = fwd_w_vld & fwd_aw_vld;
    assign bwd_b_vld    = config_wr_en;
    assign fwd_aw_rdy   = config_wr_en & bwd_b_rdy;
    assign fwd_w_rdy    = config_wr_en & bwd_b_rdy;
    assign bwd_aw_info  = {m_awid_i, m_awaddr_i};
    assign bwd_ar_info  = {m_arid_i, m_araddr_i};
    assign bwd_b_info   = (|awaddr_map_vld) ? 2'b00 : 2'b11;    // 2'b00: SUCCESS || 2'b11: Wrong mapping
    assign bwd_r_info   = {bwd_rresp, bwd_rdata};
    assign bwd_rdata    = ip_config_reg[fwd_araddr[CONF_ADDR_W+CONF_OFFSET_W-1-:CONF_ADDR_W]];
    assign bwd_rresp    = (|araddr_map_vld) ? 2'b00 : 2'b11;
    assign {fwd_arid, fwd_araddr} = fwd_ar_info;
    assign {fwd_awid, fwd_awaddr} = fwd_aw_info;
    // Flip-flop
    generate 
    for(conf_idx = 0; conf_idx < CONF_ADDR_NUM; conf_idx = conf_idx + 1) begin
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            ip_config_reg[conf_idx] <= {DATA_W{1'b0}};
        end
        else if(awaddr_map_vld[conf_idx] & config_wr_en) begin
            ip_config_reg[conf_idx] <= fwd_wdata;
        end
    end
    end
    endgenerate
    
endmodule