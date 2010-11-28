require File.expand_path(File.join(File.dirname(__FILE__), '../lib/palmade/kanned'))

SPEC_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
SPEC_ENV = "test"

class TestController < Palmade::Kanned::Controller
end

