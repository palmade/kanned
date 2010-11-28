# -*- encoding: binary -*-
#
# Adapter for Kannel's smsbox daemon (http request)
#
#
# Here's a sample Rack ENV dump from an smsbox request:
#
# {"SERVER_SOFTWARE"=>"thin 1.2.7 codename No Hup",
#  "SERVER_NAME"=>"127.0.0.1",
#  "rack.input"=>#<StringIO:0x00000102ebd0b8>,
#  "rack.version"=>[1, 0],
#  "rack.errors"=>#<IO:<STDERR>>,
#  "rack.multithread"=>false,
#  "rack.multiprocess"=>false,
#  "rack.run_once"=>false,
#  "REQUEST_METHOD"=>"POST",
#  "REQUEST_PATH"=>"/kanndee/smsbox",
#  "PATH_INFO"=>"/kanndee/smsbox",
#  "REQUEST_URI"=>"/kanndee/smsbox",
#  "HTTP_VERSION"=>"HTTP/1.1",
#  "HTTP_HOST"=>"127.0.0.1:4000",
#  "HTTP_CONNECTION"=>"keep-alive",
#  "HTTP_USER_AGENT"=>"Kannel/svn-r",
#  "HTTP_X_KANNEL_FROM"=>"+639176327037",
#  "HTTP_X_KANNEL_TO"=>"+639274041798",
#  "HTTP_X_KANNEL_TIME"=>"2010-11-14 14:55:46",
#  "HTTP_DATE"=>"2010-11-28 05:54:36",
#  "HTTP_X_KANNEL_SMSC"=>"globe_smsc",
#  "HTTP_X_KANNEL_PID"=>"0",
#  "HTTP_X_KANNEL_ALT_DCS"=>"0",
#  "HTTP_X_KANNEL_CODING"=>"0",
#  "HTTP_X_KANNEL_COMPRESS"=>"0",
#  "HTTP_X_KANNEL_SERVICE"=>"default",
#  "CONTENT_LENGTH"=>"5",
#  "CONTENT_TYPE"=>"text/plain",
#  "GATEWAY_INTERFACE"=>"CGI/1.2",
#  "SERVER_PORT"=>"4000",
#  "QUERY_STRING"=>"",
#  "SERVER_PROTOCOL"=>"HTTP/1.1",
#  "rack.url_scheme"=>"http",
#  "SCRIPT_NAME"=>"",
#  "REMOTE_ADDR"=>"127.0.0.1",
#  "async.callback"=>
#   #<Method: Palmade::PuppetMaster::ThinConnection#post_process>,
#  "async.close"=>#<EventMachine::DefaultDeferrable:0x00000102ebc2f8>,
#  "KANNED_GATEWAY_PATH"=>"/kanndee",
#  "KANNED_GATEWAY_KEY"=>"kanndee",
#  "KANNED_ADAPTER_KEY"=>"smsbox",
#  "KANNED_PATH_PARAMS"=>nil}
#

module Palmade::Kanned
  module Adapters
    class Smsbox < Base
      DEFAULT_CONFIG = {

      }

      def initialize(gw, adapter_key, config = { })
        super(gw, adapter_key, DEFAULT_CONFIG.merge(config))
      end

      # called when processing web requests (aka receiving sms)
      def parse_request(env, path_params)
        validate_request!(env, path_params)
        parse_message_hash(env, path_params)
      end

      protected

      def validate_request!(env, path_params)
        [ CHTTP_X_KANNEL_FROM,
          CHTTP_X_KANNEL_TO,
          CHTTP_X_KANNEL_SMSC,
          CHTTP_X_KANNEL_TIME ].each do |k|
          if !env.include?(k) || env[k].empty?
            raise MalformedRequest, "Invalid header value for #{k} #{env[k]}"
          end
        end
      end

      Cslash = '/'.freeze
      Ccoding0 = '0'.freeze
      Ccoding1 = '1'.freeze
      Ccoding2 = '2'.freeze
      def parse_message_hash(env, path_params)
        msg_hash = empty_message_hash

        msg_hash[CMESSAGE_ID], *rest = path_params.split(Cslash, 2)
        msg_hash[CMESSAGE_ID].freeze

        msg_hash[CSENDER_NUMBER] = env[CHTTP_X_KANNEL_FROM].dup.freeze
        msg_hash[CRECIPIENT_NUMBER] = env[CHTTP_X_KANNEL_TO].dup.freeze
        msg_hash[CRECIPIENT_ID] = env[CHTTP_X_KANNEL_SMSC].dup.freeze
        msg_hash[CRECEIVED_AT] = Time.parse(env[CHTTP_X_KANNEL_TIME]).utc.freeze

        bd = env[Crack_input]
        bd.rewind

        case coding = env[CHTTP_X_KANNEL_CODING]
        when Ccoding0
          msg_hash[CMESSAGE] = bd.read.force_encoding(CEncUTF8).freeze
        when Ccoding1
          msg_hash[CMESSAGE] = bd.read.force_encoding(CEncBINARY).freeze
        when Ccoding2
          msg_hash[CMESSAGE] = bd.read.force_encoding(CEncUTF16BE).encode(CEncUTF8).freeze
        else
          raise UnsupportedEncoding, "Unsupported encoding #{coding}"
        end

        bd.rewind

        msg_hash[CREMOTE_ADDR] = env[CREMOTE_ADDR].dup.freeze
        msg_hash[CUSER_AGENT] = env[CHTTP_USER_AGENT].dup.freeze
        msg_hash[CREQUESTED_AT] = Time.now.utc.freeze
        msg_hash[CQUERY_STRING] = env[CQUERY_STRING].dup.freeze

        msg_hash[CKANNED_GATEWAY_PATH] = env[CKANNED_GATEWAY_PATH]
        msg_hash[CKANNED_GATEWAY_KEY] = env[CKANNED_GATEWAY_KEY]
        msg_hash[CKANNED_ADAPTER_KEY] = env[CKANNED_ADAPTER_KEY]
        msg_hash[CKANNED_PATH_PARAMS] = env[CKANNED_PATH_PARAMS]

        # return message hash
        [ msg_hash, env, path_params ]
      end
    end
  end
end
