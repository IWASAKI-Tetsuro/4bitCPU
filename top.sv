module top(
  input logic pin_clock,
  input logic pin_n_reset,
  input logic [3:0] pin_switch,
  output logic [7:0] pin_segment,
  output logic clk
);
 logic [23:0] count;
 logic [3:0] addr;
 logic [3:0] led;
 logic [7:0] data;
 assign pin_segment = ~(LED_MAP1(led));

  function [7:0] LED_MAP1(input [3:0] led);
    casex (led)
      4'b0000 : LED_MAP1 = 8'b11111100;
      4'b0001 : LED_MAP1 = 8'b01100000;
      4'b0010 : LED_MAP1 = 8'b11011010;
      4'b0011 : LED_MAP1 = 8'b11110010;
      4'b0100 : LED_MAP1 = 8'b01100110;
      4'b0101 : LED_MAP1 = 8'b10110110;
      4'b0110 : LED_MAP1 = 8'b10111110;
      4'b0111 : LED_MAP1 = 8'b11100000;
      4'b1000 : LED_MAP1 = 8'b11111110;
      4'b1001 : LED_MAP1 = 8'b11110110;
      4'b1010 : LED_MAP1 = 8'b11101110;
      4'b1011 : LED_MAP1 = 8'b00111110;
      4'b1100 : LED_MAP1 = 8'b00011010;
      4'b1101 : LED_MAP1 = 8'b01111010;
      4'b1110 : LED_MAP1 = 8'b10011110;
      4'b1111 : LED_MAP1 = 8'b10001110;
    endcase
  endfunction
always_ff@(posedge pin_clock or negedge pin_n_reset) begin
   if(~pin_n_reset) begin
   count[23:0] <= 0;
	clk <= 0;
    end
    else if(count == 12000000 - 1) begin
      count <= 0;
      clk <= ~clk;
    end
    else begin
    count <= count + 1;
    clk <= clk;
    end
 end   

 
 cpu cpu(.clk, .n_reset(pin_n_reset), .addr, .data, .switch(pin_switch), .led(led));
 rom rom(.addr, .data);

endmodule
module cpu(
  input  logic clk,
  input  logic n_reset,
  output logic [3:0] addr,
  input  logic [7:0] data,
  input  logic [3:0] switch,
  output logic [3:0] led
);

  logic [3:0] a, next_a;
  logic [3:0] b, next_b;
  logic cf, next_cf;
  logic [3:0] ip, next_ip;
  logic [3:0] out, next_out;
  logic [3:0] opecode, imm;
  assign opecode = data[7:4]; 
  assign imm     = data[3:0]; 
  assign addr    = ip;
  assign led     = out;
  
  always_ff @(posedge clk or negedge n_reset) begin
    if (~n_reset) begin
      a   <= 0;
      b   <= 0;
      cf  <= 0;
      ip  <= 0;
      out <= 0;
    end else begin
      a   <= next_a;
      b   <= next_b;
      cf  <= next_cf;
      ip  <= next_ip;
      out <= next_out;
    end
  end

  always_comb begin
  
  next_a   = a; 
  next_b   = b;
  next_cf  = 0;
  next_ip  = ip + 1; 
  next_out = out;
  unique case (opecode)
		4'b0000: begin // NOP
		 ;
		end
      4'b0001: begin // A += IMM
			{next_cf, next_a} = a + imm;
		end		
		4'b0010: begin // A = B
			next_a   = b;
		end	
		4'b0011: begin // A = SWITCH
			next_a   = switch;
		end
		4'b0100: begin // A = IMM
			next_a   = imm;
		end
		4'b0101: begin // B += IMM
			{next_cf, next_b} = b + imm;
		end
      4'b0110: begin // B = A
			next_b   = a;
		end		
		4'b0111: begin // B = SWITCH
			next_b   = switch;
		end	
		4'b1000: begin // B = IMM
			next_b   = imm;
		end
		4'b1001: begin // display A
			next_out = a;
		end
		4'b1010: begin // display B
			next_out = b;
		end
		4'b1011: begin // display IMM
			next_out = imm;
		end
		4'b1100: begin // A = A + B
			{next_cf, next_a} = a + b;
		end
		4'b1100: begin // B = A + B
			{next_cf, next_b} = a + b;
		end
		4'b1110: begin // if(cf) jump to addrress
			next_ip  = (cf ? ip + 1 : imm);
		end
		4'b1111: begin // jump to addrress
			next_ip  = imm;
		end
		default: ;
    endcase
  end
endmodule

module rom(
  input  logic [3:0] addr,
  output logic [7:0] data
);
  always_comb begin
      case (addr) //ここにプログラムを書く
      4'b0000: data = 8'b1011_1100;
      4'b0001: data = 8'b0100_0011;
      4'b0010: data = 8'b1001_0000;
      4'b0011: data = 8'b1000_0110;
      4'b0100: data = 8'b1010_0000;
      4'b0101: data = 8'b0001_1100;
      4'b0110: data = 8'b1001_0000;
		default: data = 8'b0000_0000;
    endcase
  end
endmodule
