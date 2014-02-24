require 'test_helper'
require 'augeas_provider'
require 'augeas_resource'

class AugeasProviderTest < Minitest::Test
  def setup
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, {}, @events)
    @new_resource = Chef::Resource::Augeas.new("test",@run_context)
    
    @provider = Chef::Provider::Augeas.new(@new_resource,@run_context)
  end

  def test_instance_of_provider
    assert_kind_of(Chef::Provider, @provider)
    assert_kind_of(Chef::Provider::Augeas, @provider)
  end

  def test_with_no_change_needed
     
    @provider.stub :in_sync?, true do

    end
  end
end
