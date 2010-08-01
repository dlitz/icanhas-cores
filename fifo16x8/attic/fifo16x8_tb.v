`include "fifo16x8.v"

module fifo16x8_tb();

reg clock;
reg n_reset;

reg write;
reg read;
reg [7:0] wdata;

wire empty;
wire full;
wire [7:0] rdata;

always #5 clock = ~clock;    // full clock cycle every 10 ticks

initial begin
  $display ("time\t clock n_reset write wdata      read | rdata     empty full");
  $monitor   ("%g\t %b     %b       %b     %b   %b    | %b  %b     %b",
              $time, clock, n_reset, write, wdata, read, rdata, empty, full);

  // initial values
  clock = 1;
  n_reset = 0;    // assert reset
  read = 0;
  write = 0;
  wdata = 0;

  // de-assert reset
  #5 n_reset <= 1;

  $display("// Do nothing for 2 clock ticks");
  @ (negedge clock);
  @ (negedge clock);

  $display("// Write a byte into the FIFO");
  write <= 1;
  wdata <= 8'hAA;
  @ (negedge clock);
  write = 0;
  @ (negedge clock);

  $display("// Read the byte from the FIFO");
  read <= 1;
  @ (negedge clock);
  read <= 0;
  @ (negedge clock);

  $display("// Try to read a byte from the FIFO, even though it is empty.");
  $display("// (Should have no effect)");
  read <= 1;
  @ (negedge clock);
  read <= 0;
  @ (negedge clock);

  $display("// Write 16 bytes into the FIFO");
  write <= 1;
  wdata <= 8'h00;
  @ (negedge clock);
  wdata <= 8'h01; @ (negedge clock);
  wdata <= 8'h02; @ (negedge clock);
  wdata <= 8'h03; @ (negedge clock);
  wdata <= 8'h04; @ (negedge clock);
  wdata <= 8'h05; @ (negedge clock);
  wdata <= 8'h06; @ (negedge clock);
  wdata <= 8'h07; @ (negedge clock);
  wdata <= 8'h08; @ (negedge clock);
  wdata <= 8'h09; @ (negedge clock);
  wdata <= 8'h0a; @ (negedge clock);
  wdata <= 8'h0b; @ (negedge clock);
  wdata <= 8'h0c; @ (negedge clock);
  wdata <= 8'h0d; @ (negedge clock);
  wdata <= 8'h0e; @ (negedge clock);
  wdata <= 8'h0f; @ (negedge clock);

  $display("// \\full should be 1 here");

  $display("// Try to write an extra byte to the FIFO.  It should be ignored.");
  wdata <= 8'hXX; @ (negedge clock);
  write <= 0; @ (negedge clock);

  $display("// FIFO should still be full here");

  $display("// Read 1 byte from the FIFO while writing another byte");
  read <= 1;
  write <= 1;
  wdata <= 8'h10;
  @ (negedge clock);
  $display("// FIFO should still be full and rdata should be 8'h00");
  $display("// Read 15 bytes from the FIFO while writing 15 other bytes");
  wdata <= 8'h11; @ (negedge clock);
  wdata <= 8'h12; @ (negedge clock);
  wdata <= 8'h13; @ (negedge clock);
  wdata <= 8'h14; @ (negedge clock);
  wdata <= 8'h15; @ (negedge clock);
  wdata <= 8'h16; @ (negedge clock);
  wdata <= 8'h17; @ (negedge clock);
  wdata <= 8'h18; @ (negedge clock);
  wdata <= 8'h19; @ (negedge clock);
  wdata <= 8'h1a; @ (negedge clock);
  wdata <= 8'h1b; @ (negedge clock);
  wdata <= 8'h1c; @ (negedge clock);
  wdata <= 8'h1d; @ (negedge clock);
  wdata <= 8'h1e; @ (negedge clock);
  wdata <= 8'h1f; @ (negedge clock);

  $display("// Stop writing");
  $display("// Read 16 bytes from the FIFO.");
  wdata <= 8'hXX;
  write <= 0;
  read <= 1;
  repeat (16) begin
    @ (negedge clock);
  end

  $display("// Should be empty here");
  $display("// Stop reading");
  read <= 0;

  @ (negedge clock);
  @ (negedge clock);
  @ (negedge clock);
  $finish;

end

fifo16x8 U_fifo16x8(
  .clock_in (clock),
  .n_reset_in (n_reset),
  .write_in (write),
  .wdata_in (wdata),
  .read_in (read),
  .rdata_out (rdata),
  .empty_out (empty),
  .full_out (full)
);

endmodule
