require 'chef/resource'

class Chef
  class Resource
    class Augeas < Chef::Resource
      resource_name :augeas
      provides :augeas
      def initialize(name, run_context = nil)
        super
        @action = :run
        @allowed_actions = [:run, :nothing]
        @changes = []
        @provider = Chef::Provider::Augeas
      end

      def changes(arg = nil)
        arg = [arg] if arg.class == ''.class
        set_or_return(:changes, arg, kind_of: Array, required: true)
      end

      def incl(arg = nil)
        set_or_return(:incl, arg, kind_of: String)
      end

      def lens(arg = nil)
        set_or_return(:lens, arg, kind_of: String)
      end

      def run_if(arg = nil)
        set_or_return(:run_if, arg, kind_of: String)
      end
    end
  end
end
