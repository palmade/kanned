# -*- encoding: utf-8 -*-
#
require 'rack/request'
require 'rack/utils'

=begin
rack.env:

{"SERVER_SOFTWARE"=>"thin 1.2.7 codename No Hup",
  "SERVER_NAME"=>"potato.markjeee.com",
  "rack.input"=>#<StringIO:0x00000102d6ddc0>,
  "rack.version"=>[1, 0],
  "rack.errors"=>#<IO:<STDERR>>,
  "rack.multithread"=>false,
  "rack.multiprocess"=>false,
  "rack.run_once"=>false,
  "REQUEST_METHOD"=>"POST",
  "REQUEST_PATH"=>"/kanndee/tropo",
  "PATH_INFO"=>"/kanndee/tropo",
  "REQUEST_URI"=>"/kanndee/tropo",
  "HTTP_VERSION"=>"HTTP/1.0",
  "HTTP_REFERER"=>"",
  "HTTP_HOST"=>"potato.markjeee.com:4000",
  "HTTP_CONNECTION"=>"Keep-Alive",
  "HTTP_USER_AGENT"=>"Apache-HttpClient/4.0 (java 1.5)",
  "CONTENT_LENGTH"=>"807",
  "CONTENT_TYPE"=>"application/json",
  "GATEWAY_INTERFACE"=>"CGI/1.2",
  "SERVER_PORT"=>"4000",
  "QUERY_STRING"=>"",
  "SERVER_PROTOCOL"=>"HTTP/1.1",
  "rack.url_scheme"=>"http",
  "SCRIPT_NAME"=>"",
  "REMOTE_ADDR"=>"127.0.0.1",
  "async.callback"=>
  #<Method: Palmade::PuppetMaster::ThinConnection#post_process>,
  "async.close"=>#<EventMachine::DefaultDeferrable:0x00000102d6d6b8>,
  "KANNED_GATEWAY_PATH"=>"/kanndee",
  "KANNED_GATEWAY_KEY"=>"kanndee",
  "KANNED_ADAPTER_KEY"=>"tropo",
  "KANNED_PATH_PARAMS"=>nil}

rack.input:

{"session"=>
  {"id"=>"xxxxx",
   "accountId"=>"xxxxx",
   "timestamp"=>"2011-02-19T12:41:02.238Z",
   "userType"=>"HUMAN",
   "initialText"=>"Test msg, one, two, three",
   "callId"=>"xxxx",
   "to"=>
    {"id"=>"xxxxx", "name"=>nil, "channel"=>"TEXT", "network"=>"SMS"},
   "from"=>{"id"=>"xxxxx", "name"=>nil, "channel"=>"TEXT", "network"=>"SMS"},
   "headers"=>
    {"Max-Forwards"=>"70",
     "Content-Length"=>"124",
     "Contact"=>"<sip:10.6.93.101:5066;transport=udp>",
     "To"=>"<sip:9991471551@10.6.69.203:5061;to=xxxxx>",
     "CSeq"=>"1 INVITE",
     "Via"=>"SIP/2.0/UDP 10.6.93.101:5066;branch=z9hG4bKoz41kf",
     "Call-ID"=>"xxxxx",
     "Content-Type"=>"application/sdp",
     "From"=>
      "<sip:xxxxx0@10.6.61.201;channel=private;user=xxxxx;msg=Test%20msg%2c%20one%2c%20two%2c%20three;network=SMS;step=2>;tag=voznz9"}}}

=end

module Palmade::Kanned
  module Adapters
    class Tropo < Base
      DEFAULT_CONFIG = {

      }

      CTROPO_SESSION = 'TROPO_SESSION'.freeze

      Csession = 'session'.freeze
      Cid = 'id'.freeze
      Cto = 'to'.freeze
      Cfrom = 'from'.freeze
      CaccountId = 'accountId'.freeze
      Ctimestamp = 'timestamp'.freeze
      CinitialText = 'initialText'.freeze
      Cplus = '+'.freeze
      CSMS = 'SMS'.freeze
      Cnetwork = 'network'.freeze
      Cmessage = 'message'.freeze
      Csession_type = 'session_type'.freeze
      Csend_sms = 'send_sms'.freeze

      def initialize(gw, adapter_key, config = { })
        super(gw, adapter_key, DEFAULT_CONFIG.merge(config))

        if @config.include?(Caccount_id)
          @account_id = @config[Caccount_id]
        else
          raise ConfigError, "Please specify the account id in the config file"
        end

        if defined?(::Yajl)
          @json_parser = Yajl::Parser
          @json_encoder = Yajl::Encoder
        elsif defined?(::JSON)
          @json_parser = JSON
          @json_encoder = JSON
        else
          raise KannedError, "You'll need to load a JSON parser to use this adapter"
        end
      end

      # called when processing web requests (aka receiving sms)
      def parse_request(env, path_params)
        validate_request!(env, path_params)
        parse_message_hash(env, path_params)
      end

      def post_process(env, path_params, msg_hash, performed, response)
        if performed
          bd = response[2]
          unless bd.nil?
            bd = bd.collect { |s| s }.join

            tro = tropo_say(bd)
            tro = tropo_hangup(tro)

            response = respond(tro)
          end
        elsif msg_hash.nil? && env.include?(CTROPO_SESSION)
          session = env[CTROPO_SESSION]
          params = session[Cparameters]
          session_type = params[Csession_type]

          case session_type
          when Csend_sms
            to = params[Cto]
            msg = params[Cmessage]

            if !to.nil? && !msg.nil? && !to.empty? && !msg.empty?
              tro = tropo_call(to)
              tro = tropo_say(msg, tro)
              tro = tropo_hangup(tro)

              response = respond(tro)
            else
              response = respond(tropo_hangup)
            end
          else
            response = respond(tropo_hangup)
          end

          performed = true
        end

        [ performed, response ]
      end

      def send_sms(number, message, sender_id = nil)
        check_can_send!
        send_sms_post(number, message, sender_id)
      end

      protected

      def check_can_send!
        [ Capi_url,
          Cmessaging_token ].each do |k|
          if !@config.include?(k) || @config[k].nil? || @config[k].empty?
            raise CantSend, "Send sms configuration not complete"
          end
        end
      end

      Ctoken = 'token'.freeze
      Csender_id = 'sender_id'.freeze
      def send_sms_post(number, message, sender_id)
        api_url = @config[Capi_url]
        token = @config[Cmessaging_token]

        params = {
          Ctoken => token,
          Csession_type => Csend_sms,
          Cto => number,
          Cmessage => message,
          Csender_id => sender_id
        }

        handle_resp!(http.post(api_url, params))
      end

      Csuccess = 'success'.freeze
      def handle_resp!(resp)
        case resp.code
        when 200
          resp_params = Rack::Utils.parse_query(resp.read.strip)

          if resp_params[Csuccess] == Ctrue
            [ true, resp_params, resp ]
          else
            [ false, resp_params, resp ]
          end
        else
          [ false, resp.read, resp ]
        end
      end

      def validate_request!(env, path_params)
        bd = env[Crack_input]
        bd.rewind
        input = @json_parser.parse(bd.read.force_encoding(CEncUTF8).freeze)
        bd.rewind

        if input.include?(Csession)
          session = input[Csession]

          if session[CaccountId] != @account_id
            raise InvalidRequest, "Account id #{session[CaccountId]} is wrong, expected #{@account_id}"
          end

          env[CTROPO_SESSION] = session
        else
          raise MalformedRequest, "Tropo request do not contain session information"
        end
      end

      def parse_message_hash(env, path_params)
        session = env[CTROPO_SESSION]

        msg_hash = nil
        if session.include?(Cparameters) &&
            session[Cparameters].include?(Csession_type)
          # do nothing, we'll have post_process deal with this.
          #
        elsif !session[CinitialText].nil? &&
            session.include?(Cfrom) &&
            session.include?(Cto)

          if session[Cfrom][Cnetwork] != CSMS
            raise MalformedRequest, "Only SMS messages are supported"
          end

          msg_hash = empty_message_hash(CSMS)

          msg_hash[CMESSAGE_ID] = session[Cid].dup.freeze

          msg_hash[CSENDER_NUMBER] = (Cplus + session[Cfrom][Cid]).freeze
          msg_hash[CRECIPIENT_NUMBER] = (Cplus + session[Cto][Cid]).freeze
          msg_hash[CRECIPIENT_ID] = session[CaccountId].dup.freeze
          msg_hash[CRECEIVED_AT] = Time.parse(session[Ctimestamp]).utc.freeze

          msg_hash[CMESSAGE] = session[CinitialText].dup.freeze

          msg_hash[CREMOTE_ADDR] = env[CREMOTE_ADDR].dup.freeze
          msg_hash[CUSER_AGENT] = env[CHTTP_USER_AGENT].dup.freeze
          msg_hash[CREQUESTED_AT] = Time.now.utc.freeze
          msg_hash[CQUERY_STRING] = env[CQUERY_STRING].dup.freeze

          msg_hash[CKANNED_GATEWAY_PATH] = env[CKANNED_GATEWAY_PATH]
          msg_hash[CKANNED_GATEWAY_KEY] = env[CKANNED_GATEWAY_KEY]
          msg_hash[CKANNED_ADAPTER_KEY] = env[CKANNED_ADAPTER_KEY]
          msg_hash[CKANNED_PATH_PARAMS] = env[CKANNED_PATH_PARAMS]
        end

        [ msg_hash, env, path_params ]
      end

      Ccall = "call".freeze
      def tropo_call(to, tro = nil)
        tro = create_tropo if tro.nil?
        tro[Ctropo] << { Ccall => { Cto => [ to ], Cnetwork => CSMS } }
        tro
      end

      Csay = "say".freeze
      Cvalue = "value".freeze
      def tropo_say(bd, tro = nil)
        tro = create_tropo if tro.nil?
        tro[Ctropo] << { Csay => [ { Cvalue => bd } ] }
        tro
      end

      Changup = "hangup".freeze
      def tropo_hangup(tro = nil)
        tro = create_tropo if tro.nil?
        tro[Ctropo] << { Changup => nil }
        tro
      end

      Ctropo = "tropo".freeze
      def create_tropo
        { Ctropo => [ ] }
      end

      def respond(tro)
        [ 200,
          {
            CContentType => CCTapplication_json
          },
          [ @json_encoder.encode(tro) ] ]
      end

      def http
        Palmade::Kanned::Http
      end
    end
  end
end
