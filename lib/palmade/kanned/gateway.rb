module Palmade::Kanned
  class Gateway
    DEFAULT_OPTIONS = {

    }

    attr_reader :gateway_key
    attr_reader :config
    attr_reader :options

    def initialize(gw_k, gw_opts, config)
      @gateway_key = gw_k
      @options = DEFAULT_OPTIONS.merge(gw_opts)
      @config = config
    end

    def url_prefix
      "/#{gateway_key}"
    end
  end
end
