node.set['build-essential']['compile_time'] = true
include_recipe 'build-essential'

node['augeas']['packages'].each do |package_name|
  package package_name do
    action :nothing
  end.run_action(:install)
end

chef_gem 'ruby-augeas' do
  action :install
end
