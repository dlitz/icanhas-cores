#!/bin/sh
export RUBYVPI_SIMULATOR=cver
export DEBUGGER=0
export COVERAGE=0
export PROTOTYPE=0
export PROFILER=0
export RUBYVPI_TEST_LOADER=fifo16x8_test.rb
exec cver +loadvpi="$GEM_HOME"/gems/ruby-vpi-21.1.0/obj/cver.so:vlog_startup_routines_bootstrap +incdir+. fifo16x8.v
