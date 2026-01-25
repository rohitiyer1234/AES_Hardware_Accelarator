module axi_regs(
    input resetn, clk,
    input wr_en,
    input [31:0] wr_addr,
    input [31:0] wr_data,
    input [3:0] wr_strb,

    input rd_en,
    input [31:0] rd_addr,
    output reg [31:0] rd_data,

    input [31:0] status_reg,
    input [31:0] data_out_mem0,
    input [31:0] data_out_mem1,
    input [31:0] data_out_mem2,
    input [31:0] data_out_mem3,

    output reg [31:0] ctrl_reg1,
    output reg [31:0] ctrl_reg2,
    output reg [31:0] mode_reg,

    output reg [31:0] base_key_reg0,
    output reg [31:0] base_key_reg1,
    output reg [31:0] base_key_reg2,
    output reg [31:0] base_key_reg3,

    output reg [31:0] IV_W0,
    output reg [31:0] IV_W1,
    output reg [31:0] IV_W2,
    output reg [31:0] IV_W3,


    output reg [31:0] data_in_mem0,
    output reg [31:0] data_in_mem1,
    output reg [31:0] data_in_mem2,
    output reg [31:0] data_in_mem3


);

integer i;

always @ (posedge clk) begin
    if (!resetn) begin
        ctrl_reg1 <= 0;
        ctrl_reg2 <= 0;
        mode_reg <= 0;


        base_key_reg0 <= 32'h0;
        base_key_reg1 <= 32'h0;
        base_key_reg2 <= 32'h0;
        base_key_reg3 <= 32'h0;

        data_in_mem0 <= 32'h0;
        data_in_mem1 <= 32'h0;
        data_in_mem2 <= 32'h0;
        data_in_mem3 <= 32'h0;

        IV_W0 <= 32'h0;
        IV_W1 <= 32'h0;
        IV_W2 <= 32'h0;
        IV_W3 <= 32'h0;

    end else if (wr_en) begin
        case (wr_addr[7:0])

            8'h00: ctrl_reg1 <= wr_data;
            8'h04: ctrl_reg2 <= wr_data;
            //8'h08 cant write to status reg, asserted by hardware
            8'h0C: mode_reg <= wr_data;

            8'h10: base_key_reg0 <= wr_data;
            8'h14: base_key_reg1 <= wr_data;
            8'h18: base_key_reg2 <= wr_data;
            8'h1C: base_key_reg3 <= wr_data;

            8'h20: data_in_mem0 <= wr_data;
            8'h24: data_in_mem1 <= wr_data;
            8'h28: data_in_mem2 <= wr_data;
            8'h2C: data_in_mem3 <= wr_data;

            8'h30: IV_W0 <= wr_data;
            8'h34: IV_W1 <= wr_data;
            8'h38: IV_W2 <= wr_data;
            8'h3C: IV_W3 <= wr_data;

        endcase
    end
end

always @ (posedge clk) begin
    if (!resetn)
        rd_data = 32'h0;
    else if (rd_en)begin
    case (rd_addr[7:0] )
        8'h00: rd_data = ctrl_reg1;
        8'h04: rd_data = ctrl_reg2;
        8'h08: rd_data = status_reg;
        8'h0C: rd_data = mode_reg;

        8'h40: rd_data = data_out_mem0;
        8'h44: rd_data = data_out_mem1;
        8'h48: rd_data = data_out_mem2;
        8'h4C: rd_data = data_out_mem3;

        default: rd_data = 32'h0;
    endcase
    end
end
endmodule
