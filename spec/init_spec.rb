require File.expand_path('../spec_helper', __FILE__)

context "init" do
  describe "configure" do
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

    it "should create an init object" do
      @init.should_not be_nil
      @init.should be_an_instance_of Palmade::Kanned::Init
    end

    it "should finalize and create gateway instances" do
      @gw.should_not be_nil
      @gw.should be_an_instance_of Palmade::Kanned::Gateway
      @gw.gateway_key.should == "test"
    end

    it "should have only one gateway, and our only one" do
      @init.gateways.size.should == 1
      @init.gateways.values.first.should be_an_instance_of Palmade::Kanned::Gateway
      @init.gateways.values.first.gateway_key.should == "test"
    end

    it "gateway should have a class_name set" do
      @gw.options.include?(:class_name).should be_true
      @gw.options[:class_name].should == "TestController"
    end

    it "gateway should have config loaded" do
      # config: adapters
      @config['adapters'].should_not be_nil
      @config['adapters'].size.should == 3
      @config['adapters'].include?('smsbox').should be_true
      ([ 'smsbox', 'twilio', 'mbuni' ] - @config['adapters']).should be_empty

      # config: smsbox
      @config.should include "smsbox"
      @config["smsbox"].should_not be_nil

      # config: mbuni
      @config.should include "mbuni"
      @config["mbuni"].should_not be_nil

      # config: twilio
      @config.should include "twilio"
      @config["twilio"].should_not be_nil
    end

    it "should have the correct url_prefix" do
      @gw.url_prefix.should == "/#{@gw.gateway_key}"
    end

    after(:all) do

    end
  end
end
