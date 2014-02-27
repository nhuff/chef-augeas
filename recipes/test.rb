cookbook_file 'sysconfig_test' do
  path   '/etc/sysconfig/test'
  action :create
end

augeas 'sysconfig_test' do
  changes 'set /files/etc/sysconfig/test/TEST b'
end

#None of the following should change file
augeas 'sysconfig_get_equal_test' do
  changes 'set /files/etc/sysconfig/test/TEST c'
  run_if  'get /files/etc/sysconfig/test/TEST == a'
end

augeas 'sysconfig_get_not_equal_test' do
  changes 'set /files/etc/sysconfig/test/TEST c'
  run_if  'get /files/etc/sysconfig/test/TEST != b'
end

augeas 'sysconfig_get_regex_test' do
  changes 'set /files/etc/sysconfig/test/TEST c'
  run_if  'get /files/etc/sysconfig/test/TEST =~ /a/'
end
