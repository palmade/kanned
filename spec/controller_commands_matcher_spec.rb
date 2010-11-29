require File.expand_path('../spec_helper', __FILE__)

context "controller" do
  describe "commands matcher" do
    class TestControllerCommands < Palmade::Kanned::Controller
    end

    class AnotherTestControllerCommands < Palmade::Kanned::Controller
    end

    before(:all) do
      Palmade::Kanned.configure do
        init SPEC_ROOT, SPEC_ENV
        config "spec/config/kanned.yml"
        set_route "test", :class_name => "TestController"
      end

      @klass = TestControllerCommands
      @klass.class_eval do

      end
    end

    it "should match commands" do
      regex = Palmade::Kanned::Controller::COMMAND_REGEXP_MATCHER

      [ "/hello",
        "/hello world",
        "  /hello world",
        "  /hello world  ",
        "\n/hello world",
        "\n/hello world\n",
        "\n/hello world\n/hello",
        "/HelLo world",
        "/HELLO world"
      ].each do |t|
        t.should =~ regex
        t =~ regex
        $~[1].downcase.should == "hello"
      end
    end

    it "should match commands and arguments" do
      regex = Palmade::Kanned::Controller::COMMAND_REGEXP_MATCHER

      "/hello world1" =~ regex
      $~[1].should == "hello"
      $~[3].should == "world1"

      "  /hello       world2" =~ regex
      $~[1].should == "hello"
      $~[3].should == "world2"

      "/hello      world3" =~ regex
      $~[1].should == "hello"
      $~[3].should == "world3"

      "/hello   world4  " =~ regex
      $~[1].should == "hello"
      $~[3].should == "world4  "

      "\n/hello world" =~ regex
      $~[1].should == "hello"
      $~[3].should == "world"

      "/hello\t\nworld" =~ regex
      $~[1].should == "hello"
      $~[3].should == "world"
    end

    it "should not match wrong commands or malformed keywords" do
      regex = Palmade::Kanned::Controller::COMMAND_REGEXP_MATCHER

      [ "/hello.world",
        "./hello",
        "  /hello: world",
        "/ hello",
        "\n/hello.",
        "/hello%",
        "/hello_ world",
        "/hello. world",
        "/9hello",
        "/9hello world",
        "/HelLo. world",
        "not /hello first",
        "not\n/hello second"
      ].each do |t|
        t.should_not =~ regex
      end
    end

    it "should match 3chars shortcodes" do
      regex = Palmade::Kanned::Controller::SHORTCODE_3CHARS_MATCHER

      [ "abc",
        "abc world",
        "  abc world",
        "abc world  ",
        "abc     world ",
        "\nabc world\n",
        "\t\nabc world\t\nworld",
        "ABC world",
        "aBc world",
        "Abc world",
        "aBC world"
      ].each do |t|
        t.should =~ regex
        t =~ regex; $~[1].downcase.should == "abc"
      end
    end

    it "should match 4chars shortcodes" do
      regex = Palmade::Kanned::Controller::SHORTCODE_4CHARS_MATCHER

    end

    after(:all) do

    end
  end
end
