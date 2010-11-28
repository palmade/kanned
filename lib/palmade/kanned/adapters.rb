module Palmade::Kanned
  module Adapters
    autoload :Smsbox, File.join(KANNED_LIB_DIR, 'kanned/adapters/smsbox')
    autoload :Twilio, File.join(KANNED_LIB_DIR, 'kanned/adapters/twilio')
    autoload :Mbuni, File.join(KANNED_LIB_DIR, 'kanned/adapters/mbuni')
  end
end
