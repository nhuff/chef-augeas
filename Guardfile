# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :minitest do
  watch(%r{^test/unit/(.*)_test.rb$})
  watch(%r{^libraries/(.*).rb$}) {|m| "test/unit/#{m[1]}_test.rb"}
  watch('test/test_helper.rb')
end

notification :off
