case node['platform']
when 'redhat', 'centos', 'scientific', 'fedora', 'suse', 'amazon', 'oracle'
  default['augeas']['packages'] = %w(augeas-devel)
when 'debian', 'ubuntu'
  default['augeas']['packages'] = %w(libaugeas-dev ruby1.9.1-dev libxml2-dev)
end
