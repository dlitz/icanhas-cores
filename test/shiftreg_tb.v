module shiftreg_tb();

wire          clock_in;
wire          n_reset_in;
wire          pload_in;
wire [10-1:0] pdata_in;
wire          shift_in;
wire          sdata_in;
wire [10-1:0] s10r_pdata_out, s10l_pdata_out;
wire          s10r_sdata_out, s10l_sdata_out;
wire          s10r_done1_out, s10l_done1_out;
wire          s10r_done0_out, s10l_done0_out;

shiftreg #(.WIDTH(10), .LEFT(0)) S10R (    // 10-bit, shift right
  .clock_in(clock_in),
  .n_reset_in(n_reset_in),
  .pload_in(pload_in),
  .pdata_in(pdata_in),
  .shift_in(shift_in),
  .sdata_in(sdata_in),
  .pdata_out(s10r_pdata_out),
  .sdata_out(s10r_sdata_out),
  .done1_out(s10r_done1_out),
  .done0_out(s10r_done0_out)
);

shiftreg #(.WIDTH(10), .LEFT(1)) S10L (    // 10-bit, shift left
  .clock_in(clock_in),
  .n_reset_in(n_reset_in),
  .pload_in(pload_in),
  .pdata_in(pdata_in),
  .shift_in(shift_in),
  .sdata_in(sdata_in),
  .pdata_out(s10l_pdata_out),
  .sdata_out(s10l_sdata_out),
  .done1_out(s10l_done1_out),
  .done0_out(s10l_done0_out)
);

endmodule
