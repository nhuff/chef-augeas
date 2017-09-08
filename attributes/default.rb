case node['platform']
when 'debian', 'ubuntu'
  default['augeas']['packages'] = %w(libaugeas-dev pkg-config)
else
  default['augeas']['packages'] = %w(augeas-devel)
end
