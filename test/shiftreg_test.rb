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
    assert @dut.done_out.t?, "done_out should be asserted when the test starts"

    # Load one value per clock cycle
    @dut.load_in.t!
    @dut.data_in.hexStrVal = "1e6"
    @dut.cycle!
    assert_equal ["1e6", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.data_in.hexStrVal = "3ff"
    @dut.cycle!
    assert_equal ["3ff", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.load_in.f!

    # Shift right
    @dut.shift_in.t!
    @dut.cycle!
    assert_equal "1ff", @dut.data_out.hexStrVal
    @dut.cycle!
    assert_equal "0ff", @dut.data_out.hexStrVal
    @dut.cycle!
    assert_equal "07f", @dut.data_out.hexStrVal

    # Stop shifting
    @dut.shift_in.f!
    @dut.cycle!
    assert_equal "07f", @dut.data_out.hexStrVal

    # Load new value
    @dut.data_in.binStrVal = "1000000000"
    @dut.load_in.t!
    @dut.cycle!
    @dut.load_in.f!
    assert_equal "1000000000", @dut.data_out.binStrVal

    # Do nothing
    @dut.cycle!
    assert_equal "1000000000", @dut.data_out.binStrVal

    # Shift right
    @dut.shift_in.t!
    @dut.cycle!; assert_equal ["0100000000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0010000000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0001000000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000100000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000010000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000001000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000000100", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000000010", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000000001", 1], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000000000", 1], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.shift_in.f!
    @dut.cycle!; assert_equal ["0000000000", 1], [@dut.data_out.binStrVal, @dut.done_out.intVal]

    # Load while shifting (load takes precedence)
    @dut.load_in.t!
    @dut.shift_in.t!
    @dut.data_in.hexStrVal = "1a2"
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]

    # Async reset
    @dut.n_reset_in.f!
    @dut.advance_time
    assert_equal ["000", 1], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.cycle!
    assert_equal ["000", 1], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.n_reset_in.t!
    @dut.advance_time
    assert_equal ["000", 1], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
  end

  def test_shiftreg_10bit_left
    @dut = new_dut("shiftreg_tb.S10L")    # 10-bit shift left
    assert @dut.done_out.t?, "done_out should be asserted when the test starts"

    # Load one value per clock cycle
    @dut.load_in.t!
    @dut.data_in.hexStrVal = "1e6"
    @dut.cycle!
    assert_equal ["1e6", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.data_in.hexStrVal = "3ff"
    @dut.cycle!
    assert_equal ["3ff", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.load_in.f!

    # Shift right
    @dut.shift_in.t!
    @dut.cycle!
    assert_equal "3fe", @dut.data_out.hexStrVal
    @dut.cycle!
    assert_equal "3fc", @dut.data_out.hexStrVal
    @dut.cycle!
    assert_equal "3f8", @dut.data_out.hexStrVal

    # Stop shifting
    @dut.shift_in.f!
    @dut.cycle!
    assert_equal "3f8", @dut.data_out.hexStrVal

    # Load new value
    @dut.data_in.binStrVal = "0000000001"
    @dut.load_in.t!
    @dut.cycle!
    @dut.load_in.f!
    assert_equal "0000000001", @dut.data_out.binStrVal

    # Do nothing
    @dut.cycle!
    assert_equal "0000000001", @dut.data_out.binStrVal

    # Shift right
    @dut.shift_in.t!
    @dut.cycle!; assert_equal ["0000000010", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000000100", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000001000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000010000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000100000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0001000000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0010000000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0100000000", 0], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["1000000000", 1], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.cycle!; assert_equal ["0000000000", 1], [@dut.data_out.binStrVal, @dut.done_out.intVal]
    @dut.shift_in.f!
    @dut.cycle!; assert_equal ["0000000000", 1], [@dut.data_out.binStrVal, @dut.done_out.intVal]

    # Load while shifting (load takes precedence)
    @dut.load_in.t!
    @dut.shift_in.t!
    @dut.data_in.hexStrVal = "1a2"
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]

    # Async reset
    @dut.n_reset_in.f!
    @dut.advance_time
    assert_equal ["000", 1], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.cycle!
    assert_equal ["000", 1], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.n_reset_in.t!
    @dut.advance_time
    assert_equal ["000", 1], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
    @dut.cycle!
    assert_equal ["1a2", 0], [@dut.data_out.hexStrVal, @dut.done_out.intVal]
  end

  def test_shiftreg_serial_xmit_right
    # Serial transmit: Connect done_out to load_in and start 'transmitting' the least significant bit
    @dut = new_dut("shiftreg_tb.S10R")    # 10-bit shift right
    assert @dut.done_out.t?, "done_out should be asserted when the test starts"
    @dut.data_in.hexStrVal = "2aa"
    @dut.shift_in.t!
    result = ""
    30.times do
      @dut.load_in.intVal = @dut.done_out.intVal
      @dut.cycle!
      result << @dut.data_out.binStrVal[-1]
    end
    assert_equal "010101010101010101010101010101", result, "there should be no gaps when shifting"
  end

  def test_shiftreg_serial_xmit_left
    # Serial transmit: Connect done_out to load_in and start 'transmitting' the most significant bit
    @dut = new_dut("shiftreg_tb.S10L")    # 10-bit shift left
    assert @dut.done_out.t?, "done_out should be asserted when the test starts"
    @dut.data_in.hexStrVal = "155"
    @dut.shift_in.t!
    result = ""
    30.times do
      @dut.load_in.intVal = @dut.done_out.intVal
      @dut.cycle!
      result << @dut.data_out.binStrVal[0]
    end
    assert_equal "010101010101010101010101010101", result, "there should be no gaps when shifting"
  end

  protected

    def new_dut(name)
      dut = VPI.vpi_handle_by_name(name, nil)
      dut.extend(ExtraMethods)
      dut.load_in.f!
      dut.shift_in.f!
      dut.reset!
      dut
    end
end
