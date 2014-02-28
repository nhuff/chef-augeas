require 'rake/testtask'
require 'rubocop/rake_task'

namespace :test do
  Rubocop::RakeTask.new

  Rake::TestTask.new do |t|
    t.libs << 'libraries' << 'test'
    t.test_files = FileList['test/unit/**/*_test.rb']
    t.verbose = true
  end
end
