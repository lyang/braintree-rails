require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require 'webmock/rspec'
SimpleCov.command_name "spec:unit"
WebMock.disable_net_connect!
