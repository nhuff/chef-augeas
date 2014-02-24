require 'chef/provider'
require 'augeas'

class Chef
  class Provider
    class Augeas < Chef::Provider

      def initialize(new_resource,run_context=nil,aug_class=Augeas)
        super(new_resource,run_context)
      end
      def in_sync?
        true
      end
    end
  end
end

