module triangle (clk, reset, nt, xi, yi, busy, po, xo, yo);
  input clk, reset, nt;
  input [2:0] xi, yi;
  output reg busy, po;
  output reg [2:0] xo, yo;
  
  reg signed [3:0] x1,y1,x2,y2,x3,y3,xc,yc;
  reg [2:0] cs,ns;
 
  wire signed [7:0] test;
  
  parameter Reset = 3'd0;
  parameter Read_data_1 = 3'd1;
  parameter Read_data_2 = 3'd2;
  parameter Read_data_3 = 3'd3;
  parameter Result = 3'd4;
  parameter Done = 3'd5;
  
  assign test = (xc+1-x2)*(y3-y2)-(x3-x2)*(yc-y2);
  
  always@(posedge clk, posedge reset)begin
	if(reset) cs <= Reset;
	else cs <= ns;
  end
  
  always@(*)begin
	case(cs)
		Reset : ns = Read_data_1;
		Read_data_1 : ns =Read_data_2;
		Read_data_2 : ns = Read_data_3;
		Read_data_3 : ns = Result;
		Result : ns = (yc == y3) ? Done : Result;
		Done : ns = (nt) ? Read_data_1 : Done;
		default : ns =Done;
	endcase
  end
  
  always@(posedge clk)begin
	case(cs)
		Reset : begin
			busy <= 0;
			po <= 0;
			xo <= 0;
			yo <= 0;
			x1 <= {1'b0,xi};
            y1 <= {1'b0,yi};
		end
		Read_data_1 : begin
			x2 <= {1'b0,xi};
            y2 <= {1'b0,yi};
		end
		Read_data_2 : begin
			x3 <= {1'b0,xi};
            y3 <= {1'b0,yi};
			busy <= 1;
		end
		Read_data_3 : begin
			xc <= x1;
			yc <= y1;
		end
		Result : begin
		    po <= 1;
			xo <= xc[2:0];
			yo <= yc[2:0];
			if(test > 0)begin // in the right side of the line
				xc <= x1;
				yc <= yc+1;
			end
			else begin // in the left side of the line 
				xc <= xc+1;
				yc <= yc;
			end
		end
		Done : begin
			busy <= 0;
			po <= 0;
			xo <= 0;
			yo <= 0;
			x1 <= {1'b0,xi};
            y1 <= {1'b0,yi};
		end
		default : begin
			busy <= 0;
			po <= 0;
			xo <= 0;
			yo <= 0;
		end
	endcase
  end
endmodule
