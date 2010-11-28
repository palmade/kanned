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
    end

    def recipient_number
    end

    def recipient_id
    end

    def message
    end

    def recieved_at
    end
  end
end
