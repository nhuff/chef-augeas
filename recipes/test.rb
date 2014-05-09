cookbook_file 'sysconfig_test' do
  path '/etc/sysconfig/test'
  action :create
end

augeas 'sysconfig_test' do
  changes 'set /files/etc/sysconfig/test/TEST b'
end

augeas 'sysconfig_lens' do
  changes 'set /files/etc/sysconfig/test/TEST_LENS sysconfig'
  lens 'Sysconfig.lns'
  incl '/etc/sysconfig/test'
end

# None of the following should change file
augeas 'sysconfig_get_equal_test' do
  changes 'set /files/etc/sysconfig/test/TEST c'
  run_if 'get /files/etc/sysconfig/test/TEST == a'
end

augeas 'sysconfig_get_not_equal_test' do
  changes 'set /files/etc/sysconfig/test/TEST c'
  run_if 'get /files/etc/sysconfig/test/TEST != b'
end

augeas 'sysconfig_get_regex_test' do
  changes 'set /files/etc/sysconfig/test/TEST c'
  run_if 'get /files/etc/sysconfig/test/TEST =~ /a/'
end

augeas 'sysconfig_get_lt_test' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'get /files/etc/sysconfig/test/TEST_NUM < 1'
end

augeas 'sysconfig_get_gt_test' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'get /files/etc/sysconfig/test/TEST_NUM > 1'
end

augeas 'sysconfig_get_ge_test' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'get /files/etc/sysconfig/test/TEST_NUM >= 2'
end

augeas 'sysconfig_get_le_test' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'get /files/etc/sysconfig/test/TEST_NUM <= 0'
end

augeas 'sysconfig_match_size' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'match /files/etc/sysconfig/test/TEST_NUM[. = "2"] size > 0'
end

augeas 'sysconfig_match_include' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'match /files/etc/sysconfig/test/TEST_NUM[. = "2"] include /files/etc/sysconfig/test/TEST_NUM'
end

augeas 'sysconfig_match_not_include' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'match /files/etc/sysconfig/test/TEST_NUM[. = "1"] not_include /files/etc/sysconfig/test/TEST_NUM'
end

augeas 'sysconfig_match_equals' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'match /files/etc/sysconfig/test/TEST_NUM[. = "2"] == ["/files/etc/sysconfig/test/TEST_NUM"]'
end

augeas 'sysconfig_match_not_equals' do
  changes 'set /files/etc/sysconfig/test/TEST_NUM 2'
  run_if 'match /files/etc/sysconfig/test/TEST_NUM[. = "1"] != ["/files/etc/sysconfig/test/TEST_NUM"]'
end

augeas 'sysconfig_no_change' do
  changes 'set /files/etc/sysconfig/test/TEST b'
end
