require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../../http_service/lib/palmade/http_service', __FILE__)

context "gateway" do
  describe "send sms" do
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

    it "should determine correct can send adapter" do
      can_send = Palmade::Kanned::Adapters.which_can_send(@gw.adapters.keys)
      can_send.should_not be_nil
      can_send.should == "smsbox"
    end

    it "should send an sms" do
      # Uncomment the following line if you want to send a text message.
      #
      resp = @gw.send_sms('+639176327037', 'Howdy do!')
      resp[0].should be_true
      resp[1].should_not be_empty
    end
  end
end
