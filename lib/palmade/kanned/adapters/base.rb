# -*- encoding: binary -*-

module Palmade::Kanned
  module Adapters
    class Base
      include Constants

      DEFAULT_CONFIG = {

      }

      # == SAMPLE MESSAGE hash after being parsed by an adapter
      DEFAULT_MESSAGE_HASH = {
        CMESSAGE_TYPE => nil,
        CMESSAGE_ID => nil,

        # == Message details
        CSENDER_NUMBER => nil, # "+631231234567"
        CRECIPIENT_NUMBER => nil, # "+631231234567"
        CRECIPIENT_ID => nil, # "globe_smsc"
        # in utc, format
        CRECEIVED_AT => nil,
        # encoded, in binary format
        CMESSAGE => nil,
        CSUBJECT => nil,

        # if this is an MMS message
        CATTACHMENTS => nil,

        # == Internal request details
        CREMOTE_ADDR => nil, # "127.0.0.1"
        CUSER_AGENT => nil, # "Kannel/svn-r"
        # when kanned received the message, in utc format
        CREQUESTED_AT => nil,
        # query string of the request
        CQUERY_STRING => nil,

        CKANNED_GATEWAY_PATH => nil, # "/kanndee"
        CKANNED_GATEWAY_KEY => nil, # "kanndee"
        CKANNED_ADAPTER_KEY => nil, # "smsbox"
        CKANNED_PATH_PARAMS => nil
      }

      def self.create(gw, adapter_key, config = { })
        self.new(gw, adapter_key, config).build!
      end

      def initialize(gw, adapter_key, config = { })
        @gateway = gw
        @adapter_key = adapter_key
        @config = config
      end

      def build!
        self
      end

      def parse_request(env, path_params = nil)
        raise NotImplemented, "parse_request method not implemented"
      end

      def send_sms(number, message, sender_id)
        raise NotImplemented, "send_sms method not implemented"
      end

      def post_process(env, path_params, msg_hash, performed, response)
        [ performed, response ]
      end

      protected

      def empty_message_hash(mtype = CSMS)
        { CMESSAGE_TYPE => mtype }.merge(DEFAULT_MESSAGE_HASH)
      end
    end
  end
end
