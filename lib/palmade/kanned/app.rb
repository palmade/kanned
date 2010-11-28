# -*- encoding: binary -*-

require 'rack/utils'

module Palmade::Kanned
  class App
    include Constants

    attr_reader :logger

    def self.run
      self.new(Palmade::Kanned.init).run
    end

    def initialize(init)
      @init = init
      @logger = init.logger
      @gw_routes = [ ]
    end

    def run
      build_gateway_routes!
      self
    end

    def call(env)
      performed, response = call_gateways(env)
      if performed
        response
      else
        fail!
      end
    end

    protected

    def gateways
      @init.gateways
    end

    def call_gateways(env)
      performed = false; response = nil

      unless @gw_routes.empty?
        pi = Rack::Utils.unescape(env[CPATH_INFO])

        @gw_routes.each do |gw_r|
          url_p = gw_r[0]

          if pi.index(url_p) == 0
            if pi =~ gw_r[1]
              adapter_key = $~[1]
              path_params = $~[2]

              env[CKANNED_GATEWAY_PATH] = url_p
              env[CKANNED_GATEWAY_KEY] = gw_r[2]
              env[CKANNED_ADAPTER_KEY] = adapter_key
              env[CKANNED_PATH_PARAMS] = path_params

              gw = gateways[gw_r[2]]
              msg_hash, env, path_params = gw.adapter(adapter_key).
                parse_request(env, path_params)

              performed, response = gw.call(msg_hash, env, path_params)
            end
          end

          break if performed
        end
      end

      [ performed, response ]
    end

    def build_gateway_routes!
      @init.gateways.each do |gw_key, gw|
        url_prefix = gw.url_prefix.dup.freeze
        url_prefix_regex = /\A#{url_prefix}\/([^\/]+)(\/.*)?\Z/.freeze

        @gw_routes.push [ url_prefix, url_prefix_regex, gw_key ]
      end
    end

    def fail!
      [ 500, { CContentType => CCTtext_plain }, CFailWhale ]
    end
  end
end
