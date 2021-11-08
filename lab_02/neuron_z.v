module neuron_z
(
    input en,
    input clk,
    input rst_n,
	input [SIZE - 1 : 0] W [image_size-1:0],
	input [SIZE - 1 : 0] img [image_size-1:0],
	output done,
	output [SIZE-1:0] num
);
parameter image_size = 4;
parameter SIZE = 32;

    reg [SIZE - 1 : 0] sum = 'd0;
    reg [SIZE - 1 : 0] counter = 'd0;
    reg doneReg = 'b0;
	 reg saveReg = 'b0;
	 reg [SIZE-1:0] numreg = 'd0;
	

//    integer index, i;

    assign done = doneReg;
	 assign num = numreg;
	 reg [SIZE-1:0] tmp_res [image_size-1:0];
    genvar i;
    generate 
        for (i = 0; i < image_size; i = i + 1)
        begin : generate_block_identifier

            one_mul one
            (   
                .W(W [i]),
                .img(img[i]),
                .out(tmp_res[i])
            );
        end
    endgenerate
	
	reg [SIZE-1:0] sums [image_size-1:0];
genvar j;
always @(posedge clk or negedge rst_n) begin
sums[0] = tmp_res[0];
end
generate
        for (j = 1; j < image_size; j = j + 1)
        begin : generate_block_identifier1
            reduce_sum(tmp_res[j], sums[j-1], sums[j]);
        end
endgenerate
always @(negedge clk or posedge rst_n) begin
numreg = sums[image_size-1];
end

endmodule

module one_mul
(
input [SIZE - 1 : 0] W,
input [SIZE - 1 : 0] img,
output [SIZE - 1 : 0] out
);
reg [SIZE - 1 : 0] outreg  = 'd0;
assign out = outreg;
parameter image_size = 4;
outreg = W*img + image_size;
endmodule


module reduce_sum
(input [SIZE - 1 : 0] inp,
input [SIZE - 1 : 0] inp1,
output [SIZE - 1 : 0] out);
reg [SIZE - 1 : 0] outreg  = 'd0;
assign out = outreg;
outreg = inp + inp1;
endmodule