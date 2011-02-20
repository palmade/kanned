# -*- encoding: binary -*-

module Palmade::Kanned
  class Gateway
    DEFAULT_OPTIONS = {
      :cache_classes => true
    }

    attr_reader :gateway_key
    attr_reader :config
    attr_reader :options
    attr_reader :adapters
    attr_reader :adapter_keys
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
      @adapter_keys = [ ]
      @adapters_can_send = [ ]

      @controller_klass = nil
    end

    def call(msg_hash, env, path_params)
      controller_klass.perform(self, msg_hash, env, path_params)
    end

    def url_prefix
      "/#{gateway_key}".freeze
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

    def send_sms(number, message, sender_id = nil, adapter_keys = nil)
      adapter_for_sending(number, message, sender_id, adapter_keys) do |ad|
        if testing?
          logger.debug { "  !!! [TEST] Sending sms via #{ad.adapter_key} to #{number}: #{message}" }

          resp = [ true, "TESTING: Sent", nil ]
        else
          resp = ad.send_sms(number, message, sender_id)
        end
      end
    end

    protected

    def adapter_for_sending(number,
                            message,
                            sender_id = nil,
                            adapter_keys = nil,
                            &block)

      adapter_keys = adapter_keys_for_sending(adapter_keys)

      unless adapter_keys.empty?
        resp = nil

        adapter_keys.each do |ak|
          ad = adapter(ak)
          if ad.allowed_to_send?(number, message, sender_id)
            if block_given?
              resp = yield(ad)
            else
              resp = ad
            end

            break
          end
        end

        if resp.nil?
          raise CantSend, "None of the adapters are allowed to send to this number  #{number}"
        end

        resp
      else
        raise CantSend, "No adapter key specified or none of the adapters can send."
      end
    end

    def adapter_keys_for_sending(adapter_keys = nil)
      if adapter_keys.nil?
        adapter_keys = @adapters_can_send
      elsif !adapter_keys.is_a?(Array)
        adapter_keys = Adapters.which_can_send([ adapter_keys ])
      else
        adapter_keys = Adapters.which_can_send(adapter_keys)
      end
    end

    def testing?
      if defined?(@testing)
        @testing
      else
        @testing = config.include?("testing") && config["testing"]
      end
    end

    def controller_klass
      if !@options[:cache_classes] || @controller_klass.nil?
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
          @adapter_keys.push(adapter_key)
        end

        @adapters_can_send = Adapters.which_can_send(@adapter_keys)
      else
        raise ConfigError, "No adapters specified. Either no adapter set, or non-array, or empty"
      end
    end
  end
end
