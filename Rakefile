# rubocop:disable HashSyntax
require 'rake/testtask'
require 'rubocop/rake_task'
require 'kitchen/rake_tasks'

namespace :test do
  Rubocop::RakeTask.new

  Rake::TestTask.new do |t|
    t.libs << 'libraries' << 'test'
    t.test_files = FileList['test/unit/**/*_test.rb']
    t.verbose = true
  end
  Kitchen::RakeTasks.new

  task :all => [:rubocop,:test,'kitchen:all']
end

task :default => ['test:all']
