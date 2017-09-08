name             'augeas'
maintainer       'Nathan Huff'
maintainer_email 'nrhuff@umn.edu'
license          'Apache 2.0'
description      'Installs/Configures augeas'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
if File.exist? File.join(File.dirname(__FILE__), 'VERSION')
  version IO.read(File.join(File.dirname(__FILE__), 'VERSION'))
else
  version '0.0.1'
end
chef_version '>= 12.1'
supports 'rhel'
supports 'fedora'
supports 'ubuntu'
source_url 'https://github.com/nhuff/chef-augeas'
issues_url 'https://github.com/nhuff/chef-augeas/issues'

depends 'build-essential'
