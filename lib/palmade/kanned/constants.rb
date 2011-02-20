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

    CHTTP_X_MBUNI_MESSAGE_ID = "HTTP_X_MBUNI_MESSAGE_ID".freeze
    CHTTP_X_MBUNI_MMSC_ID = "HTTP_X_MBUNI_MMSC_ID".freeze
    CHTTP_X_MBUNI_FROM = "HTTP_X_MBUNI_FROM".freeze
    CHTTP_X_MBUNI_SUBJECT = "HTTP_X_MBUNI_SUBJECT".freeze
    CHTTP_X_MBUNI_TRANSACTIONID = "HTTP_X_MBUNI_TRANSACTIONID".freeze
    CHTTP_X_MBUNI_TO = "HTTP_X_MBUNI_TO".freeze
    CHTTP_X_MBUNI_MESSAGE_DATE = "HTTP_X_MBUNI_MESSAGE_DATE".freeze
    CHTTP_X_MBUNI_RECEIVED_DATE = "HTTP_X_MBUNI_RECEIVED_DATE".freeze

    CHTTP_DATE = "HTTP_DATE".freeze
    CHTTP_USER_AGENT = "HTTP_USER_AGENT".freeze

    CContentType = "Content-Type".freeze
    CContentTypeRegEx = /\s*[;,]\s*/.freeze
    CCTtext_plain = "text/plain; charset=utf-8".freeze
    CCTtext_html = "text/html; charset=utf-8".freeze
    CCTapplication_json = "application/json; chartset=utf-8".freeze
    Ctext = "text".freeze
    Cimage = "image".freeze
    Ccharset = "charset".freeze
    Cparts = "parts".freeze

    CKANNED_GATEWAY_PATH = "KANNED_GATEWAY_PATH".freeze
    CKANNED_GATEWAY_KEY = "KANNED_GATEWAY_KEY".freeze
    CKANNED_ADAPTER_KEY = "KANNED_ADAPTER_KEY".freeze
    CKANNED_PATH_PARAMS = "KANNED_PATH_PARAMS".freeze

    CMESSAGE_TYPE = "MESSAGE_TYPE".freeze
    CSMS = "SMS".freeze
    CMMS = "MMS".freeze
    Cutf8 = "utf-8".freeze

    CMESSAGE_ID = "MESSAGE_ID".freeze
    CSENDER_NUMBER = "SENDER_NUMBER".freeze
    CRECIPIENT_NUMBER = "RECIPIENT_NUMBER".freeze
    CRECIPIENT_ID = "RECIPIENT_ID".freeze
    CRECEIVED_AT = "RECEIVED_AT".freeze
    CMESSAGE = "MESSAGE".freeze
    CSUBJECT = "SUBJECT".freeze
    CATTACHMENTS = "ATTACHMENTS".freeze
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
    Clogcompletedformat =  ("Completed in %.5f (%s reqs/sec) | %s [ %s %s ]").freeze

    Clogtextersending = "  Sending SMS to %s\n    %s".freeze

    Cmessaging_token = 'messaging_token'.freeze
    Caccount_id = 'account_id'.freeze
    Capi_url = 'api_url'.freeze
    Cparameters = 'parameters'.freeze
    Ctrue = 'true'. freeze
    Callowed_regex = 'allowed_regex'.freeze
  end
end
