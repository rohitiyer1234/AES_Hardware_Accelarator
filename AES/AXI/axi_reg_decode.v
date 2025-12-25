module axi_reg_decode (
    input  wire        clk,
    input  wire        resetn,

    input  wire        wr_en,
    input  wire [31:0] wr_addr,
    input  wire [31:0] wr_data,

    input  wire        rd_en,
    input  wire [31:0] rd_addr,
    output reg  [31:0] rd_data,

    output reg  [31:0] ctrl_reg,
    output reg  [31:0] mode_reg,
    input  wire [31:0] status_reg,

    output reg  [31:0] key_mem [0:7],
    output reg  [31:0] data_in_mem [0:3],
    input  wire [31:0] data_out_mem [0:3]
);

    integer i;

    always @(posedge clk) begin
        if (!resetn) begin
            ctrl_reg <= 0;
            mode_reg <= 0;
            for (i = 0; i < 8; i = i + 1) key_mem[i] <= 0;
            for (i = 0; i < 4; i = i + 1) data_in_mem[i] <= 0;
        end else if (wr_en) begin
            case (wr_addr[7:0])
                8'h00: ctrl_reg <= wr_data;
                8'h08: mode_reg <= wr_data;

                8'h0C: key_mem[0] <= wr_data;
                8'h10: key_mem[1] <= wr_data;
                8'h14: key_mem[2] <= wr_data;
                8'h18: key_mem[3] <= wr_data;
                8'h1C: key_mem[4] <= wr_data;
                8'h20: key_mem[5] <= wr_data;
                8'h24: key_mem[6] <= wr_data;
                8'h28: key_mem[7] <= wr_data;

                8'h40: data_in_mem[0] <= wr_data;
                8'h44: data_in_mem[1] <= wr_data;
                8'h48: data_in_mem[2] <= wr_data;
                8'h4C: data_in_mem[3] <= wr_data;
            endcase
        end
    end

    always @(*) begin
        case (rd_addr[7:0])
            8'h00: rd_data = ctrl_reg;
            8'h04: rd_data = status_reg;
            8'h08: rd_data = mode_reg;

            8'h80: rd_data = data_out_mem[0];
            8'h84: rd_data = data_out_mem[1];
            8'h88: rd_data = data_out_mem[2];
            8'h8C: rd_data = data_out_mem[3];

            default: rd_data = 32'h0;
        endcase
    end
endmodule
