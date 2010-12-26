require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../../http_service/lib/palmade/http_service', __FILE__)

context "texter" do
  describe "deliver" do
    class Texter < Palmade::Kanned::Texter
      set_gateway :test

      attr_accessor :test_sent

      def test_message(msg)
        gateway.gateway_key.should == "test"

        self.test_sent = true
        "test #{msg}"
      end
    end

    before(:all) do
      Palmade::Kanned.configure do
        init SPEC_ROOT, SPEC_ENV
        config "spec/config/kanned.yml"
        set_route "test", :class_name => "TestController"
      end

      @init = Palmade::Kanned.init
      @gw = @init.gateways["test"]
      @config = @gw.config

    end

    it "should delivery ok" do
      test = Texter.deliver_test_message("deliver")
      test.should == "test deliver"
    end
  end
end
