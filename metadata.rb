name             'augeas'
maintainer       'Nathan Huff'
maintainer_email 'nrhuff@umn.edu'
license          'Apache 2.0'
description      'Installs/Configures augeas'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          IO.read(File.join(File.dirname(__FILE__), 'VERSION')) rescue '0.1.0'

depends 'build-essential'

supports 'rhel'
supports 'fedora'
supports 'ubuntu'
