require File.expand_path('../spec_helper', __FILE__)

context "controller" do
  describe "commands" do
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
        command "hello" do
          reply "Hello World"
        end

        shortcode "info" do
          reply "Info info info"
        end
      end
    end

    it "should define a new controller class" do
      @klass.should_not be_nil
    end

    it "should define a 'hello' command" do
      @klass.text_commands.should_not be_empty
      @klass.text_commands.should include "hello"
      @klass.text_commands.should_not include "info"
      @klass.instance_methods.should include :_command_hello

      cmd_data = @klass.text_commands["hello"]
      cmd_data[0].should == "hello"
      cmd_data[0].frozen?.should be_true
      cmd_data[1].should be_instance_of Regexp
      cmd_data[1].should =~ "/hello"
      cmd_data[1].should_not =~ "hello"
      cmd_data[2].should == :_command_hello
      cmd_data[3].should be_instance_of Hash
      cmd_data[3].should be_empty
    end

    it "should define a 'info' shortcode" do
      @klass.text_shortcodes.should_not be_empty
      @klass.text_shortcodes.should include "info"
      @klass.text_shortcodes.should_not include "hello"
      @klass.instance_methods.should include :_shortcode_info

      code_data = @klass.text_shortcodes["info"]
      code_data[0].should == "info"
      code_data[0].frozen?.should be_true
      code_data[1].should be_instance_of Regexp
      code_data[1].should =~ "info"
      code_data[1].should_not =~ "/info"
      code_data[2].should == :_shortcode_info
      code_data[3].should be_instance_of Hash
      code_data[3].should be_empty
    end

    it "should match the command keyword" do
      regex = @klass.text_commands["hello"][1]

      [ "/hello",
        "/hello   ",
        "/hello\n",
        "/hello\nhoho",
        "/hello\n\t",
        "/hello\t\n",
        "\n/hello",
        "\n/hello\n",
        "/hello world",
        "  /hello",
        "  /hello  ",
        "  /hello     world    test"
      ].each do |t|
        t.should =~ regex
        t =~ regex; $~[1].should == "hello"
      end
    end

    it "should not match non-command keywords" do
      regex = @klass.text_commands["hello"][1]

      [ "/hellos",
        "  /hello-s",
        " /hello.s",
        "a/hello z",
        "hello",
        "hello     ",
        "hello\n",
        "hello\n\t",
        "hello\t\n",
        "   hello  ",
        "   world hello ",
        "world hello",
        "test hello    "
      ].each do |t|
        t.should_not =~ regex
      end
    end

    it "should match the shortcode keyword" do
      regex = @klass.text_shortcodes["info"][1]

      [ "info",
        "  info",
        "info  ",
        "info\t",
        "info\t\n",
        "info\n\t",
        "\ninfo\n",
        "info\nworld\ninfo",
        "info  world",
        "info world\nworld",
        "info info info",
        "\ninfo world info"
      ].each do |t|
        t.should =~ regex
        t =~ regex; $~[1].should == "info"
      end
    end

    it "should not match non-shortcode keyword" do
      regex = @klass.text_shortcodes["info"][1]

      [ "infos",
        "sinfo",
        "/info",
        "info.",
        ".info",
        "info.world ",
        ".info world",
        "  infos",
        "  infos  ",
        "world info",
        "s info",
        "\ninfos",
        "\nsinfo world"
      ].each do |t|
        t.should_not =~ regex
      end
    end

    it "should not leak to other class" do
      klass = ::Palmade::Kanned::Controller
      klass.text_commands.should be_nil
      klass.text_shortcodes.should be_nil

      klass = ::AnotherTestControllerCommands
      klass.text_commands.should be_nil
      klass.text_shortcodes.should be_nil
    end

    after(:all) do

    end
  end
end
