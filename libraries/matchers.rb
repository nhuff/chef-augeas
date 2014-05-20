# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-
#
if defined?(ChefSpec)
  def run_augeas(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:augeas, :run, resource_name)
  end
end
