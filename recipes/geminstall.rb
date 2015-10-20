node['augeas']['packages'].each do |package_name|
  package package_name
end

chef_gem 'ruby-augeas' do
  compile_time false if Chef::Resource::ChefGem.method_defined?(:compile_time)
end
