`timescale 1ns/1ps

module tb_aes_axi;

    reg clk;
    reg resetn;

    // AXI signals
    reg  [31:0] awaddr;
    reg         awvalid;
    wire        awready;

    reg  [31:0] wdata;
    reg  [3:0]  wstrb;
    reg         wvalid;
    wire        wready;

    wire [1:0]  bresp;
    wire        bvalid;
    reg         bready;

    reg  [31:0] araddr;
    reg         arvalid;
    wire        arready;

    wire [31:0] rdata;
    wire [1:0]  rresp;
    wire        rvalid;
    reg         rready;

    always #5 clk = ~clk;

    aes_axi_top dut (
        .clk(clk),
        .resetn(resetn),

        .s_axi_awaddr (awaddr),
        .s_axi_awvalid(awvalid),
        .s_axi_awready(awready),

        .s_axi_wdata  (wdata),
        .s_axi_wstrb  (wstrb),
        .s_axi_wvalid (wvalid),
        .s_axi_wready (wready),

        .s_axi_bresp  (bresp),
        .s_axi_bvalid (bvalid),
        .s_axi_bready (bready),

        .s_axi_araddr (araddr),
        .s_axi_arvalid(arvalid),
        .s_axi_arready(arready),

        .s_axi_rdata  (rdata),
        .s_axi_rresp  (rresp),
        .s_axi_rvalid (rvalid),
        .s_axi_rready (rready)
    );

    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            awaddr  = addr;
            awvalid = 1;
            wdata   = data;
            wstrb   = 4'hF;
            wvalid  = 1;
            bready  = 1;

            while (!(awready && wready))
                @(posedge clk);

            awvalid = 0;
            wvalid  = 0;

            while (!bvalid)
                @(posedge clk);

            bready = 0;
        end
    endtask

    task axi_read;
        input  [31:0] addr;
        output [31:0] data;
        begin
            @(posedge clk);
            araddr  = addr;
            arvalid = 1;
            rready  = 1;

            while (!arready)
                @(posedge clk);

            arvalid = 0;

            while (!rvalid)
                @(posedge clk);

            data = rdata;
            rready = 0;
        end
    endtask

    reg [31:0] rd;

    initial begin
        clk = 0;
        resetn = 0;

        awaddr = 0; awvalid = 0;
        wdata  = 0; wvalid  = 0;
        bready = 0;
        araddr = 0; arvalid = 0;
        rready = 0;

        #50 resetn = 1;

        // IV
        axi_write(32'h30, 32'h00010203);
        axi_write(32'h34, 32'h04050607);
        axi_write(32'h38, 32'h08090A0B);
        axi_write(32'h3C, 32'h0C0D0E0F);

        // DATA IN
        axi_write(32'h20, 32'hAAAAAAAA);
        axi_write(32'h24, 32'hBBBBBBBB);
        axi_write(32'h28, 32'hCCCCCCCC);
        axi_write(32'h2C, 32'hDDDDDDDD);

        // MODE = CBC
        axi_write(32'h0C, 32'h1);

        // CTRL1 = START + ENCRYPT
        axi_write(32'h00, 32'b01);

        // Poll STATUS
        repeat (40) begin
            axi_read(32'h08, rd);
            if (rd[1]) begin
                $display("DONE");
                disable wait_done;
            end
            #20;
        end
        wait_done:

        // READ OUTPUT
        axi_read(32'h2C, rd); $display("OUT0 = %h", rd);
        axi_read(32'h30, rd); $display("OUT1 = %h", rd);
        axi_read(32'h34, rd); $display("OUT2 = %h", rd);
        axi_read(32'h38, rd); $display("OUT3 = %h", rd);

        #100;
        $finish;
    end

endmodule
