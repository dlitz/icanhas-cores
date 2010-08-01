// Reset synchronizer
// Copyright (c) 2010 Dwayne C. Litzenberger <dlitz@dlitz.net>
//
// See Clifford E. Cummings and Don Mills, "Synchronous Resets? Asynchronous
// Resets? I am so confused! How will I ever know which to use?",  SNUG San
// Jose 2002
//

`ifndef RESET_SYNCHRONIZER_V
`define RESET_SYNCHRONIZER_V

module reset_synchronizer(
  clock_in,             // positive edge-triggered clock input
  reset_in,             // active high asynchronous reset input
  n_master_reset_out    // active low asynchronous assert, synchronous de-assert reset output
);

// inputs
input clock_in;
input reset_in;

// outputs
output n_master_reset_out;

// wires
wire clock_in;     // positive edge-triggered clock
wire reset_in;     // active high asynchronous reset

// registers
reg n_master_reset_out;
reg d;    // intermediate signal -- output of RESET_FF1, input of RESET_FF2

// active-low reset signal by inverting active-high reset signal
wire n_reset;
assign n_reset = ~reset_in;   // active low asynchronous reset (negation of reset)

// First flip-flop.  Output of this flip-flop should be 0 after async reset is
// de-asserted, but if it happens near a clock edge, it might be 1.
always @ (posedge clock_in, negedge n_reset)
begin: RESET_FF1
  if (!n_reset) d <= 0;
  else d <= 1;
end

// Second flip-flop.  Output of this flip-flop will be 0 after async reset is
// de-asserted, until either 1 or 2 clock cycles later, depending on the
// behaviour of RESET_FF1.
//
// The result is that n_master_reset_out is asserted asynchronously, but
// de-asserted synchronously.
always @ (posedge clock_in, negedge n_reset)
begin: RESET_FF2
  if (!n_reset) n_master_reset_out <= 0;
  else n_master_reset_out <= d;
end

endmodule

`endif // RESET_SYNCHRONIZER_V
