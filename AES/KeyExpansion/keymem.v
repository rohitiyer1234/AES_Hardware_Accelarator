module keymem(
    input clk,
    input reset,
    input w_en,
    input [3:0] raddr_read,
    input [3:0] waddr,
    input [127:0] wkey,
    output [127:0] rkey_read,
    output wire all_valid_bits
);

	reg [14:0] valid_bits;
	reg [127:0] mem [0:14];

	integer i;
	
	assign rkey_read = (all_valid_bits && valid_bits[raddr_read]) ? mem[raddr_read] : 128'b0;		// Setting read value to high impedance if the valid bit is invalid
	
    assign all_valid_bits = &valid_bits[10:0];                                  // Signal to indicate read can be done

	always @(posedge clk) begin
	    if(reset) begin
	        for(i=0; i<15; i=i+1) begin
	            valid_bits[i] <= 0;
	            mem[i] <= 0;
	        end
	    end
	   
	    else begin
	        if(w_en) begin
	            mem[waddr] <= wkey;
	            valid_bits[waddr] <= 1; 
	        end
	    end
	end
endmodule
