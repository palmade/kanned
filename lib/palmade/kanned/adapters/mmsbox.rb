require 'pp'
require 'rack/request'

# ===== ENV ====
# {"SERVER_SOFTWARE"=>"thin 1.2.7 codename No Hup",
#  "SERVER_NAME"=>"localhost",
#  "rack.input"=>#<StringIO:0x00000102e3f168>,
#  "rack.version"=>[1, 0],
#  "rack.errors"=>#<IO:<STDERR>>,
#  "rack.multithread"=>false,
#  "rack.multiprocess"=>false,
#  "rack.run_once"=>false,
#  "REQUEST_METHOD"=>"POST",
#  "REQUEST_PATH"=>"/kanndee/mmsbox",
#  "PATH_INFO"=>"/kanndee/mmsbox",
#  "REQUEST_URI"=>"/kanndee/mmsbox",
#  "HTTP_VERSION"=>"HTTP/1.1",
#  "HTTP_HOST"=>"localhost:4000",
#  "HTTP_CONNECTION"=>"keep-alive",
#  "HTTP_USER_AGENT"=>"Mbuni/cvs-20100809",
#  "HTTP_X_MBUNI_MESSAGE_ID"=>"217FED48-08F8-71E0-B083-000000000000",
#  "HTTP_X_MBUNI_MMSC_ID"=>"globe_mmsc",
#  "HTTP_X_MBUNI_FROM"=>"+639176327037",
#  "HTTP_X_MBUNI_SUBJECT"=>"This is me",
#  "HTTP_X_MBUNI_TRANSACTIONID"=>"Mbuni-i-ch-qf2285.12.x180.73",
#  "HTTP_X_MBUNI_TO"=>"+639275601597",
#  "HTTP_X_MBUNI_MESSAGE_DATE"=>"Thu, 16 Dec 2010 09:37:42 GMT",
#  "HTTP_X_MBUNI_RECEIVED_DATE"=>"Thu, 16 Dec 2010 09:38:05 GMT",
#  "HTTP_MIME_VERSION"=>"1.0",
#  "CONTENT_LENGTH"=>"56175",
#  "CONTENT_TYPE"=>
#   "multipart/form-data; boundary=_boundary_1598245182_1292492289_D_l_bd975466932",
#  "GATEWAY_INTERFACE"=>"CGI/1.2",
#  "SERVER_PORT"=>"4000",
#  "QUERY_STRING"=>"",
#  "SERVER_PROTOCOL"=>"HTTP/1.1",
#  "rack.url_scheme"=>"http",
#  "SCRIPT_NAME"=>"",
#  "REMOTE_ADDR"=>"127.0.0.1",
#  "async.callback"=>
#   #<Method: Palmade::PuppetMaster::ThinConnection#post_process>,
#  "async.close"=>#<EventMachine::DefaultDeferrable:0x00000102e2a768>,
#  "KANNED_GATEWAY_PATH"=>"/kanndee",
#  "KANNED_GATEWAY_KEY"=>"kanndee",
#  "KANNED_ADAPTER_KEY"=>"mmsbox",
#  "KANNED_PATH_PARAMS"=>nil}
# =====
#
#
# ===== PARAMS =====
# Media Type: multipart/form-data
# Form data: true
# {"parts"=> [
#             {
#               :filename=>"mmm.smil",
#               :type=>"application/smil; charset=utf-8",
#               :name=>"parts[]",
#               :tempfile=> "#<File:/var/folders/dK/dKSub9W2FsKUaXGTUn8kYU+++TI/-Tmp-/RackMultipart20101216-23676-rbfu54>",
#               :head=> "Content-Disposition: form-data; name=\"parts[]\"; filename=\"mmm.smil\"\r\nContent-Type: application/smil; charset=utf-8\r\n" },
#             {
#               :filename=>"1292488442580.txt",
#               :type=>"text/plain; charset=utf-8",
#               :name=>"parts[]",
#               :tempfile=> "#<File:/var/folders/dK/dKSub9W2FsKUaXGTUn8kYU+++TI/-Tmp-/RackMultipart20101216-23676-174mdyl>",
#               :head=> "Content-Disposition: form-data; name=\"parts[]\"; filename=\"1292488442580.txt\"\r\nContent-Type: text/plain; charset=utf-8\r\n" },
#             {
#               :filename=>"IMG00172-20101207-2112.jpg",
#               :type=>"image/jpeg",
#               :name=>"parts[]",
#               :tempfile=> "#<File:/var/folders/dK/dKSub9W2FsKUaXGTUn8kYU+++TI/-Tmp-/RackMultipart20101216-23676-bh9a47>",
#               :head=>"Content-Disposition: form-data; name=\"parts[]\"; filename=\"IMG00172-20101207-2112.jpg\"\r\nContent-Type: image/jpeg\r\n" }
#            ]
# }

module Palmade::Kanned
  module Adapters
    class Mmsbox < Base
      DEFAULT_CONFIG = {

      }

      def initialize(gw, adapter_key, config = { })
        super(gw, adapter_key, DEFAULT_CONFIG.merge(config))
      end

      # called when processing web requests (aka receiving sms)
      def parse_request(env, path_params)
        validate_request!(env, path_params)

        env[Crack_input] = strip_leading_eol(env[Crack_input])
        parse_message_hash(env, path_params)
      end

      protected

      Cslash = "/".freeze
      def parse_message_hash(env, path_params)
        msg_hash = empty_message_hash(CMMS)

        msg_hash[CSENDER_NUMBER] = env[CHTTP_X_MBUNI_FROM].dup.freeze
        msg_hash[CRECIPIENT_NUMBER] = env[CHTTP_X_MBUNI_TO].dup.freeze
        msg_hash[CRECIPIENT_ID] = env[CHTTP_X_MBUNI_MMSC_ID].dup.freeze
        msg_hash[CRECEIVED_AT] = Time.parse(env[CHTTP_X_MBUNI_RECEIVED_DATE]).utc.freeze

        msg_hash[CSUBJECT] = env[CHTTP_X_MBUNI_SUBJECT].dup.freeze

        r = Rack::Request.new(env)
        r.POST[Cparts].each do |part|
          ct, ct_params = parse_content_type(part[:type])
          puts "CT: #{ct.inspect}, #{ct_params.inspect}"

          case ct.split(Cslash).first
          when Ctext
            temp_file = part[:tempfile]
            temp_file.rewind

            case ct_params[Ccharset]
            when Cutf8
              msg_hash[CMESSAGE] = temp_file.read.force_encoding(CEncUTF8).freeze
            else
              msg_hash[CMESSAGE] = temp_file.read.force_encoding(CEncBINARY).freeze
            end
          else
            msg_hash[CATTACHMENTS] ||= [ ]
            msg_hash[CATTACHMENTS].push(part)
          end
        end

        msg_hash[CREMOTE_ADDR] = env[CREMOTE_ADDR].dup.freeze
        msg_hash[CUSER_AGENT] = env[CHTTP_USER_AGENT].dup.freeze
        msg_hash[CREQUESTED_AT] = Time.now.utc.freeze
        msg_hash[CQUERY_STRING] = env[CQUERY_STRING].dup.freeze

        msg_hash[CKANNED_GATEWAY_PATH] = env[CKANNED_GATEWAY_PATH]
        msg_hash[CKANNED_GATEWAY_KEY] = env[CKANNED_GATEWAY_KEY]
        msg_hash[CKANNED_ADAPTER_KEY] = env[CKANNED_ADAPTER_KEY]
        msg_hash[CKANNED_PATH_PARAMS] = env[CKANNED_PATH_PARAMS]

        puts "\n\n===== MSG HASH ====="
        pp msg_hash
        puts "=====\n"

        [ msg_hash, env, path_params ]
      end

      def validate_request!(env, path_params)
        [ CHTTP_X_MBUNI_MESSAGE_ID,
          CHTTP_X_MBUNI_MMSC_ID,
          CHTTP_X_MBUNI_TRANSACTIONID,
          CHTTP_X_MBUNI_FROM,
          CHTTP_X_MBUNI_TO,
          CHTTP_X_MBUNI_RECEIVED_DATE
        ].each do |k|
          if !env.include?(k) || env[k].nil? || env[k].empty?
            raise MalformedRequest, "Invalid header value for #{k} #{env[k]}"
          end
        end
      end

      Ceol = "\r\n".freeze
      CKannedMmsboxBody = "kanned-mmsbox-body".freeze
      C16k = 16384
      def strip_leading_eol(input)
        eol = input.read(2)
        if !eol.nil? && eol == Ceol
          body = Tempfile.new(CKannedMmsboxBody)
          body.binmode
          while !input.eof?
            body << input.read(C16k)
          end
          body

          input.close if input.respond_to?(:close)
          input = body
        else
          input.rewind
        end

        input
      end

      Ceql = '='.freeze
      def parse_content_type(content_type)
        ct_parts = content_type.split(CContentTypeRegEx, 2)
        [ ct_parts.first.downcase,
          Hash[*ct_parts[1..-1].
               collect { |s| s.split(Ceql, 2) }.
               map { |k,v| [k.downcase, v] }.flatten] ]
      end
    end
  end
end
