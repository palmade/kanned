module Palmade::Kanned
  module Adapters
    class Smsbox
      DEFAULT_CONFIG = {

      }

      def initialize(gateway, config = { })
        @gateway = gateway
        @config = DEFAULT_CONFIG.merge(config)
      end

      # called when sending an sms
      def send_sms
      end

      # called when processing web requests (aka receiving sms)
      def call(env)
      end
    end
  end
end
