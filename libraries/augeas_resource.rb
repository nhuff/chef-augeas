require 'chef/resource'

class Chef
  class Resource
    class Augeas < Chef::Resource

      def initialize(name, run_context=nil)
        super
        @resource_name = :augeas
        @action = :run
        @allowed_actions = [:run,:nothing]
        @changes = []
        @provider = Chef::Provider::Augeas
      end

      def changes(arg = nil)
        if arg.class == ''.class
          arg = [arg]
        end
        set_or_return(:changes,arg,kind_of: [Array],required: true)
      end
      def incl(arg=nil)
        set_or_return(:incl,arg,kind_of: String)
      end
      def context(arg=nil)
        set_or_return(:context,arg,kind_of: String)
      end
      def lens(arg=nil)
        set_or_return(:lens,arg,kind_of: String)
      end
      def only_if(arg=nil)
        set_or_return(:lens,arg,kind_of: String)
      end
    end
  end
end
