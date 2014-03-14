require 'rake/testtask'
require 'rubocop/rake_task'
require 'ridley'

namespace :test do
  Rubocop::RakeTask.new

  Rake::TestTask.new do |t|
    t.libs << 'libraries' << 'test'
    t.test_files = FileList['test/unit/**/*_test.rb']
    t.verbose = true
  end
end

namespace :deploy do
  task 'pin' do
    env = ENV['env'] || '_default'
    ver = IO.read(File.join(File.dirname(__FILE__), 'VERSION'))
    ridley = Ridley.from_chef_config
    dev = ridley.environment.find('dev')
    dev.cookbook_versions['augeas'] = "= #{ver.chomp()}"
    dev.save
  end
end
