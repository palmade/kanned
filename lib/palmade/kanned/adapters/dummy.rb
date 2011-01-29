require 'rack/request'
require 'rack/utils'

module Palmade::Kanned
  module Adapters
    class Dummy < Base
      DEFAULT_CONFIG = {

      }

      def initialize(gw, adapter_key, config = { })
        super(gw, adapter_key, DEFAULT_CONFIG.merge(config))
      end

      # called when processing web requests (aka receiving sms)
      def parse_request(env, path_params)
        if env[CREQUEST_METHOD] == CPOST
          parse_message_hash(env, path_params)
        else
          [ nil, env, path_params ]
        end
      end

      def post_process(env, path_params, msg_hash, performed, response)
        case env[CREQUEST_METHOD]
        when CGET
          performed, response = true, reply_html(sms_form)
        when CPOST
          if performed
            performed, response = true, reply_html(sms_form(msg_hash, response))
          else
            performed, response = true, reply_html(sms_form)
          end
        end

        [ performed, response ]
      end

      protected

      def parse_message_hash(env, path_params)
        msg_hash = nil

        req = Rack::Request.new(env)
        if req.form_data?
          sender_number = req.params['sender_number']
          message = req.params['message']

          unless sender_number.nil? || sender_number.empty?
            msg_hash = empty_message_hash

            msg_hash[CSENDER_NUMBER] = sender_number.dup.freeze
            unless message.nil?
              msg_hash[CMESSAGE] = message.dup.freeze
            else
              msg_hash[CMESSAGE] = nil
            end

            msg_hash[CMESSAGE_ID] = "XXXX".freeze
            msg_hash[CRECIPIENT_ID] = "XXXX".freeze
            msg_hash[CRECIPIENT_NUMBER] = "XXXX".freeze
            msg_hash[CRECEIVED_AT] = Time.now.utc.freeze

            msg_hash[CREMOTE_ADDR] = env[CREMOTE_ADDR].dup.freeze
            msg_hash[CUSER_AGENT] = env[CHTTP_USER_AGENT].dup.freeze
            msg_hash[CREQUESTED_AT] = Time.now.utc.freeze
            msg_hash[CQUERY_STRING] = env[CQUERY_STRING].dup.freeze

            msg_hash[CKANNED_GATEWAY_PATH] = env[CKANNED_GATEWAY_PATH]
            msg_hash[CKANNED_GATEWAY_KEY] = env[CKANNED_GATEWAY_KEY]
            msg_hash[CKANNED_ADAPTER_KEY] = env[CKANNED_ADAPTER_KEY]
            msg_hash[CKANNED_PATH_PARAMS] = env[CKANNED_PATH_PARAMS]
          else
            raise IncompleteRequest, "Please specify a sender number"
          end
        else
          raise MalformedRequest, "Got a POST request without form data"
        end

        [ msg_hash, env, path_params ]
      end

      def sms_form(msg_hash = nil, response = nil)
        smsf = ""

        unless msg_hash.nil?
          sender_number = msg_hash[CSENDER_NUMBER]
          message = msg_hash[CMESSAGE]
        else
          sender_number = nil
          message
        end

        unless response.nil?
          smsf += <<SMSFORM
<p>Message: #{message}</p>
<p>Response:<br />#{Rack::Utils.escape_html(response.inspect)}</p>
SMSFORM
        end

        smsf += <<SMSFORM
<form method="POST">
<p>Sender:<br /><input type="text" name="sender_number" value="#{sender_number}" /></p>
<p>Message:<br /><textarea name="message" rows="10" cols="40"></textarea></p>
<p><input type="submit" value="Send"></p>
</form>
SMSFORM
      end

      def reply_html(html)
        body = <<HTML
<html>
<head>
</head>
<body>
#{html}
</body>
</html>
HTML

        [ 200,
          { CContentType => CCTtext_html },
          [ body ] ]
      end
    end
  end
end
