require 'rubygems'
require 'test/unit'
require 'ruby-vpi'

module ExtraMethods
  def cycle!
    clock_in.t!
    advance_time
    clock_in.f!
    advance_time
  end

  def reset!
    n_reset_in.f!
    cycle!
    n_reset_in.t!
  end
end

class MyTest < Test::Unit::TestCase
  def setup
    @dut = VPI.vpi_handle_by_name("fifo16x8", nil)
    @dut.extend(ExtraMethods)
    @dut.write_in.f!
    @dut.read_in.f!
    @dut.reset!
  end

  # Test a single write, followed by a single read cycle.
  #
  # This test should pass no matter what the capacity of the FIFO is.
  def test_single_read
    assert @dut.readable_out.f?, "after reset, FIFO shouldn't be readable"
    assert @dut.writable_out.t?, "after reset, FIFO should be writable"

    # Write a value to the FIFO
    @dut.write_in.t!
    @dut.wdata_in.hexStrVal = 'a3'
    @dut.cycle!
    # De-assert the input signals
    @dut.wdata_in.hexStrVal = "XX"
    @dut.write_in.f!

    # FIFO should now be readable
    assert @dut.readable_out.t?, "after write, FIFO should be readable"

    # Read from the FIFO
    @dut.read_in.t!
    @dut.cycle!

    assert_equal 'a3', @dut.rdata_out.hexStrVal, "after read, rdata_out should contain value originally written"

    assert @dut.readable_out.f?, "after read, FIFO shouldn't be readable"
  end

  # Test concurrent reading and writing
  #
  # This test should pass no matter what the capacity of the FIFO is.
  def test_concurrent_read_write
    assert @dut.readable_out.f?, "after reset, FIFO shouldn't be readable"
    assert @dut.writable_out.t?, "after reset, FIFO should be writable"

    # We want to read and write at the same time.
    #
    # Notes:
    # - The FIFO is not readable on the first cycle, so the read_in signal will
    #   be ignored by the FIFO until a value has been written.
    @dut.write_in.t!
    @dut.read_in.t!   # ignored this cycle

    (0..255).each do |v|
      @dut.wdata_in.intVal = v
      @dut.cycle!
      if v > 0
        assert_equal sprintf("%02x", v-1), @dut.rdata_out.hexStrVal
      end
      assert @dut.readable_out.t?, "FIFO should remain readable throughout the test (v=#{v.inspect})"
      assert @dut.writable_out.t?, "FIFO should remain writable throughout the test (v=#{v.inspect})"
    end
  end

  # Test that the FIFO behaves correctly when full and empty
  def test_full_and_empty
    assert @dut.readable_out.f?, "after reset, FIFO shouldn't be readable"
    assert @dut.writable_out.t?, "after reset, FIFO should be writable"

    # Perform the first write
    @dut.write_in.t!
    @dut.wdata_in.intVal = 1
    @dut.cycle!
    assert @dut.readable_out.t?, "FIFO should become readable after the first write"
    assert @dut.writable_out.t?, "FIFO should remain writable after the first write"

    # Perform subsequent writes
    (2..15).each do |n|
      @dut.wdata_in.intVal = n
      @dut.cycle!
      assert @dut.readable_out.t?, "FIFO should remain readable after writing #{n} bytes"
      assert @dut.writable_out.t?, "FIFO should remain writable after writing #{n} bytes"
      if n == 9
        # After writing a few bytes:
        # - de-assert write_in
        # - do some stuff, which should be ignored
        # - re-assert write_in
        @dut.write_in.f!
        @dut.wdata_in.hexStrVal = 'f1'
        @dut.cycle!
        @dut.wdata_in.hexStrVal = 'f2'
        @dut.cycle!
        @dut.wdata_in.hexStrVal = 'f3'
        @dut.cycle!
        @dut.wdata_in.hexStrVal = 'f4'
        @dut.cycle!
        @dut.wdata_in.hexStrVal = 'f5'
        @dut.cycle!
        @dut.write_in.t!
      end
    end

    # Perform the final write (FIFO should be full after this)
    @dut.wdata_in.intVal = 16
    @dut.cycle!
    assert @dut.readable_out.t?, "FIFO should remain readable after writing final byte"
    assert @dut.writable_out.f?, "FIFO should become unwritable after writing final byte"

    # Perform some extraneous writes (these should be ignored, even though write_in is asserted)
    (17..20).each do |n|
      @dut.wdata_in.intVal = n
      @dut.cycle!
      assert @dut.readable_out.t?, "FIFO should remain readable after writing #{n} bytes"
      assert @dut.writable_out.f?, "FIFO should remain unwritable after writing #{n} bytes"
    end

    # Stop writing and start reading
    @dut.write_in.f!
    @dut.read_in.t!

    # Perform several read cycles, doing some sanity checking along the way.
    (1..22).each do |n|
      @dut.cycle!
      if n == 1
        assert @dut.readable_out.t?, "FIFO should remain readable after reading #{n} bytes"
        assert @dut.writable_out.t?, "FIFO should become writable after reading #{n} bytes"
        assert_equal n, @dut.rdata_out.intVal, "FIFO should output #{n} after reading #{n} bytes"
      elsif n < 16
        assert @dut.readable_out.t?, "FIFO should remain readable after reading #{n} bytes"
        assert @dut.writable_out.t?, "FIFO should remain writable after reading #{n} bytes"
        assert_equal n, @dut.rdata_out.intVal, "FIFO should output #{n} after reading #{n} bytes"
      elsif n == 16
        assert @dut.readable_out.f?, "FIFO should become unreadable after reading #{n} bytes"
        assert @dut.writable_out.t?, "FIFO should remain writable after reading #{n} bytes"
        assert_equal n, @dut.rdata_out.intVal, "FIFO should output #{n} after reading #{n} bytes"
      else  # n > 16
        assert @dut.readable_out.f?, "FIFO should remain unreadable after reading #{n} bytes"
        assert @dut.writable_out.t?, "FIFO should remain writable after reading #{n} bytes"
        assert_equal 16, @dut.rdata_out.intVal, "FIFO output should not change when the FIFO is not readable"
      end

      # After reading a few bytes:
      # - de-assert read_in
      # - do some stuff, which should be ignored
      # - re-assert read_in
      if n == 3
        @dut.read_in.f!
        @dut.wdata_in.hexStrVal = 'd1'
        @dut.cycle!
        assert_equal n, @dut.rdata_out.intVal, "FIFO output should not change when read_in is not asserted"
        @dut.wdata_in.hexStrVal = 'd2'
        @dut.cycle!
        assert_equal n, @dut.rdata_out.intVal, "FIFO output should not change when read_in is not asserted"
        @dut.wdata_in.hexStrVal = 'd3'
        @dut.cycle!
        assert_equal n, @dut.rdata_out.intVal, "FIFO output should not change when read_in is not asserted"
        @dut.read_in.t!
      end
    end
  end
end
