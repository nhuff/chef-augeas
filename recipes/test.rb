if platform_family?('rhel','fedora')
  conf_dir = '/etc/sysconfig'
elsif platform_family?('debian')
  conf_dir = '/etc/default'
else
  conf_dir = '/etc/sysconfig'
end

cookbook_file 'sysconfig_test' do
  path "#{conf_dir}/test"
  action :create
end

augeas 'sysconfig_test' do
  changes "set /files#{conf_dir}/test/TEST b"
end

augeas 'sysconfig_lens' do
  changes "set /files#{conf_dir}/test/TEST_LENS sysconfig"
  lens 'Sysconfig.lns'
  incl "#{conf_dir}/test"
end

# None of the following should change file
augeas 'sysconfig_get_equal_test' do
  changes "set /files#{conf_dir}/test/TEST c"
  run_if "get /files#{conf_dir}/test/TEST == a"
end

augeas 'sysconfig_get_not_equal_test' do
  changes "set /files#{conf_dir}/test/TEST c"
  run_if "get /files#{conf_dir}/test/TEST != b"
end

augeas 'sysconfig_get_regex_test' do
  changes "set /files#{conf_dir}/test/TEST c"
  run_if "get /files#{conf_dir}/test/TEST =~ /a/"
end

augeas 'sysconfig_get_lt_test' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "get /files#{conf_dir}/test/TEST_NUM < 1"
end

augeas 'sysconfig_get_gt_test' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "get /files#{conf_dir}/test/TEST_NUM > 1"
end

augeas 'sysconfig_get_ge_test' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "get /files#{conf_dir}/test/TEST_NUM >= 2"
end

augeas 'sysconfig_get_le_test' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "get /files#{conf_dir}/test/TEST_NUM <= 0"
end

augeas 'sysconfig_match_size' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "match /files#{conf_dir}/test/TEST_NUM[. = \"2\"] size > 0"
end

augeas 'sysconfig_match_include' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "match /files#{conf_dir}/test/TEST_NUM[. = \"2\"] include /files#{conf_dir}/test/TEST_NUM"
end

augeas 'sysconfig_match_not_include' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "match /files#{conf_dir}/test/TEST_NUM[. = \"1\"] not_include /files#{conf_dir}/test/TEST_NUM"
end

augeas 'sysconfig_match_equals' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "match /files#{conf_dir}/test/TEST_NUM[. = \"2\"] == [\"/files#{conf_dir}/test/TEST_NUM\"]"
end

augeas 'sysconfig_match_not_equals' do
  changes "set /files#{conf_dir}/test/TEST_NUM 2"
  run_if "match /files#{conf_dir}/test/TEST_NUM[. = \"1\"] != [\"/files#{conf_dir}/test/TEST_NUM\"]"
end

augeas 'sysconfig_no_change' do
  changes "set /files#{conf_dir}/test/TEST b"
end
