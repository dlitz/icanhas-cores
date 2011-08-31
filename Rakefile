desc "Run the tests (using cver)"
task :test do
  require 'ruby-vpi/util'

  # variables for ruby-vpi
  ENV['RUBYVPI_SIMULATOR'] = 'ivl'
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

  rm_f("a.out")
  cp(object_file_path, "ruby-vpi.vpi")
  system('iverilog', '-mruby-vpi', *Dir.glob(["hdl/*.v", "test/*.v"])) && system('vvp', '-M.', 'a.out')
end
