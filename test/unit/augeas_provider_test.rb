require 'test_helper'
require 'augeas_provider'
require 'augeas_resource'

# Tests for incl and lens
class AugeasProviderInclLens < Minitest::Test
  def setup
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, {}, @events)
    @new_resource = Chef::Resource::Augeas.new('test',@run_context)
    @provider = Chef::Provider::Augeas.new(@new_resource,@run_context)
    @aug = Minitest::Mock.new
    @aug.expect(:load,true)
    @aug.expect(:match,[],['/augeas//error'])
  end

  def test_incl
    @new_resource.incl('/etc/sysconfig/test1')
    @new_resource.lens('Sysconfig.lns')
    @aug.expect(:set,true,['/augeas/load/Xfm/lens','Sysconfig.lns'])
    @aug.expect(:set,true,['/augeas/load/Xfm/incl','/etc/sysconfig/test1'])
    Augeas.stub(:open, @aug) do
      @provider.open_augeas
    end
    @aug.verify
  end

  def test_lens
    @new_resource.lens('Sysconfig.lns')

    @aug.expect(:set,true,['/augeas/load/Xfm/lens','Sysconfig.lns'])
    Augeas.stub(:open, @aug) do
      @provider.open_augeas
    end
    @aug.verify
  end

  def test_incl_without_lens
    @new_resource.incl('/etc/sysconfig/test1')

    Augeas.stub(:open, @aug) do
      assert_raises(ArgumentError) { @provider.open_augeas }
    end
  end
end

# Tests for setting changes
class AugeasProviderSetTest < Minitest::Test
  def setup
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, {}, @events)
    @new_resource = Chef::Resource::Augeas.new('test',@run_context)

    @provider = Chef::Provider::Augeas.new(@new_resource,@run_context)
    @aug = Minitest::Mock.new
    @aug.expect(:set,true,['/augeas/save','overwrite'])
    @aug.expect(:load,true)
    @aug.expect(:load,true)
    @aug.expect(:save,true)
    @aug.expect(:close,true)
    @aug.expect(:match,[],['/augeas//error'])
    @aug.expect(:match,[],['/augeas/events/saved'])
  end

  def test_set_command
    @new_resource.changes('set /files/etc/hosts[. = \'127.0.0.1\'][last()+1] localhost.localdomain')

    @aug.expect(:set,true,["/files/etc/hosts[. = '127.0.0.1'][last()+1]",'localhost.localdomain'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_setm_command
    @new_resource.changes('setm /files/etc/hosts/* foo localhost.localdomain')

    @aug.expect(:setm,true,['/files/etc/hosts/*','foo','localhost.localdomain'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_rm_command
    @new_resource.changes("rm /files/etc/hosts/[. = 'localhost.localdomain']")

    @aug.expect(:rm,true,["/files/etc/hosts/[. = 'localhost.localdomain']"])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_clear_command
    @new_resource.changes("clear /files/etc/hosts/[. = 'localhost.localdomain']")

    @aug.expect(:clear,true,["/files/etc/hosts/[. = 'localhost.localdomain']"])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_clearm_command
    @new_resource.changes("clearm /files/etc/hosts/[. = 'localhost.localdomain'] *")

    @aug.expect(:clearm,true,["/files/etc/hosts/[. = 'localhost.localdomain']",'*'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_ins_before_command
    @new_resource.changes('ins foo before /files/etc/hosts[last()]')

    @aug.expect(:insert,true,['/files/etc/hosts[last()]','foo',true])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_ins_after_command
    @new_resource.changes('ins foo after /files/etc/hosts[last()]')

    @aug.expect(:insert,true,['/files/etc/hosts[last()]','foo',false])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_ins_fail
    @new_resource.changes('ins foo ter /files/etc/hosts[last()]')

    @aug.expect(:close,true)
    Augeas.stub(:open, @aug) do
      assert_raises(ArgumentError) { @provider.run_action(:run) }
    end
  end

  def test_mv_command
    @new_resource.changes('mv /foo /bar')

    @aug.expect(:mv,true,['/foo','/bar'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_defvar_command
    @new_resource.changes('defvar foo /bar')

    @aug.expect(:defvar,true,['foo','/bar'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_defnode_command
    @new_resource.changes('defnode foo /bar baz')

    @aug.expect(:defnode,true,['foo','/bar','baz'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end

  def test_nonexistent_command
    @new_resource.changes('asdf foo /bar baz')
    @aug.expect(:close,true)
    Augeas.stub(:open, @aug) do
      assert_raises(ArgumentError) { @provider.run_action(:run) }
    end
  end

  def test_command_array
    @new_resource.changes(['defvar foo /bar','rm /bar'])

    @aug.expect(:defvar,true,['foo','/bar'])
    @aug.expect(:rm,true,['/bar'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        @provider.run_action(:run)
      end
    end
    @aug.verify
  end
end

# Tests for augeas provder
class AugeasProviderTest < Minitest::Test
  def setup
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, {}, @events)
    @new_resource = Chef::Resource::Augeas.new('test',@run_context)

    @provider = Chef::Provider::Augeas.new(@new_resource,@run_context)
    @aug = Minitest::Mock.new
  end

  def test_instance_of_provider
    assert_kind_of(Chef::Provider, @provider)
    assert_kind_of(Chef::Provider::Augeas, @provider)
  end

  def test_get
    @aug.expect(:get,'bar',['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        assert(@provider.need_run?(@aug,'get /foo == bar',[]))
      end
    end
    @aug.verify
  end

  def test_get_ge
    @aug.expect(:get,'3',['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        assert(@provider.need_run?(@aug,'get /foo >= 2',[]))
      end
    end
  end

  def test_get_fail
    @aug.expect(:get,'baz',['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        refute(@provider.need_run?(@aug,'get /foo == bar',[]))
      end
    end
    @aug.verify
  end

  def test_match_size
    @aug.expect(:match,['foo'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        assert(@provider.need_run?(@aug,'match /foo size > 0',[]))
      end
    end
    @aug.verify
  end

  def test_match_size_fail
    @aug.expect(:match,[],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        refute(@provider.need_run?(@aug,'match /foo size > 0',[]))
      end
    end
    @aug.verify
  end

  def test_match_include
    @aug.expect(:match,['bar','baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        assert(@provider.need_run?(@aug,'match /foo include bar',[]))
      end
    end
    @aug.verify
  end

  def test_match_include_fail
    @aug.expect(:match,['baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        refute(@provider.need_run?(@aug,'match /foo include bar',[]))
      end
    end
    @aug.verify
  end

  def test_match_not_include
    @aug.expect(:match,['baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        assert(@provider.need_run?(@aug,'match /foo not_include bar',[]))
      end
    end
    @aug.verify
  end

  def test_match_not_include_fail
    @aug.expect(:match,['baz','bar'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        refute(@provider.need_run?(@aug,'match /foo not_include bar',[]))
      end
    end
    @aug.verify
  end

  def test_match_equals
    @aug.expect(:match,['bar','baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        assert(@provider.need_run?(@aug,'match /foo == ["bar","baz"]',[]))
      end
    end
    @aug.verify
  end

  def test_match_equals
    @aug.expect(:match,['bar'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        refute(@provider.need_run?(@aug,'match /foo == ["bar","baz"]',[]))
      end
    end
    @aug.verify
  end

  def test_match_not_equals
    @aug.expect(:match,['baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        assert(@provider.need_run?(@aug,'match /foo != ["bar","baz"]',[]))
      end
    end
    @aug.verify
  end

  def test_match_not_equals_fail
    @aug.expect(:match,['bar','baz'],['/foo'])
    Augeas.stub(:open, @aug) do
      @provider.stub(:in_sync?,false) do
        refute(@provider.need_run?(@aug,'match /foo != ["bar","baz"]',[]))
      end
    end
    @aug.verify
  end

  def test_not_in_sync
    @aug.expect(:match,['/augeas/events/saved'],['/augeas/events/saved'])
    @aug.expect(:save,true)
    Augeas.stub(:open, @aug) do
      File.stub(:delete,true) do
        assert(@provider.need_run?(@aug,nil,[]))
      end
    end
    @aug.verify
  end

  def test_in_sync
    @aug.expect(:match,[],['/augeas/events/saved'])
    @aug.expect(:save,true)
    Augeas.stub(:open, @aug) do
      refute(@provider.need_run?(@aug,nil,[]))
    end
    @aug.verify
  end
end
