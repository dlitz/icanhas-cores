module shiftreg_tb();
  wire                 clock_in;
  wire                 n_reset_in;
  wire                 load_in;
  wire                 shift_in;
  wire     [10-1:0] data_in;
  wire     [10-1:0] s10r_data_out, s10l_data_out;
  wire              s10r_done_out, s10l_done_out;

shiftreg #(.WIDTH(10), .LEFT(0)) S10R (    // 10-bit, shift right
  .clock_in(clock_in),
  .n_reset_in(n_reset_in),
  .load_in(load_in),
  .shift_in(shift_in),
  .data_in(data_in),
  .data_out(s10r_data_out),
  .done_out(s10r_done_out)
);

shiftreg #(.WIDTH(10), .LEFT(1)) S10L (    // 10-bit, shift left
  .clock_in(clock_in),
  .n_reset_in(n_reset_in),
  .load_in(load_in),
  .shift_in(shift_in),
  .data_in(data_in),
  .data_out(s10l_data_out),
  .done_out(s10l_done_out)
);

endmodule
