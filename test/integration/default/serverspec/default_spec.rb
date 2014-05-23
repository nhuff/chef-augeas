require 'spec_helper'

t_file = ''
t_file = '/etc/default/test' if ['Ubuntu','Debian'].include?(os[:family])
t_file = '/etc/sysconfig/test' if ['Fedora','RedHat'].include?(os[:family])

describe file(t_file) do
  its(:content) { should match(/^TEST=b$/) }
  its(:content) { should match(/^TEST_NUM=1$/) }
  its(:content) { should match(/^TEST_LENS=sysconfig$/) }
end
