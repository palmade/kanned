module Palmade::Kanned
  class Texter
    include Constants

    Cdeliver_prefix_regex = /\Adeliver\_(.+)\Z/.freeze

    def self.deliver(what, *args, &block)
      new.perform(what, *args, &block)
    end

    def perform(what, *args, &block)
      send(what, *args, &block);
    end

    protected

    def self.method_missing(method_name, *args, &block)
      method_name = method_name.to_s

      if method_name =~ Cdeliver_prefix_regex
        meth = $~[1]
        deliver(meth.to_sym, *args, &block)
      else
        super
      end
    end

    def self.set_gateway(gw_key); @@gateway_key = gw_key.to_s; end
    def self.gateway_key; @@gateway_key ||= nil; end

    def send_sms(number, message, sender_id = nil, adapter_key = nil)
      logger.debug do
        sprintf(Clogtextersending, number, message)
      end

      success, resp_text, resp =
        gateway.send_sms(number, message, sender_id, adapter_key)

      if success
        [ success, resp_text ]
      else
        raise SendSmsFail, "Unable to send sms, fail with http #{resp.code}, response #{resp_text}"
      end
    end

    def gateway
      if defined?(@gateway)
        @gateway
      elsif self.class.gateway_key.nil?
        raise "Gateway not set for this mailer: #{self.class.name}"
      else
        @gateway = Palmade::Kanned.init.gateways[self.class.gateway_key]
      end
    end

    def logger
      if defined?(@logger)
        @logger
      else
        @logger = gateway.logger
      end
    end
  end
end
