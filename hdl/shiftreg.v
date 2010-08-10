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
  input                  load_in,     // when high, load data_in into the shift register
  input                  shift_in,    // when high, shift the bits in the direction specified by DIRECTION
  input      [WIDTH-1:0] data_in,     // loaded when \load_in is high
  output reg [WIDTH-1:0] data_out,    // contents of the shift register
  output                 done_out     // active when the shift register is empty
);

reg [WIDTH-2:0] done_reg;
assign done_out = ~done_reg[0];

always @ (posedge clock_in, negedge n_reset_in) begin
  if (!n_reset_in) begin
    data_out <= 0;
    done_reg <= 0;  // done_out becomes '1'
  end
  else if (load_in) begin
    data_out <= data_in;
    done_reg <= ~0;   // done becomes '0'
  end
  else if (shift_in) begin
    if (LEFT == 0)   // right
      data_out <= data_out >> 1;
    else  // left
      data_out <= data_out << 1;
    done_reg <= done_reg >> 1;
  end
end

endmodule

`endif // SHIFTREG_V
