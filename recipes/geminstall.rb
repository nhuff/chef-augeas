node.set['build_essential']['compiletime'] = true
include_recipe "build-essential"

package 'augeas-devel' do
  action :nothing
end.run_action(:install)

chef_gem 'augeas' do
  action :install
end
