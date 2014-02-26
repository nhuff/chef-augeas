cookbook_file 'sysconfig_test' do
  path   '/etc/sysconfig/test'
  action :create_if_missing
end

augeas_apply 'sysconfig_test' do
  changes 'set /files/etc/sysconfig/test/TEST b'
end
