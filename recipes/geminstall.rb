include_recipe 'build-essential' if node['augeas']['build-essential']

node['augeas']['packages'].each do |package_name|
  package package_name do
    action :nothing
  end.run_action(:install)
end

chef_gem 'ruby-augeas' do
  compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
end
