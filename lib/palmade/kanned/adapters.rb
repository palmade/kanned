module Palmade::Kanned
  module Adapters
    autoload :Base, File.join(KANNED_LIB_DIR, 'kanned/adapters/base')
    autoload :Smsbox, File.join(KANNED_LIB_DIR, 'kanned/adapters/smsbox')
    autoload :Twilio, File.join(KANNED_LIB_DIR, 'kanned/adapters/twilio')
    autoload :Mmsbox, File.join(KANNED_LIB_DIR, 'kanned/adapters/mmsbox')
    autoload :Dummy, File.join(KANNED_LIB_DIR, 'kanned/adapters/dummy')

    def self.create(gw, adapter_key, adapter_config = { })
      case adapter_key
      when 'smsbox'
        Smsbox.create(gw, adapter_key, adapter_config)
      when 'twilio'
        Twilio.create(gw, adapter_key, adapter_config)
      when 'mmsbox'
        Mmsbox.create(gw, adapter_key, adapter_config)
      when 'dummy'
        Dummy.create(gw, adapter_key, adapter_config)
      else
        raise UnknownAdapter, "Unknown adapter #{adapter_key}"
      end
    end
  end
end
