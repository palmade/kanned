# -*- encoding: binary -*-

module Palmade::Kanned
  module Constants
    CPATH_INFO = "PATH_INFO".freeze
    Crack_input = "rack.input".freeze
    CREMOTE_ADDR = "REMOTE_ADDR".freeze
    CQUERY_STRING = "QUERY_STRING".freeze

    CHTTP_X_KANNEL_FROM = "HTTP_X_KANNEL_FROM".freeze
    CHTTP_X_KANNEL_TO = "HTTP_X_KANNEL_TO".freeze
    CHTTP_X_KANNEL_SMSC = "HTTP_X_KANNEL_SMSC".freeze
    CHTTP_X_KANNEL_TIME = "HTTP_X_KANNEL_TIME".freeze
    CHTTP_DATE = "HTTP_DATE".freeze
    CHTTP_USER_AGENT = "HTTP_USER_AGENT".freeze

    CContentType = "Content-Type".freeze
    CCTtext_plain = "text/plain".freeze
    CFailWhale = "Fail Whale".freeze

    CKANNED_GATEWAY_PATH = "KANNED_GATEWAY_PATH".freeze
    CKANNED_GATEWAY_KEY = "KANNED_GATEWAY_KEY".freeze
    CKANNED_ADAPTER_KEY = "KANNED_ADAPTER_KEY".freeze
    CKANNED_PATH_PARAMS = "KANNED_PATH_PARAMS".freeze

    CSENDER_NUMBER = "SENDER_NUMBER".freeze
    CRECIPIENT_NUMBER = "RECIPIENT_NUMBER".freeze
    CRECIPIENT_ID = "RECIPIENT_ID".freeze
    CRECEIVED_AT = "RECIEVED_AT".freeze
    CMESSAGE = "MESSAGE".freeze
    CSUBJECT = "SUBJECT".freeze
    CUSER_AGENT = "USER_AGENT".freeze
    CREQUESTED_AT = "REQUESTED_AT".freeze

    CEncBINARY = Encoding.find('BINARY')
  end
end
