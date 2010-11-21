module Palmade::Kanned
  class Gateway
    DEFAULT_OPTIONS = {

    }

    def initialize(gw_k, gw_opts, config)
      @gateway_key = gw_k
      @options = DEFAULT_OPTIONS.merge(gw_opts)
      @config = config
    end
  end
end
