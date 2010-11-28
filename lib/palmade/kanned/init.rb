module Palmade::Kanned
  class Init
    attr_reader :root_path
    attr_reader :env
    attr_reader :config
    attr_reader :gateways

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

      @routes = { }
      @gateways = { }
    end

    def set_logger(l)
      @logger.close unless @logger.nil?
      @logger = nil
      @logger = l
    end

    # reads and loads config files from config/kanned.yml file
    def configure(config_path = nil)
      config_path = File.join(@root_path, config_path || CDEFAULT_CONFIG_PATH)
      if File.exists?(config_path)
        @config = Config.load_file(config_path)
      else
        raise "Config file not found. Expected: #{config_path}"
      end
    end

    def finalize
      # build gateways, with routes and mapping
      unless @routes.empty?
        @routes.each do |gw_k, gw_opts|
          if @config.gateways.include?(gw_k)
            @gateways[gw_k] = Gateway.create(self,
                                             gw_k,
                                             gw_opts,
                                             @config.gateways[gw_k])
          else
            raise "Found no configuration for route #{gw_k}"
          end
        end
      else
        raise "Routes is empty. Please set some active gateway routes for this Kanned instance."
      end
    end

    def set_route(gw_k, route_opts = { })
      @routes[gw_k.to_s.dup.freeze] = route_opts.dup
    end

    def logger
      if @logger.nil?
        @logger = Logger.new(File.join(@root_path, CDEFAULT_LOG_PATH))
      else
        @logger
      end
    end

    def gw(gw_k)
      @gateways[gw_k]
    end
  end
end
