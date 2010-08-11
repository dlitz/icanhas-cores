// Parallel-to-serial shift register with 'done' flag.
// Copyright (c) 2010 Dwayne C. Litzenberger <dlitz@dlitz.net>

`ifndef SHIFTREG_V
`define SHIFTREG_V

module shiftreg #(parameter
    WIDTH = 8,
    LEFT = 0       // shift direction: 0: right, 1: left
) (
  input                  clock_in,    // positive edge-triggered system clock
  input                  n_reset_in,  // active low async reset
  input                  shift_in,    // when high, shift the bits in the direction specified by DIRECTION
  input                  pload_in,    // parallel load: when high, load pdata_in into the shift register
  input                  sdata_in,    // bit used to fill the empty space when shifting
  input      [WIDTH-1:0] pdata_in,    // parallel data input: loaded when \pload_in is high
  output reg [WIDTH-1:0] pdata_out,   // contents of the shift register
  output                 sdata_out,   // pdata_out[0] when LEFT=0; pdata_out[WIDTH-1] when LEFT=1
  output                 done1_out,   // active when pdata_out contains at most 1 of the bits that were loaded during the previous parallel load
  output                 done0_out    // active when pdata_out contains no more of the bits that were loaded during the previous parallel load
);

reg [WIDTH-1:0] done_reg;
assign done1_out = ~done_reg[1];
assign done0_out = ~done_reg[0];
assign sdata_out = LEFT ? pdata_out[WIDTH-1] : pdata_out[0];

always @ (posedge clock_in, negedge n_reset_in) begin
  if (!n_reset_in) begin
    pdata_out <= 0;
    done_reg <= 0;  // done_out becomes '1'
  end
  else if (pload_in) begin
    pdata_out <= pdata_in;
    done_reg <= ~0;   // done becomes '0'
  end
  else if (shift_in) begin
    if (LEFT) // shift left
      pdata_out <= (pdata_out << 1) | sdata_in;
    else   // shift right
      pdata_out <= {sdata_in, pdata_out} >> 1;
    done_reg <= done_reg >> 1;
  end
end

endmodule

`endif // SHIFTREG_V
