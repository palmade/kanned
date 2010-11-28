module Palmade::Kanned
  class Message
    include Constants

    def initialize(msg_hash)
      @msg_hash = msg_hash
    end

    def [](k)
      @msg_hash[k]
    end

    def keys
      @msg_hash.keys
    end

    def size
      @msg_hash.size
    end

    def sender_number
      @msg_hash[CSENDER_NUMBER]
    end

    def recipient_number
      @msg_hash[CRECIPIENT_NUMBER]
    end

    def recipient_id
      @msg_hash[CRECIPIENT_ID]
    end

    def message
      @msg_hash[CMESSAGE]
    end

    def recieved_at
      @msg_hash[RECEIVED_AT]
    end
  end
end
