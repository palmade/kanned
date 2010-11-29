require File.expand_path('../spec_helper', __FILE__)

context "controller" do
  describe "perform" do
    class PerformControllerCommands < Palmade::Kanned::Controller
    end

    before(:all) do
      Palmade::Kanned.configure do
        init SPEC_ROOT, SPEC_ENV
        config "spec/config/kanned.yml"
        set_route "test", :class_name => "PerformControllerCommands"
      end

      @init = Palmade::Kanned.init
      @gateway = @init.gateways["test"]

      @klass = PerformControllerCommands
      @klass.class_eval do
        command "hello" do
          reply "world"
        end

        shortcode "code" do
          reply "hacker #{cmd_params.strip}"
        end

        shortcode "hack", :hacker
        def hacker
          reply "code #{cmd_params.strip} sent with #{cmd_key}"
        end

        def perform_message
          reply "Hello World"
        end
      end
    end

    it "should respond to normal message" do
      controller = @klass.new(@gateway)
      mhash = {
        "MESSAGE" => "test message"
      }

      performed, response = controller.perform(mhash, { }, nil)
      performed.should be_true
      controller.instance_variable_get(:@reply).should == "Hello World"
      response[0].should == 200
      response[2].should_not be_nil
    end

    it "should respond to 'hello' command" do
      controller = @klass.new(@gateway)
      mhash = {
        "MESSAGE" => "/hello"
      }

      performed, response = controller.perform(mhash, { }, nil)
      performed.should be_true
      controller.instance_variable_get(:@reply).should == "world"
      response[0].should == 200
      response[2].should_not be_nil
    end

    it "should respond with error when passed the wrong command" do
      controller = @klass.new(@gateway)
      mhash = {
        "MESSAGE" => "/wrong command"
      }

      performed, response = controller.perform(mhash, { }, nil)
      performed.should be_true
      controller.instance_variable_get(:@reply).should == "Invalid command wrong"
      response[0].should == 200
      response[2].should_not be_nil
    end

    it "should respond to 'code' shortcode" do
      controller = @klass.new(@gateway)
      mhash = {
        "MESSAGE" => "code review"
      }

      performed, response = controller.perform(mhash, { }, nil)
      performed.should be_true
      controller.instance_variable_get(:@reply).should == "hacker review"
      response[0].should == 200
      response[2].should_not be_nil
    end

    it "should respond to 'hack' shortcode" do
      controller = @klass.new(@gateway)
      mhash = {
        "MESSAGE" => "hack you"
      }

      performed, response = controller.perform(mhash, { }, nil)
      performed.should be_true
      controller.instance_variable_get(:@reply).should == "code you sent with hack"
      response[0].should == 200
      response[2].should_not be_nil
    end

    after(:all) do

    end
  end
end
