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

  def test_set_command
    @new_resource.changes('set /files/etc/hosts[. = \'127.0.0.1\'][last()+1] localhost.localdomain')

    aug = Minitest::Mock.new
    aug.expect(:set,true,["/files/etc/hosts[. = '127.0.0.1'][last()+1]",'localhost.localdomain'])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_setm_command
    @new_resource.changes('setm /files/etc/hosts/* foo localhost.localdomain')

    aug = Minitest::Mock.new
    aug.expect(:setm,true,["/files/etc/hosts/*",'foo','localhost.localdomain'])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_rm_command
    @new_resource.changes("rm /files/etc/hosts/[. = 'localhost.localdomain']")

    aug = Minitest::Mock.new
    aug.expect(:rm,true,["/files/etc/hosts/[. = 'localhost.localdomain']"])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_clear_command
    @new_resource.changes("clear /files/etc/hosts/[. = 'localhost.localdomain']")

    aug = Minitest::Mock.new
    aug.expect(:clear,true,["/files/etc/hosts/[. = 'localhost.localdomain']"])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_clearm_command
    @new_resource.changes("clearm /files/etc/hosts/[. = 'localhost.localdomain'] *")

    aug = Minitest::Mock.new
    aug.expect(:clearm,true,["/files/etc/hosts/[. = 'localhost.localdomain']","*"])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_ins_before_command
    @new_resource.changes("ins foo before /files/etc/hosts[last()]")

    aug = Minitest::Mock.new
    aug.expect(:insert,true,["/files/etc/hosts[last()]","foo",true])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_ins_after_command
    @new_resource.changes("ins foo after /files/etc/hosts[last()]")

    aug = Minitest::Mock.new
    aug.expect(:insert,true,["/files/etc/hosts[last()]","foo",false])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end
  
  def test_ins_fail
    @new_resource.changes("ins foo ter /files/etc/hosts[last()]")

    Augeas.stub(:open, true) do
     assert_raises(ArgumentError) {@provider.run_action(:run)}
    end
  end

  def test_mv_command
    @new_resource.changes("mv /foo /bar")

    aug = Minitest::Mock.new
    aug.expect(:mv,true,["/foo","/bar"])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_defvar_command
    @new_resource.changes("defvar foo /bar")

    aug = Minitest::Mock.new
    aug.expect(:defvar,true,["foo","/bar"])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_defnode_command
    @new_resource.changes("defnode foo /bar baz")

    aug = Minitest::Mock.new
    aug.expect(:defnode,true,["foo","/bar","baz"])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_nonexistent_command
    @new_resource.changes("asdf foo /bar baz")
    Augeas.stub(:open, true) do
     assert_raises(ArgumentError) {@provider.run_action(:run)}
    end
  end

  def test_command_array
    @new_resource.changes(["defvar foo /bar","rm /bar"])

    aug = Minitest::Mock.new
    aug.expect(:defvar,true,["foo","/bar"])
    aug.expect(:rm,true,["/bar"])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

  def test_get
    @new_resource.only_if('get /foo == bar')

    aug = Minitest::Mock.new
    aug.expect(:get,'bar',['/foo'])
    aug.expect(:close,true)
    Augeas.stub(:open, aug) do
      @provider.run_action(:run)
    end
    aug.verify
  end

end
