require 'test_helper'
require 'augeas_resource'
require 'augeas_provider'

# Tests for augeas chef resource
class AugeasTest < MiniTest::Test
  def setup
    @resource = Chef::Resource::Augeas.new('test')
    @resource.incl('/etc/sysconfig/test1')
  end

  def test_creates_chef_resource
    assert_instance_of(Chef::Resource::Augeas, @resource)
    assert_kind_of(Chef::Resource, @resource)
  end

  def test_has_a_name
    assert_equal(@resource.name, 'test')
  end

  def test_default_action_run
    assert_equal(:run, @resource.action)
  end

  def test_acceptable_actions
    assert_raises(Chef::Exceptions::ValidationFailed) { @resource.action(:lol) }
  end

  def test_accepts_incl
    assert_equal('/etc/sysconfig/test1', @resource.incl)
  end

  def test_accept_string_or_array_for_changes
    @resource.changes('set foo 1')
    assert_kind_of(Array, @resource.changes)
    assert_equal('set foo 1', @resource.changes.pop)
    @resource.changes(['set foo 2'])
    assert_kind_of(Array, @resource.changes)
    assert_equal('set foo 2', @resource.changes.pop)
  end

  def test_accept_run_if
    @resource.run_if 'match foo size > 0'
    assert_equal('match foo size > 0', @resource.run_if)
  end
end
