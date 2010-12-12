# -*- encoding: binary -*-

module Palmade::Kanned
  module Constants
    CPATH_INFO = "PATH_INFO".freeze
    Crack_input = "rack.input".freeze
    CREMOTE_ADDR = "REMOTE_ADDR".freeze
    CREQUEST_METHOD = "REQUEST_METHOD".freeze
    CQUERY_STRING = "QUERY_STRING".freeze

    CGET = "GET".freeze
    CPOST = "POST".freeze

    CHTTP_X_KANNEL_FROM = "HTTP_X_KANNEL_FROM".freeze
    CHTTP_X_KANNEL_TO = "HTTP_X_KANNEL_TO".freeze
    CHTTP_X_KANNEL_SMSC = "HTTP_X_KANNEL_SMSC".freeze
    CHTTP_X_KANNEL_TIME = "HTTP_X_KANNEL_TIME".freeze
    CHTTP_X_KANNEL_CODING = "HTTP_X_KANNEL_CODING".freeze
    CHTTP_DATE = "HTTP_DATE".freeze
    CHTTP_USER_AGENT = "HTTP_USER_AGENT".freeze

    CContentType = "Content-Type".freeze
    CCTtext_plain = "text/plain; charset=utf-8".freeze
    CCTtext_html = "text/html; charset=utf-8".freeze

    CKANNED_GATEWAY_PATH = "KANNED_GATEWAY_PATH".freeze
    CKANNED_GATEWAY_KEY = "KANNED_GATEWAY_KEY".freeze
    CKANNED_ADAPTER_KEY = "KANNED_ADAPTER_KEY".freeze
    CKANNED_PATH_PARAMS = "KANNED_PATH_PARAMS".freeze

    CMESSAGE_ID = "MESSAGE_ID".freeze
    CSENDER_NUMBER = "SENDER_NUMBER".freeze
    CRECIPIENT_NUMBER = "RECIPIENT_NUMBER".freeze
    CRECIPIENT_ID = "RECIPIENT_ID".freeze
    CRECEIVED_AT = "RECEIVED_AT".freeze
    CMESSAGE = "MESSAGE".freeze
    CSUBJECT = "SUBJECT".freeze
    CUSER_AGENT = "USER_AGENT".freeze
    CREQUESTED_AT = "REQUESTED_AT".freeze

    CEncUTF8 = Encoding.find('UTF-8')
    CEncUTF16BE = Encoding.find('UTF-16BE')
    CEncBINARY = Encoding.find('BINARY')

    CFailWhale = "Fail Whale".encode('UTF-8').freeze
    CEmptyBody = "".encode('UTF-8').freeze

    Clogtimestamp = "%Y-%m-%d %H:%M:%S".freeze
    Clogprocessingformat = ("\n\nProcessing %s %s (for %s at %s)\n" +
                            "  SMS from %s to %s %s\n" +
                            "    %s").freeze
    Clogcompletedformat = ("Completed in %.5f (%s reqs/sec) | %s [ %s %s ]").freeze
  end
end
