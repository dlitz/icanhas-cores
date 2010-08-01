$LOAD_PATH.unshift "test"
Dir.glob("test/**/*_test.rb").each do |file|
  require file
end
