# -*- encoding: binary -*-
#

=begin
==== ENV
{"SERVER_SOFTWARE"=>"thin 1.2.11 codename Bat-Shit Crazy",
 "SERVER_NAME"=>"potato.markjeee.com",
 "rack.input"=>#<StringIO:0x000001042235a8>,
 "rack.version"=>[1, 0],
 "rack.errors"=>#<IO:<STDERR>>,
 "rack.multithread"=>false,
 "rack.multiprocess"=>false,
 "rack.run_once"=>false,
 "REQUEST_METHOD"=>"POST",
 "REQUEST_PATH"=>"/kanndee/globelabs/",
 "PATH_INFO"=>"/kanndee/globelabs/",
 "REQUEST_URI"=>"/kanndee/globelabs/",
 "HTTP_VERSION"=>"HTTP/1.1",
 "HTTP_ACCEPT"=>"text/xml",
 "HTTP_SAFE"=>"yes",
 "HTTP_USER_AGENT"=>"Java/1.6.0_06",
 "HTTP_HOST"=>"potato.markjeee.com:4000",
 "HTTP_CONNECTION"=>"keep-alive",
 "CONTENT_LENGTH"=>"637",
 "CONTENT_TYPE"=>"text/xml; charset=utf-8",
 "GATEWAY_INTERFACE"=>"CGI/1.2",
 "SERVER_PORT"=>"4000",
 "QUERY_STRING"=>"",
 "SERVER_PROTOCOL"=>"HTTP/1.1",
 "rack.url_scheme"=>"http",
 "SCRIPT_NAME"=>"",
 "REMOTE_ADDR"=>"127.0.0.1",
 "async.callback"=>
  #<Method: Palmade::PuppetMaster::ThinConnection#post_process>,
 "async.close"=>#<EventMach
ine::DefaultDeferrable:0x00000104222c98>,
 "KANNED_GATEWAY_PATH"=>"/kanndee",
 "KANNED_GATEWAY_KEY"=>"kanndee",
 "KANNED_ADAPTER_KEY"=>"globelabs",
 "KANNED_PATH_PARAMS"=>"/"}

==== PP
"/"

==== POST
{}

==== XML
"<?xml version=\"1.0\" encoding=\"utf-8\"?><message><param><name>id</name><value>2373703320110419204840</value></param><param><name>messageType</name><value>SMS</value></param><param><name>target</name><value>23737033</value></param><param><name>source</name><value>09176327037</value></param><param><name>msg</name><value>This is a super long sms. Testing how long is supported here. This is a super long sms. Testing how long is supported here. This is a super long sms. Testing how long is supported here. This is a super long sms. Testing how long is supported here.</value></param><param><name>udh</name><value></value></param></message>"

==== SMS INFO:
{"id"=>"2373703320110419211119",
 "messagetype"=>"SMS",
 "target"=>"23737033",
 "source"=>"09176327037",
 "msg"=>"Testing 5",
 "udh"=>""}


==== MMS XML

"<?xml version=\"1.0\" encoding=\"utf-8\"?><message><param><name>messageType</name><value>MMS</value></param><param><name>subject</name><value>7033</value></param><param><name>source</name><value>+639176327037</value></param><param><name>target</name><value>2373</value></param><param><name>file</name><value><file>http://202.126.34.117:1883/platform/20110430223040IMG00027-20110430-2217.jpg</file><file>http://202.126.34.117:1883/platform/201104302230401304173009829.txt</file><file>http://202.126.34.117:1883/platform/20110430223040mmm.smil</file></value></param></message>"


==== MI

{"messagetype"=>"MMS",
 "subject"=>"7033",
 "source"=>"+639176327037",
 "target"=>"2373",
 "file"=>
  ["http://202.126.34.117:1883/platform/20110430223040IMG00027-20110430-2217.jpg",
   "http://202.126.34.117:1883/platform/201104302230401304173009829.txt",
   "http://202.126.34.117:1883/platform/20110430223040mmm.smil"]}

=end

require 'nokogiri'
require 'handsoap'
require 'uri'

module Palmade::Kanned
  module Adapters
    class Globelabs < Base
      class SoapService < Handsoap::Service
        self.endpoint({ :uri => 'http://this-is-wrong-on-purpose',
                        :version => 1 })

        def initialize(uri = nil)
          @uri = uri
        end

        def uri
          if defined?(@uri) && !@uri.nil?
            @uri
          else
            self.class.uri
          end
        end

        on_create_document do |doc|
          doc.alias 'xsd', "http://ESCPlatform/xsd"
        end

        def send_sms!(params = { })
          response = invoke("xsd:sendSMS") do |m|
            m.add 'xsd:uName', params[:username]
            m.add 'xsd:uPin', params[:password]
            m.add 'xsd:MSISDN', params[:number]
            m.add 'xsd:messageString', params[:message]

            # right now, the following params are
            # fixed, since we're assuming we're always
            # sending plain SMS text messages.
            #
            m.add 'xsd:Display', '1'
            m.add 'xsd:udh', ''
            m.add 'xsd:mwi', ''
            m.add 'xsd:coding', '0'
          end

          # now, let's return the SOAP command response.
          response.document.xpath('//ns:sendSMSResponse/ns:return/text()',
                                  'ns' => "http://ESCPlatform/xsd").first.to_s
        end
      end

      Cnormalize_prefix = 'normalize_prefix'.freeze
      Cpath_key = 'path_key'.freeze
      Cignore_subject = 'ignore_subject'.freeze

      DEFAULT_CONFIG = {
        Cnormalize_prefix => '+63',
        Cpath_key => nil,
        Cignore_subject => false
      }

      DEFAULT_RECIPIENT_ID = 'globelabs'.freeze
      CORIGINAL_SOURCE_NUMBER = 'ORIGINAL_SOURCE_NUMBER'.freeze

      Cusername = 'username'.freeze
      Cpassword = 'password'.freeze

      CSMS_NOTIFICATION = 'SMS-NOTIFICATION'.freeze
      CGLOBELABS_MESSAGE_TYPE = 'GLOBELABS_MESSAGE_TYPE'.freeze

      # NOTE!!!
      # If you get into trouble, try updating this file
      # first, before doing anything else.
      #
      WSDL_FILE_PATH = 'data/globelabs_wsdl.xml'

      def initialize(gw, adapter_key, config = { })
        super(gw, adapter_key, DEFAULT_CONFIG.merge(config))

        @wsdl_file = File.join(KANNED_ROOT_DIR, WSDL_FILE_PATH)
      end

      # called when processing web requests (aka receiving sms)
      def parse_request(env, path_params)
        if env[CREQUEST_METHOD] == CPOST
          validate_request!(env, path_params)
          parse_message_hash(env, path_params)
        else
          [ nil, env, path_params ]
        end
      end

      def post_process(env, path_params, msg_hash, performed, response)
        if performed
          bd = response[2]
          unless bd.nil?
            msg = bd = bd.collect { |s| s }.join.strip
            to = msg_hash[CORIGINAL_SOURCE_NUMBER]

            unless msg.empty?
              # just try to catch if we can't send, and just fail gracefully
              #
              begin
                check_can_send!

                # try to send reply within the same request.
                # for robustness or whatever later on, this part can be
                # done asynchronously. as it might affect receiving of
                # messages.
                #
                resp = send_sms(to, msg)
                unless resp[0]
                  logger.error { "  !!! Sending failed to #{to} with error #{resp[1]}" }
                end
              rescue Exception => e
                logger.error { "  Cant send response to #{to}" }
                logger.error { "#{e.class.name} #{e.message}\n#{e.backtrace.join("\n")}" }
              end
            end
          end
        else
          case env[CGLOBELABS_MESSAGE_TYPE]
          when CSMS_NOTIFICATION
            response = reply_txt("Success")
          else
            # just ignore, move on with life.
          end
        end

        [ performed, response ]
      end

      def send_sms(number, message, sender_id = nil)
        check_can_send!

        number = normalize_number(number)
        send_sms_soap(number, message, sender_id)
      end

      protected

      def send_sms_soap(number, message, sender_id = nil)
        ss = SoapService.new(@config[Cendpoint_url])

        handle_resp!(ss.send_sms!(:username => @config[Cusername],
                                  :password => @config[Cpassword],
                                  :number => number,
                                  :message => message))
      end

      # NOTE: See Globelabs site for more information about these
      # return codes. The SOAP response only contains the code,
      # so you'll need to go to their site to know more info about
      # these codes.
      #
      def handle_resp!(resp)
        case resp
        when '201', '202'
          [ true, resp ]
        else
          [ false, resp ]
        end
      end

      def check_can_send!
        [ Cendpoint_url,
          Cusername,
          Cpassword ].each do |k|
          if !@config.include?(k) || @config[k].nil? || @config[k].empty?
            raise CantSend, "Send sms configuration not complete"
          end
        end
      end

      def parse_message_hash(env, path_params)
        msg_hash = nil

        bd = env[Crack_input]
        bd.rewind

        xml_txt = bd.read.force_encoding(CEncUTF8)
        mi = parse_xml_input(xml_txt)
        bd.rewind

        unless mi['messagetype'].nil?
          env[CGLOBELABS_MESSAGE_TYPE] = mi['messagetype'].upcase.freeze

          case mt = mi['messagetype'].upcase
          when CSMS, CMMS
            msg_hash = empty_message_hash(mt)

            msg_hash[CMESSAGE_ID] = mi['id'].freeze

            # let's try to normalize the sender number, if it's
            # not in the format we expect it (ISOxx format)
            #
            if mi['source'] =~ /\A0(\d+)\Z/
              msg_hash[CSENDER_NUMBER] = ("%s%s" % [ @config[Cnormalize_prefix], $~[1] ]).freeze
            else
              msg_hash[CSENDER_NUMBER] = mi['source'].freeze
            end

            msg_hash[CORIGINAL_SOURCE_NUMBER] = mi['source'].freeze
            msg_hash[CRECIPIENT_NUMBER] = mi['target'].freeze

            # e.g. /kanndee/globelabs/tweetitow/some_key
            msg_hash[CRECIPIENT_ID] = (path_params.split(/\//, 3)[1] || DEFAULT_RECIPIENT_ID).freeze

            msg_hash[CRECEIVED_AT] = Time.now.utc.freeze

            case mt
            when CSMS
              msg_hash[CMESSAGE] = mi['msg'].freeze
            when CMMS
              unless @config[Cignore_subject]
                msg_hash[CSUBJECT] = mi['subject'].freeze
              end

              fetch_attachments(msg_hash, mi)
            end

            msg_hash[CREMOTE_ADDR] = env[CREMOTE_ADDR].dup.freeze
            msg_hash[CUSER_AGENT] = env[CHTTP_USER_AGENT].dup.freeze
            msg_hash[CREQUESTED_AT] = Time.now.utc.freeze
            msg_hash[CQUERY_STRING] = env[CQUERY_STRING].dup.freeze

            msg_hash[CKANNED_GATEWAY_PATH] = env[CKANNED_GATEWAY_PATH]
            msg_hash[CKANNED_GATEWAY_KEY] = env[CKANNED_GATEWAY_KEY]
            msg_hash[CKANNED_ADAPTER_KEY] = env[CKANNED_ADAPTER_KEY]
            msg_hash[CKANNED_PATH_PARAMS] = env[CKANNED_PATH_PARAMS]
          when CSMS_NOTIFICATION
            logger.info { "!!! Got GlobeLabs notification. Params: #{mi.inspect}" }
          else
            raise InvalidRequest, "Don't know how to parse message type #{mi['messagetype']}"
          end
        else
          env[CGLOBELABS_MESSAGE_TYPE] = nil
        end

        [ msg_hash, env, path_params ]
      end

      def fetch_attachments(msg_hash, mi)
        msg_hash[CATTACHMENTS] = [ ]

        # try to get the smil file, if it exists, parse it, and
        # read the files based from there. if not, only parse the
        # txt file.
        #
        mi['file'].each do |furl|
          url = URI.parse(furl)
          path = url.path

          # Strip out the prefixed dates. This can change, so beware
          # e.g. 20110430223040IMG00027-20110430-2217.jpg
          fname = File.basename(path)[14..-1]
          # fallback to full fname, if slice returns empty
          fname = File.basename(path) if fname.nil? || fname.empty?

          ext = File.extname(fname)
          ext = ext[1..-1] unless ext.nil?

          case ext
          when 'txt'
            resp = http.get(url.to_s)
            if resp.success?
              msg_hash[CMESSAGE] = resp.read.force_encoding(CEncUTF8).freeze

              # sometimes, the message id param of an MMS message is empty.
              # let's try to fill-it in here, using the sender number, and the
              # timestamp found on the filename of the attached files.
              #
              if msg_hash[CMESSAGE_ID].nil?
                sender = msg_hash[CSENDER_NUMBER][1..-1]
                timestamp = File.basename(path)[0...14]

                msg_hash[CMESSAGE_ID] = "%s-%s" % [ sender, timestamp ]
              end
            else
              resp.raise_http_error
            end
          else
            tempfile = create_tempfile
            resp = http.get(url.to_s, tempfile)
            if resp.success?
              attach = MessageAttachment.new(tempfile,
                                             :original_filename => fname,
                                             :size => tempfile.size)

              msg_hash[CATTACHMENTS].push(attach)
            else
              resp.raise_http_error
            end
          end

          msg_hash[CATTACHMENTS]
        end
      end

      def validate_request!(env, path_params)
        bd = env[Crack_input]
        raise MalformedRequest, "Contains no XML in request body" unless bd.size > 0

        unless @config[Cpath_key].nil?
          pk = path_params.split(/\//, 4)[2]
          raise InvalidRequest, "Wrong path key provided" if pk != @config[Cpath_key]
        end
      end

      def parse_xml_input(xml_txt)
        mi = { }

        doc = Nokogiri::XML(xml_txt)
        doc.xpath('//message/param').each do |p|
          pname = p.xpath('name').first.content.downcase

          if (fs = p.xpath('value/file')).empty?
            mi[pname] = p.xpath('value').first.content
          else
            mi[pname] = [ ]
            fs.each do |f|
              mi[pname].push(f.content)
            end
          end
        end

        mi
      end

      def normalize_number(number)
        if number =~ /(\+63|0)(\d+)/
          "0%s" % $~[2]
        else
          number
        end
      end
    end
  end
end
