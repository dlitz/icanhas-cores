desc "Run the tests (using cver)"
task :test do
  require 'ruby-vpi/util'

  # variables for ruby-vpi
  ENV['RUBYVPI_SIMULATOR'] = 'cver'
  ENV['DEBUGGER'] = '0'
  ENV['COVERAGE'] = '0'
  ENV['PROTOTYPE'] = '0'
  ENV['PROFILER'] = '0'
  ENV['RUBYVPI_TEST_LOADER'] = 'test/test_loader.rb'

  object_file_path = nil
  $LOAD_PATH.each{|p|
    object_file_path = File.expand_path("../obj/cver.so", p)
    break if File.exist?(object_file_path)
  }

  system 'cver', "+loadvpi=#{object_file_path}:vlog_startup_routines_bootstrap", '+incdir+./hdl', *Dir.glob("hdl/*.v")
end
