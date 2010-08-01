// 16-byte FIFO
`ifndef FIFO16X8_V
`define FIFO16X8_V

module fifo16x8(
  clock_in,                   // positive edge-triggered system clock
  n_reset_in,                 // active low async reset
  write_in,                   // write enable
  wdata_in,                   // data to write into the fifo
  read_in,                    // read enable
  rdata_out,                  // data to read from the fifo
  readable_out,               // asserted when the fifo is empty
  writable_out                // asserted when the fifo is full
);

input clock_in;
input n_reset_in;
input write_in;
input [7:0] wdata_in;
input read_in;

output [7:0] rdata_out;
output readable_out;
output writable_out;

reg [3:0] rptr;
reg [3:0] wptr;
reg [4:0] avail;    // number of bytes available in the buffer

reg [7:0] rdata_out;

wire full = (avail == 0);
wire empty = (avail == 16);

wire writable_out = !full;
wire readable_out = !empty;

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
