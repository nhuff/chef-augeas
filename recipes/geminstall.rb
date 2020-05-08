node['augeas']['packages'].each do |p|
  package p
end
build_essential 'ruby-augeas' do
  only_if { node['augeas']['build_essential'] }
end
chef_gem 'ruby-augeas'
