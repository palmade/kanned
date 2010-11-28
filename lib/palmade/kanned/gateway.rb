# -*- encoding: binary -*-

module Palmade::Kanned
  class Gateway
    DEFAULT_OPTIONS = {

    }

    attr_reader :gateway_key
    attr_reader :config
    attr_reader :options
    attr_reader :adapters
    attr_reader :logger

    def self.create(init, gw_k, gw_opts, config)
      self.new(init, gw_k, gw_opts, config).build!
    end

    def initialize(init, gw_k, gw_opts, config)
      @logger = init.logger
      @gateway_key = gw_k
      @options = DEFAULT_OPTIONS.merge(gw_opts)
      @config = config
      @adapters = { }
      @controller_klass = nil
    end

    def call(msg_hash, env, path_params)
      controller_klass.perform(self, msg_hash, env, path_params)
    end

    def url_prefix
      "/#{gateway_key}"
    end

    def build!
      build_adapters!

      self
    end

    # Returns the adapter instance for a given adapter key
    def adapter(adapter_key)
      if @adapters.include?(adapter_key)
        @adapters[adapter_key]
      else
        raise UnknownAdapter, "Unknown adapter key #{adapter_key}"
      end
    end

    protected

    def controller_klass
      if @controller_klass.nil?
        controller_name = @options[:class_name]
        unless controller_name.nil?
          @controller_klass = eval(controller_name, TOPLEVEL_BINDING)
        else
          raise ArgumentError, "Controller class name not defined"
        end
      else
        @controller_klass
      end
    end

    def build_adapters!
      if @config.include?('adapters') &&
          @config['adapters'].is_a?(Array) &&
          !@config['adapters'].empty?

        @config['adapters'].each do |adapter_key|
          adapter_key = adapter_key.to_s.dup.freeze

          if @config.include?(adapter_key) &&
              !@config[adapter_key].nil?
            adapter_options = @config[adapter_key]
          else
            adapter_options = { }
          end

          @adapters[adapter_key] = Palmade::Kanned::Adapters.create(self, adapter_key, adapter_options)
        end

      else
        raise ConfigError, "No adapters specified. Either no adapter set, or non-array, or empty"
      end
    end
  end
end
