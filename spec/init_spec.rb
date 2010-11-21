require File.expand_path('../spec_helper', __FILE__)

context "init" do
  describe "configure" do
    before(:all) do
      Palmade::Kanned.configure do
        init SPEC_ROOT, SPEC_ENV
        config "spec/config/kanned.yml"
        set_route "spec", :class_name => "TestGateway"
      end

      @init = Palmade::Kanned.init
    end

    it "should create an init object" do
      @init.should_not be_nil
      @init.should be_an_instance_of Palmade::Kanned::Init
    end

    after(:all) do

    end
  end
end
