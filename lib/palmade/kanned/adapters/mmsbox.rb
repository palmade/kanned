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
        env['rack.input'] = strip_leading_eol(env['rack.input'])

        [ nil, env, path_params ]
      end

      protected

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
    end
  end
end
