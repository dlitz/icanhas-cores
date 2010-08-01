require 'test_helper'

class ResetSynchronizerTest < Test::Unit::TestCase
  module ExtraMethods
    def cycle!
      clock_in.t!
      advance_time
      clock_in.f!
      advance_time
    end
  end

  def setup
    @dut = VPI.vpi_handle_by_name("reset_synchronizer", nil)
    @dut.extend(ExtraMethods)

    # Flush the DUT (it has no traditional reset signal, obviously)
    @dut.reset_in.t!
    5.times { @dut.cycle! }
    @dut.reset_in.f!
    5.times { @dut.cycle! }
  end

  def test_reset_synchronizer
    assert @dut.n_master_reset_out.t?, "output should be 1 before running test"
    assert @dut.clock_in.f?, "clock input should be 0 before running test"

    # Assert active-high reset_in
    @dut.reset_in.t!
    @dut.advance_time   # advance time only; no clock cycle
    assert @dut.n_master_reset_out.f?, "active low reset output should be asserted asynchronously"

    # De-assert active-high reset_in
    @dut.reset_in.f!
    @dut.advance_time   # advance time only; no clock cycle
    assert @dut.n_master_reset_out.f?, "active low reset output should not be de-asserted asynchronously"

    # Active-low reset output should be de-asserted synchronously in 2 cycles.
    @dut.cycle!
    assert @dut.n_master_reset_out.f?, "Active-low reset output should not be de-asserted after the first clock cycle"
    @dut.cycle!
    assert @dut.n_master_reset_out.t?, "Active-low reset output should be de-asserted after the second clock cycle"
  end
end
