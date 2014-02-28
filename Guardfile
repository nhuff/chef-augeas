# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :off
group :test, halt_on_fail: true  do

  guard :minitest do
    watch(%r{^test/unit/(.*)_test.rb$})
    watch(%r{^libraries/(.*).rb$}) {|m| "test/unit/#{m[1]}_test.rb"}
    watch('test/test_helper.rb')
  end

  guard :rubocop do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end

  guard 'kitchen' do
    watch(%r{test/integration/.+})
    watch(%r{^recipes/(.+)\.rb$})
    watch(%r{^attributes/(.+)\.rb$})
    watch(%r{^files/(.+)})
    watch(%r{^templates/(.+)})
    watch(%r{^libraries/(.+)\.rb})
  end
end
