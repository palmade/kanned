require File.expand_path(File.join(File.dirname(__FILE__), '../lib/palmade/kanned'))

require 'rubygems'
gem 'yajl-ruby'
require 'yajl'

SPEC_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
SPEC_ENV = "test"

class TestController < Palmade::Kanned::Controller
end
