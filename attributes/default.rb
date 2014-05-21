case node['platform']
when 'debian', 'ubuntu'
  default['augeas']['packages'] = %w(libaugeas-dev ruby1.9.1-dev libxml2-dev pkg-config)
else
  default['augeas']['packages'] = %w(augeas-devel)
end
