// Baud generator
// Copyright (c) 2010 Dwayne C. Litzenberger <dlitz@dlitz.net>

`ifndef BAUDGEN_V
`define BAUDGEN_V

// See the technique described here: http://www.fpga4fun.com/SerialInterface2.html
// 50 MHz / (4*115200) Hz = 50 MHz / 460800 Hz = 108.50694444444444
// 16384 / 151 = 108.50331125827815
// 16384 is 14 bits

module baudgen (
  input         clock_in,    // positive edge-triggered system clock
  input         n_reset_in,  // active low async reset
  input  [11:0] rate_in,     // number that the 460.8 kHz clock will be divided by, minus 1 (0: 460.8 kHz, 1: 230.4 kHz, 3: 115.2 kHz, ...)
  output        tick_out
);


//
// Stage 1: Divide the system clock down to 460.8 kHz
//

reg [14:0] s1_count;    // Stage 1 counter
wire s1_divided = s1_count[14];    // 230.4 kHz square wave with 50% duty cycle
reg s1_tick;                      // 460.8 kHz - pulses at the rising and falling edges of s1_divided
reg s1_divided_prev;

always @(posedge clock_in, negedge n_reset_in) begin
  if (!n_reset_in) begin
    s1_count <= 0;
  end
  else begin
    s1_count <= s1_count[13:0] + 151;
  end
end

always @(posedge clock_in, negedge n_reset_in) begin
  if (!n_reset_in) begin
    s1_tick <= 0;
    s1_divided_prev <= 0;
  end
  else if (s1_divided_prev != s1_divided) begin
    s1_tick <= 1;
    s1_divided_prev <= s1_divided;
  end
  else begin
    s1_tick <= 0;
    s1_divided_prev <= s1_divided;
  end
end

//
// Stage 2: Divide s1_tick down by the amount specified by rate_in
//

reg [11:0] s2_count;
assign tick_out = (s1_tick && s2_count == 0);
always @(posedge clock_in, negedge n_reset_in) begin
  if (!n_reset_in) begin
    s2_count <= 0;
  end
  else if (s1_tick && s2_count == rate_in) begin
    s2_count <= 0;
  end
  else if (s1_tick) begin
    s2_count <= s2_count + 1;
  end
end

endmodule

`endif // BAUDGEN_V
