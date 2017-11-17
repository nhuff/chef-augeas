case node['platform']
when 'debian', 'ubuntu'
  default['augeas']['packages'] = %w(libaugeas-dev pkg-config)
when 'freebsd'
  default['augeas']['packages'] = %w(augeas pkgconf)
else
  default['augeas']['packages'] = %w(augeas-devel)
end

# Set to false by default to maintain historic behavior
default['augeas']['build_essential'] = false
