module nn
#(SIZE=32, N=3, M=4, K=1)
(
	input en,
    input clk,
    input rst_n,
    output [SIZE * M - 1 : 0] Snext,
	 output [SIZE - 1 : 0] Snext_max,
    output done,
	 output [M - 1: 0] result
);
//	 input [SIZE * N - 1 : 0] Scurr,
//	 input [SIZE * N - 1 : 0] W,
	reg [SIZE * N - 1 : 0] Scurr = {32'd1, -32'd1, 32'd1};
	reg [SIZE * N * M - 1 : 0] W = {
						{ 32'b1, -32'b1, -32'd1},
						{-32'b1,  32'b1,  32'd1},
						{-32'b1, -32'b1,  32'd1},
						{ 32'b1, -32'b1,  32'd1}
						};
	
//	assign act = (Snext <= 0) ? 'b0 :
//						  (Snext < (N*2+1))? Snext*2 : N*2+1;
//	
//	neuron_z #(.SIZE(SIZE), .N(N)) n1z
//	(
//		.en(en),
//		.clk(clk),
//		.rst_n(rst_n),
//		.Scurr(Scurr),
//		.W(W),
//		.b(N),
//		.Snext(Snext),
//		.done(done)
//	);
		
	layer_z #(.SIZE(SIZE), .N(N), .M(M), .K(K)) lz
	(
		.en(en),
		.clk(clk),
		.rst_n(rst_n),
		.Scurr(Scurr),
		.W(W),
		.Snext(Snext),
		.done(done)
	);
	
	argmax #(.SIZE(SIZE), .N(M))
	(
		 .en(en),
		 .clk(clk),
		 .rst_n(rst_n),
		 .Scurr(Snext),   
		 .Snext(Snext_max),
		 .result(result)
	);
	
	
endmodule

module neuron_z
#(SIZE=32, N=3)
(
    input en,
    input clk,
    input rst_n,
    input [SIZE * N - 1 : 0] Scurr,   
    input [SIZE * N - 1 : 0] W,
	 input [SIZE * N - 1 : 0] b,
    output [SIZE - 1 : 0] Snext,
    output done
);

    reg [SIZE - 1 : 0] sum = 'b0;
    reg [SIZE * N - 1 : 0] Scurrreg = 'd0;
    reg [SIZE * N - 1 : 0] Wreg = 'd0;
    reg [SIZE - 1 : 0] counter = 'd0;
    reg [SIZE - 1 : 0] Snextreg = 'd0; 
    reg doneReg = 'b0;
	 reg saveReg = 'b0;

    integer index, i;

    assign Snext = Snextreg;
    assign done = doneReg;


	always @(negedge clk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			counter <= 'd0;
			Snextreg <= 'd0;
			saveReg <= 'b0;
			Scurrreg <= 'b0;
			Wreg <= 'b0;
		end
		else
			if(en)
			begin
				doneReg <= 'b0;
//			   Snextreg <= sum;
				if(counter === N)
				begin
					counter <= 'd0;
					doneReg <= 'b1;
					Snextreg <= sum;
//					Snextreg <= (|sum) ? {{SIZE - 1 {sum[SIZE-1]}}, 1'b1} : 'd0;
				end
				else if(counter === 'd0)
				begin
					Scurrreg <= Scurr;
					Wreg <= W;
					counter <= counter + 1;
				end
				else
				begin
					Wreg <= Wreg >> SIZE;
					Scurrreg <= Scurrreg >> SIZE;
					counter <= counter + 1;
				end
			end
	end
	
    always @(posedge clk or negedge rst_n)
    begin
		if(!rst_n)
		begin
			sum <= 'b0;
		end
		else
		begin
			if (!counter) 
				sum = b;
			else
				sum = sum + Wreg[SIZE-1:0] * Scurrreg[SIZE-1:0];
		end
    end

endmodule

module layer_z
#(SIZE=32, N=3, M=3, K=1)
(
    input en,
    input clk,
    input rst_n,
    input [SIZE * N - 1 : 0] Scurr,   
    input [SIZE * N * M - 1 : 0] W,
    output [SIZE * M - 1 : 0] Snext,
    output done
);
	wire [M - 1 : 0] done_n;
	wire [SIZE * M - 1 : 0] nRes;
	genvar i;
    generate
			for (i=0; i<M; i=i+1) begin: z_layer
				neuron_z #(.SIZE(SIZE), .N(N))
					(
						.en(en),
						.clk(clk),
						.rst_n(rst_n),
						.Scurr(Scurr),
						.W(W[i*SIZE*N +: SIZE*N]),
						.b(N),
						.Snext(nRes[i*SIZE +: SIZE]),
						.done(done_n[i])
					);
				assign Snext[i*SIZE +: SIZE] = (nRes[i*SIZE +: SIZE] <= 0) ? 'b0 :
								 (nRes[i*SIZE +: SIZE] < (N*2+1)) ? nRes[i*SIZE +: SIZE]*K : N*2+1;
			end
	 endgenerate
	assign done = &done_n;
endmodule

module argmax
#(SIZE=32, N=3)
(
    input en,
    input clk,
    input rst_n,
    input [SIZE * N - 1 : 0] Scurr,   
    output [SIZE - 1 : 0] Snext,
	 output reg [N-1:0] result,
    output done
);
	 
	 reg [N-1:0] temp_result;
    reg [SIZE - 1 : 0] sum = 'b0;
    reg [SIZE * N - 1 : 0] Scurrreg = 'd0;
    reg [SIZE - 1 : 0] counter = 'd0;
    reg [SIZE - 1 : 0] Snextreg = 'd0; 
    reg doneReg = 'b0;
	 reg saveReg = 'b0;

    integer index, i;
	
    assign Snext = Snextreg;
    assign done = doneReg;


	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			counter <= 'd0;
			Snextreg <= 'd0;
			saveReg <= 'b0;
			Scurrreg <= 'b0;
		end
		else
			if(en)
			begin
				doneReg <= 'b0;
				if(counter === N+1)
				begin
					counter <= 'd0;
					doneReg <= 'b1;
					result <= temp_result;
					Snextreg <= sum;
				end
				else if(counter === 'd0)
				begin
					Scurrreg <= Scurr;
					counter <= counter + 1;
				end
				else
				begin
					Scurrreg <= Scurrreg >> SIZE;
					counter <= counter + 1;
				end
			end
	end
	
    always @(posedge clk or negedge rst_n)
    begin
		if(!rst_n)
		begin
			sum <= 'b0;
		end
		else
		begin
			if (!counter) 
			begin
				sum = 0;
				temp_result=0;
			end
			else
				if (sum<= Scurrreg[SIZE-1:0])
				begin	
					sum=Scurrreg[SIZE-1:0];
					temp_result = {N{1'b0}};
					temp_result[counter-1] = 1'b1;
				end
		end
    end

endmodule
