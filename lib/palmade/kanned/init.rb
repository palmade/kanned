module Palmade::Kanned
  class Init
    attr_reader :root_path
    attr_reader :env
    attr_reader :config

    CDEFAULT_LOG_PATH = "log/kanned.log".freeze
    CDEFAULT_CONFIG_PATH = "config/kanned.yml".freeze

    def self.init(root_path, env)
      Palmade::Kanned.init = self.new(root_path, env)
    end

    def initialize(root_path, env)
      @root_path = root_path
      @env = env
      @logger = nil
      @config = nil
    end

    def set_logger(l)
      @logger.close unless @logger.nil?
      @logger = nil
      @logger = l
    end

    # reads and loads config files from config/kanned.yml file
    def configure(config_path = nil)
      # TODO
    end

    def logger
      if @logger.nil?
        @logger = Logger.new(File.join(@root_path, CDEFAULT_LOG_PATH))
      else
        @logger
      end
    end
  end
end
