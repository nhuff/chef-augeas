require 'test_helper'
require 'augeas_resource'
require 'augeas_provider'

class AugeasApplyTest < MiniTest::Test
  def setup
    @resource = Chef::Resource::AugeasApply.new('test')
  end

  def test_creates_chef_resource
    assert_instance_of(Chef::Resource::AugeasApply,@resource)
    assert_kind_of(Chef::Resource,@resource)
  end

  def test_has_a_name
    assert_equal(@resource.name,'test')
  end

  def test_default_action_run
    assert_equal(:run,@resource.action)
  end

  def test_acceptable_actions
    assert_raises(Chef::Exceptions::ValidationFailed) { @resource.action(:lol) }
  end

  def test_accept_string_or_array_for_changes
    @resource.changes('set foo 1')
    assert_kind_of(Array,@resource.changes)
    assert_equal('set foo 1',@resource.changes.pop)
    @resource.changes(['set foo 2'])
    assert_kind_of(Array,@resource.changes)
    assert_equal('set foo 2',@resource.changes.pop)
  end

  def test_accept_context
    @resource.context('/files/etc/passwd')
    assert_equal('/files/etc/passwd', @resource.context)
  end

  def test_accept_lens
    @resource.lens('Xml.lns')
    assert_equal('Xml.lns',@resource.lens)
  end

  def test_accept_run_if
    @resource.run_if 'match foo size > 0'
    assert_equal('match foo size > 0', @resource.run_if)
  end

  def test_accept_incl
    @resource.incl('/etc/passwd')
    assert_equal('/etc/passwd',@resource.incl)
  end
end
