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
    @aug = Minitest::Mock.new
    @aug.expect(:close,true)
    @aug.expect(:close,true)
  end

  def test_instance_of_provider
    assert_kind_of(Chef::Provider, @provider)
    assert_kind_of(Chef::Provider::Augeas, @provider)
  end

  def test_set_command
    @new_resource.changes('set /files/etc/hosts[. = \'127.0.0.1\'][last()+1] localhost.localdomain')

    @aug.expect(:set,true,["/files/etc/hosts[. = '127.0.0.1'][last()+1]",'localhost.localdomain'])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_setm_command
    @new_resource.changes('setm /files/etc/hosts/* foo localhost.localdomain')

    @aug.expect(:setm,true,["/files/etc/hosts/*",'foo','localhost.localdomain'])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_rm_command
    @new_resource.changes("rm /files/etc/hosts/[. = 'localhost.localdomain']")

    @aug.expect(:rm,true,["/files/etc/hosts/[. = 'localhost.localdomain']"])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_clear_command
    @new_resource.changes("clear /files/etc/hosts/[. = 'localhost.localdomain']")

    @aug.expect(:clear,true,["/files/etc/hosts/[. = 'localhost.localdomain']"])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_clearm_command
    @new_resource.changes("clearm /files/etc/hosts/[. = 'localhost.localdomain'] *")

    @aug.expect(:clearm,true,["/files/etc/hosts/[. = 'localhost.localdomain']","*"])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_ins_before_command
    @new_resource.changes("ins foo before /files/etc/hosts[last()]")

    @aug.expect(:insert,true,["/files/etc/hosts[last()]","foo",true])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_ins_after_command
    @new_resource.changes("ins foo after /files/etc/hosts[last()]")

    @aug.expect(:insert,true,["/files/etc/hosts[last()]","foo",false])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end
  
  def test_ins_fail
    @new_resource.changes("ins foo ter /files/etc/hosts[last()]")

    Augeas.stub(:open, @aug) do
     assert_raises(ArgumentError) {@provider.run_action(:run)}
    end
  end

  def test_mv_command
    @new_resource.changes("mv /foo /bar")

    @aug.expect(:mv,true,["/foo","/bar"])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_defvar_command
    @new_resource.changes("defvar foo /bar")

    @aug.expect(:defvar,true,["foo","/bar"])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_defnode_command
    @new_resource.changes("defnode foo /bar baz")

    @aug.expect(:defnode,true,["foo","/bar","baz"])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_nonexistent_command
    @new_resource.changes("asdf foo /bar baz")
    Augeas.stub(:open, @aug) do
     assert_raises(ArgumentError) {@provider.run_action(:run)}
    end
  end

  def test_command_array
    @new_resource.changes(["defvar foo /bar","rm /bar"])

    @aug.expect(:defvar,true,["foo","/bar"])
    @aug.expect(:rm,true,["/bar"])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_get
    @new_resource.only_if('get /foo == bar')

    @aug.expect(:get,'bar',['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_match_size
    @new_resource.only_if('match /foo size > 0')

    @aug.expect(:match,['foo'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_match_include
    @new_resource.only_if('match /foo include bar')

    @aug.expect(:match,['bar'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_match_not_include
    @new_resource.only_if('match /foo not_include bar')

    @aug.expect(:match,['baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_match_equals
    @new_resource.only_if('match /foo == ["bar","baz"]')

    @aug.expect(:match,['bar','baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

  def test_match_not_equals
    @new_resource.only_if('match /foo != ["bar","baz"]')

    @aug.expect(:match,['bar','baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.run_action(:run)
    end
    @aug.verify
  end

end
