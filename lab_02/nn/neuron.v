module lab5

(
	input en,
    input clk,
    input rst_n,
    output [4 - 1 : 0] Snext,
    output done
);
	reg [4 * 3 - 1 : 0] Scurr= {4'b0001, 4'b0010, 4'b0011};
	reg [4 * 3 - 1 : 0] W  ={4'b0010, 4'b0010, 4'b0010};
	
	
	neuron (
		.en(en),
		.clk(clk),
		.rst_n(rst_n),
		.Scurr(Scurr),
		.W(W),
		.Snext(Snext),
		.done(done)
	);

	
endmodule

module neuron
(
    input en,
    input clk,
    input rst_n,
    input [SIZE * N - 1 : 0] Scurr,   
    input [SIZE * N - 1 : 0] W,
    output [SIZE - 1 : 0] Snext,
    output done
);
    parameter N = 3;
    parameter SIZE = 4;

    reg [SIZE - 1 : 0] sum = 'd0;
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
		begin
			if(en)
			begin
				if(counter === N)
				begin
					counter <= 'd0;
					saveReg <= 1'b1;
					Snextreg <= (|sum) ? {{SIZE - 1 {sum[SIZE-1]}}, 1'b1} : 'd0;
				end
				else
				begin
					if(counter === 'd0)
					begin
						Scurrreg <= Scurr;
						Wreg <= W;
						saveReg <= 1'b0;
						counter <= counter + 1;
					end
					else
					begin
						Wreg <= Wreg >> SIZE;
						Scurrreg <= Scurrreg >> SIZE;
						saveReg <= 1'b0;
						counter <= counter + 1;
					end
				end
			end
		end
	end
	
    always @(posedge clk or negedge rst_n)
    begin
		if(!rst_n)
		begin
			sum <= 'b0;
			doneReg <= 1'b0;
		end
		else
		begin
			if (!counter) 
			begin
				sum = 'd0;
			end
			else
			begin
				sum = sum + Wreg[SIZE-1:0] * Scurrreg[SIZE-1:0];
			end
			
			if(saveReg)
				doneReg = 1'b1;
			else
				doneReg = 1'b0;
		end
    end


endmodule