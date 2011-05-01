module Palmade::Kanned
  module Adapters
    class Clickatell < Base

      CsendSMSPath = 'sendmsg'.freeze

      Capi_id = 'api_id'.freeze
      Cuser = 'user'.freeze
      Cpassword = 'password'.freeze
      Csender_id = 'sender_id'.freeze

      Cto = 'to'.freeze
      Cfrom = 'from'.freeze
      Ctext = 'text'.freeze
      Cplus = '+'.freeze

      def initialize(gw, adapter_key, config = { })
        super
        @send_sms_url = URI.join(@config[Capi_url], CsendSMSPath)
      end

      def send_sms(number, message, sender_id = nil)
        check_can_send!

        params = {
          Capi_id => @config[Capi_id],
          Cuser => @config[Cuser],
          Cpassword => @config[Cpassword],
          Cto => number.delete(Cplus),
          Ctext => message,
          Cfrom => @config[Csender_id]
        }

        handle_resp!(http.post(@send_sms_url, params))
      end

      protected

      def check_can_send!
        [ Capi_url,
          Capi_id,
          Cuser,
          Cpassword ].each do |k|
          if !@config.include?(k) || @config[k].nil? || @config[k].empty?
            raise CantSend, "Send sms configuration not complete"
          end
        end
      end

      def handle_resp!(resp)
        case resp.code
        when 200
          if resp.body.scan(/ERR/).any?
            [ false, resp ]
          else
            [ true, resp ]
          end
        else
          [ false, resp ]
        end
      end
    end
  end
end
