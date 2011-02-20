module Palmade::Kanned
  module Adapters
    autoload :Base, File.join(KANNED_LIB_DIR, 'kanned/adapters/base')
    autoload :Smsbox, File.join(KANNED_LIB_DIR, 'kanned/adapters/smsbox')
    autoload :Mmsbox, File.join(KANNED_LIB_DIR, 'kanned/adapters/mmsbox')
    autoload :Dummy, File.join(KANNED_LIB_DIR, 'kanned/adapters/dummy')

    autoload :Twilio, File.join(KANNED_LIB_DIR, 'kanned/adapters/twilio')
    autoload :Tropo, File.join(KANNED_LIB_DIR, 'kanned/adapters/tropo')
    autoload :Clickatell, File.join(KANNED_LIB_DIR, 'kanned/adapters/clickatell')

    CAN_SEND_ADAPTERS = [ "smsbox", "twilio", "tropo", "clickatell" ]

    def self.which_can_send(keys)
      keys.collect { |k| CAN_SEND_ADAPTERS.include?(k.to_s) ? k : nil }.compact
    end

    def self.create(gw, adapter_key, adapter_config = { })
      case adapter_key
      when 'smsbox'
        Smsbox.create(gw, adapter_key, adapter_config)
      when 'mmsbox'
        Mmsbox.create(gw, adapter_key, adapter_config)
      when 'dummy'
        Dummy.create(gw, adapter_key, adapter_config)
      when 'twilio'
        Twilio.create(gw, adapter_key, adapter_config)
      when 'tropo'
        Tropo.create(gw, adapter_key, adapter_config)
      when 'clickatell'
        Clickatell.create(gw, adapter_key, adapter_config)
      else
        raise UnknownAdapter, "Unknown adapter #{adapter_key}"
      end
    end
  end
end
