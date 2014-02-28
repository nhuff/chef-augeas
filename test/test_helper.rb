$LOAD_PATH.unshift(File.expand_path('../../libraries', __FILE__))

require 'rubygems'
require 'minitest'
require 'minitest/autorun'
require 'chef/resource'
require 'chef/provider'
require 'chef/event_dispatch/dispatcher'
require 'chef/run_context'
