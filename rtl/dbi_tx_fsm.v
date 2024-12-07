module dbi_tx_fsm 
#(
    // DBI Interface
    parameter DBI_IF_D_W        = 8
) 
(
    // Input declaration
    input                       clk,
    input                       rst_n,
    // -- To AXI4 Configuration Register
    input                       dbi_tx_start_i,
    input   [DBI_IF_D_W-1:0]    addr_soft_rst_i,
    input   [DBI_IF_D_W-1:0]    addr_disp_on_i,
    input   [DBI_IF_D_W-1:0]    addr_col_i,
    input   [DBI_IF_D_W-1:0]    addr_row_i,
    input   [DBI_IF_D_W-1:0]    addr_mem_wr_i,
    input   [DBI_IF_D_W-1:0]    cmd_s_col_h_i,
    input   [DBI_IF_D_W-1:0]    cmd_s_col_l_i,
    input   [DBI_IF_D_W-1:0]    cmd_e_col_h_i,
    input   [DBI_IF_D_W-1:0]    cmd_e_col_l_i,
    input   [DBI_IF_D_W-1:0]    cmd_s_row_h_i,
    input   [DBI_IF_D_W-1:0]    cmd_s_row_l_i,
    input   [DBI_IF_D_W-1:0]    cmd_e_row_h_i,
    input   [DBI_IF_D_W-1:0]    cmd_e_row_l_i,
    // -- To AXI4 FIFO
    input   [DBI_IF_D_W-1:0]    pxl_d_i,
    input                       pxl_vld_i,
    // -- To DBI TX PHY
    input                       dtp_tx_rdy_i,
    // Output declaration
    // -- To AXI4 FIFO
    output                      pxl_rdy_o,
    // -- To DBI TX PHY
    output  [DBI_IF_D_W-1:0]    dtp_tx_cmd_typ_o,
    output  [DBI_IF_D_W-1:0]    dtp_tx_cmd_dat_o,
    output                      dtp_tx_last_o,
    output                      dtp_tx_vld_o
);
    // Local parameters
    localparam IDLE_ST          = 3'd0;
    localparam DBI_RST_ST       = 3'd1;
    localparam DBI_SET_COL_ST   = 3'd2;
    localparam DBI_SET_ROW_ST   = 3'd3;
    localparam DBI_DISP_ST      = 3'd4;
    localparam DBI_STM_ST       = 3'd5;

    // Internal signal
    // -- wire
    reg     [2:0]   dbi_tx_st_d;
    // -- reg
    reg     [2:0]   dbi_tx_st_q;

    // Combination logic
    always @(*) begin
        dbi_tx_st_d = dbi_tx_st_q;
        case(dbi_tx_st_q) 
            IDLE_ST: begin
                if(dbi_tx_start_o) begin
                    dbi_tx_st_q = DBI_RST_ST;
                    // TODO
                end
            end
            DBI_RST_ST: begin
                
            end
            DBI_SET_COL_ST: begin
                
            end
            DBI_SET_ROW_ST: begin
                
            end
            DBI_DISP_ST: begin
                
            end
            DBI_STM_ST: begin
                
            end
        endcase 
    end
endmodule