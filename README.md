# augeas cookbook

[Augeas](http://augeas.net/) is a library that allows files of different formats to be
edited in a mostly generic manner.  It does this by using a `lens` to transform the file
into a generic tree like structure which can then be modified and transformed back into
the original format of the file.  This cookbook provides a resource that allows recipes to
modify files using augeas.

# Requirements

Platforms:

* RHEL Family
* Debian
* Ubuntu

# Resources and Providers
### `augeas`

The `augeas` provider is used to make changes to files using the augeas library.

#### Attributes
* `changes`(required) - A string or list of strings that contain augeas commands to run
* `lens`(optional) - A specific lens to use to transform the file being modified
* `incl`(optional) - Only include the specified file in the augeas context. If this is set lens must also be specified.
* `run_if`(optional) - Only run if the given augeas matcher is true

#### Examples

Set the sysconfig variable `TEST` in the `/etc/sysconfig/test` file to b
```
augeas 'sysconfig_test' do
  changes 'set /files/etc/sysconfig/test/TEST b'
end
```

In the above case augeas already knows which lens to use to transform files
in `/etc/sysconfig`. If it didn't we could tell it more explicitly like

```
augeas 'sysconfig_lens' do
  changes 'set /files/etc/sysconfig/test/TEST b'
  lens    'Sysconfig.lns'
  incl    '/etc/sysconfig/test'
end
```

I can also make changes conditionaly based on augeas match statements.  The following will set TEST to c only if it is currently set to a.

```
augeas 'sysconfig_get_equal_test' do
  changes 'set /files/etc/sysconfig/test/TEST c'
  run_if  'get /files/etc/sysconfig/test/TEST == a'
end
```

# Recipes

### augeas::geminstall

This recipe will install the augeas development libraries and then use `chef_gem` to
make the `ruby-augeas` gem available to the resource.

TODO: This has the redhat package name hard coded right now.

# Author

Author:: Nathan Huff (nhuff@acm.org)
Contributor:: Pierre Rambaud

# Acknowledgements

The interface for this resource is pretty much a copy of the Puppet resource of the same
name.  While the code is rewritten the general flow of how it interacts with augeas is
also highly influenced by what the Puppet provider does.
