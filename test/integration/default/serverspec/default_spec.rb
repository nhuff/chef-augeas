require 'spec_helper'

describe file('/etc/sysconfig/test') do
  its(:content) { should match(/^TEST=b$/) }
end

describe file('/etc/sysconfig/test') do
  its(:content) { should match(/^TEST_NUM=1$/) }
end

describe file('/etc/sysconfig/test') do
  its(:content) { should match(/^TEST_LENS=sysconfig$/) }
end
