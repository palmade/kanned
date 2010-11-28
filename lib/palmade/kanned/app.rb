module Palmade::Kanned
  class App
    def self.run
      self.new(Palmade::Kanned.init).run
    end

    def initialize(init)
      @init = init
    end

    def run
      self
    end

    def call(env)

    end

    protected

    def build_gateway_routes!
      @init.gateways.each do |gw|
        url_prefix = gw.url_prefix
      end
    end

    def fail!
      [ 500, { 'Content-Type' => 'text/plain' }, 'Fail Whale' ]
    end
  end
end
