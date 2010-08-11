require 'test_helper'

class ShiftregTest < Test::Unit::TestCase
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

  def test_shiftreg_10bit_right
    @dut = new_dut("shiftreg_tb.S10R")    # 10-bit shift right
    assert @dut.done1_out.t?, "done1_out should be asserted when the test starts"

    # Load one value per clock cycle
    @dut.pload_in.t!
    @dut.pdata_in.hexStrVal = "1e6"
    @dut.cycle!
    assert_equal ["1e6", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.pdata_in.hexStrVal = "3ff"
    @dut.cycle!
    assert_equal ["3ff", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.pload_in.f!

    # Shift 0's right
    @dut.sdata_in.intVal = 0
    @dut.shift_in.t!
    @dut.cycle!
    assert_equal "1ff", @dut.pdata_out.hexStrVal
    @dut.cycle!
    assert_equal "0ff", @dut.pdata_out.hexStrVal
    @dut.cycle!
    assert_equal "07f", @dut.pdata_out.hexStrVal

    # Stop shifting
    @dut.shift_in.f!
    @dut.cycle!
    assert_equal "07f", @dut.pdata_out.hexStrVal

    # Load new value
    @dut.pdata_in.binStrVal = "1000000000"
    @dut.pload_in.t!
    @dut.cycle!
    @dut.pload_in.f!
    assert_equal "1000000000", @dut.pdata_out.binStrVal

    # Do nothing
    @dut.cycle!
    assert_equal "1000000000", @dut.pdata_out.binStrVal

    # Shift right
    @dut.shift_in.t!
    @dut.cycle!; assert_equal ["0100000000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0010000000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0001000000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000100000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000010000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000001000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000000100", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000000010", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000000001", 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000000000", 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.shift_in.f!
    @dut.cycle!; assert_equal ["0000000000", 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]

    # Load while shifting (load takes precedence)
    @dut.pload_in.t!
    @dut.shift_in.t!
    @dut.pdata_in.hexStrVal = "1a2"
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]

    # Async reset
    @dut.n_reset_in.f!
    @dut.advance_time
    assert_equal ["000", 1], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.cycle!
    assert_equal ["000", 1], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.n_reset_in.t!
    @dut.advance_time
    assert_equal ["000", 1], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
  end

  def test_shiftreg_10bit_left
    @dut = new_dut("shiftreg_tb.S10L")    # 10-bit shift left
    assert @dut.done1_out.t?, "done1_out should be asserted when the test starts"

    # Load one value per clock cycle
    @dut.pload_in.t!
    @dut.pdata_in.hexStrVal = "1e6"
    @dut.cycle!
    assert_equal ["1e6", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.pdata_in.hexStrVal = "3ff"
    @dut.cycle!
    assert_equal ["3ff", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.pload_in.f!

    # Shift right
    @dut.shift_in.t!
    @dut.cycle!
    assert_equal "3fe", @dut.pdata_out.hexStrVal
    @dut.cycle!
    assert_equal "3fc", @dut.pdata_out.hexStrVal
    @dut.cycle!
    assert_equal "3f8", @dut.pdata_out.hexStrVal

    # Stop shifting
    @dut.shift_in.f!
    @dut.cycle!
    assert_equal "3f8", @dut.pdata_out.hexStrVal

    # Load new value
    @dut.pdata_in.binStrVal = "0000000001"
    @dut.pload_in.t!
    @dut.cycle!
    @dut.pload_in.f!
    assert_equal "0000000001", @dut.pdata_out.binStrVal

    # Do nothing
    @dut.cycle!
    assert_equal "0000000001", @dut.pdata_out.binStrVal

    # Shift right
    @dut.shift_in.t!
    @dut.cycle!; assert_equal ["0000000010", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000000100", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000001000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000010000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000100000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0001000000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0010000000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0100000000", 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["1000000000", 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.cycle!; assert_equal ["0000000000", 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]
    @dut.shift_in.f!
    @dut.cycle!; assert_equal ["0000000000", 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal]

    # Load while shifting (load takes precedence)
    @dut.pload_in.t!
    @dut.shift_in.t!
    @dut.pdata_in.hexStrVal = "1a2"
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]

    # Async reset
    @dut.n_reset_in.f!
    @dut.advance_time
    assert_equal ["000", 1], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.cycle!
    assert_equal ["000", 1], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.n_reset_in.t!
    @dut.advance_time
    assert_equal ["000", 1], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.pdata_out.hexStrVal, @dut.done1_out.intVal]
  end

  def test_shiftreg_10bit_sdata_right
    @dut = new_dut("shiftreg_tb.S10R")    # 10-bit shift right

    # Load zero
    @dut.pdata_in.hexStrVal = "000"
    @dut.pload_in.t!
    @dut.cycle!; assert_equal ["0000000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.pload_in.f!

    # Shift ones right
    @dut.sdata_in.intVal = 1
    @dut.shift_in.t!
    @dut.cycle!; assert_equal ["1000000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1100000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1110000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111100000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111110000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111111000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111111100", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111111110", 1, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111111111", 1, 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]

    # Load ones
    @dut.pdata_in.hexStrVal = "3ff"
    @dut.pload_in.t!
    @dut.cycle!; assert_equal ["1111111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.pload_in.f!

    # Shift zeroes right
    @dut.sdata_in.intVal = 0
    @dut.cycle!; assert_equal ["0111111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0011111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0001111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000011111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000001111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000000111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000000011", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000000001", 1, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000000000", 1, 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
  end

  def test_shiftreg_10bit_sdata_left
    @dut = new_dut("shiftreg_tb.S10L")    # 10-bit shift left

    # Load zero
    @dut.pdata_in.hexStrVal = "3ff"
    @dut.pload_in.t!
    @dut.cycle!; assert_equal ["1111111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.pload_in.f!

    # Shift zeroes left
    @dut.sdata_in.hexStrVal = 0
    @dut.shift_in.t!
    @dut.cycle!; assert_equal ["1111111110", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111111100", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111111000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111110000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111100000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1110000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1100000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1000000000", 1, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000000000", 1, 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]

    # Load zeroes
    @dut.pdata_in.hexStrVal = "000"
    @dut.pload_in.t!
    @dut.cycle!; assert_equal ["0000000000", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.pload_in.f!

    # Shift ones left
    @dut.sdata_in.intVal = 1
    @dut.cycle!; assert_equal ["0000000001", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000000011", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000000111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000001111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000011111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0000111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0001111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0011111111", 0, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["0111111111", 1, 0], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    @dut.cycle!; assert_equal ["1111111111", 1, 1], [@dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
  end


  def test_shiftreg_serial_xmit_right
    # Serial transmit: Connect done1_out to pload_in and start 'transmitting' the least significant bit
    @dut = new_dut("shiftreg_tb.S10R")    # 10-bit shift right
    assert @dut.done1_out.t?, "done1_out should be asserted when the test starts"
    @dut.pdata_in.hexStrVal = "2aa"
    @dut.shift_in.t!
    result = ""
    30.times do
      @dut.pload_in.intVal = @dut.done1_out.intVal
      @dut.cycle!
      result << @dut.pdata_out.binStrVal[-1]
    end
    assert_equal "010101010101010101010101010101", result, "there should be no gaps when shifting"
  end

  def test_shiftreg_serial_xmit_left
    # Serial transmit: Connect done1_out to pload_in and start 'transmitting' the most significant bit
    @dut = new_dut("shiftreg_tb.S10L")    # 10-bit shift left
    assert @dut.done1_out.t?, "done1_out should be asserted when the test starts"
    @dut.pdata_in.hexStrVal = "155"
    @dut.shift_in.t!
    result = ""
    30.times do
      @dut.pload_in.intVal = @dut.done1_out.intVal
      @dut.cycle!
      result << @dut.pdata_out.binStrVal[0]
    end
    assert_equal "010101010101010101010101010101", result, "there should be no gaps when shifting"
  end

  def test_shiftreg_serial_recv_right
    # Serial receive: Connect !done0_out to shift_in.  It will read 10 bits and then stop
    @dut = new_dut("shiftreg_tb.S10R")    # 10-bit shift right
    assert @dut.done0_out.t?, "done0_out should be asserted when the test starts"

    # Initialize the register with 0
    @dut.pdata_in.intVal = 0
    @dut.pload_in.t!
    @dut.cycle!
    @dut.pload_in.f!

    expected = [
      [0, "0000000000", 0, 0],
      [0, "0000000000", 0, 0],
      [0, "0000000000", 0, 0],
      [1, "1000000000", 0, 0],

      [0, "0100000000", 0, 0],
      [0, "0010000000", 0, 0],
      [0, "0001000000", 0, 0],
      [0, "0000100000", 0, 0],

      [0, "0000010000", 1, 0],
      [1, "1000001000", 1, 1],
      [1, "1000001000", 1, 1],
      [0, "1000001000", 1, 1],

      [1, "1000001000", 1, 1],
      [0, "1000001000", 1, 1],
      [0, "1000001000", 1, 1],
      [0, "1000001000", 1, 1],
    ]
    input = 0x1608
    result = []
    16.times do |i|
      @dut.shift_in.intVal = ~@dut.done0_out.intVal
      @dut.sdata_in.intVal = input & 1
      input >>= 1
      @dut.cycle!
      result << [@dut.sdata_in.intVal, @dut.pdata_out.binStrVal, @dut.done1_out.intVal, @dut.done0_out.intVal]
    end

    assert_equal "1000001000", @dut.pdata_out.binStrVal, "should give correct result"
    assert_equal expected, result, "intermediate steps should match expected"
  end


  protected

    def new_dut(name)
      dut = VPI.vpi_handle_by_name(name, nil)
      dut.extend(ExtraMethods)
      dut.sdata_in.f!
      dut.pload_in.f!
      dut.shift_in.f!
      dut.reset!
      dut
    end
end
