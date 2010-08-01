// 16-byte FIFO
`ifndef FIFO16X8_V
`define FIFO16X8_V

module fifo16x8(
  input clock_in,                   // positive edge-triggered system clock
  input n_reset_in,                 // active low async reset
  input write_in,                   // write enable
  input [7:0] wdata_in,             // data to write into the fifo
  input read_in,                    // read enable
  output reg [7:0] rdata_out,       // data to read from the fifo
  output wire readable_out,          // asserted when the fifo is empty
  output wire writable_out           // asserted when the fifo is full
);

reg [3:0] rptr;
reg [3:0] wptr;
reg [4:0] avail;    // number of bytes available in the buffer

wire full = (avail == 0);
wire empty = (avail == 16);

assign writable_out = !full;
assign readable_out = !empty;

// Internal read & write signals
// Read requests are ignored when the buffer is empty.
wire read = (read_in && !empty);
// Write requests are ignored when the buffer is full, unless a simultaneous
// read is occurring.
wire write = (write_in && read) || (write_in && !full);

reg [7:0] buffer [0:15];  // 16x8 ram

always @ (posedge clock_in, negedge n_reset_in)
begin
  if (!n_reset_in) begin
    rptr <= 0;
    wptr <= 0;
    avail <= 16;
    rdata_out <= 0;
  end
  else begin
    if (write) begin // writes are ignored when the buffer is full
      buffer[wptr] <= wdata_in;
      wptr <= wptr + 1;
    end
    if (read) begin
      rdata_out <= buffer[rptr];
      rptr <= rptr + 1;
    end
    // Increment \avail if reading but not writing
    // Decrement \avail if writing but not reading
    // Leave \avail alone if reading and writing, or neither reading nor writing.
    if (read && !write) avail <= avail + 1;
    else if (write && !read) avail <= avail - 1;
  end
end

endmodule

`endif // FIFO16X8_V
