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

    rescue Exception => e
      tm = Time.now.strftime(Clogtimestamp)
      logger.error { "[#{tm}] #{e.class.name} #{e.message}\n\t" +
        e.backtrace.join("\n\t") + "\n\n" }

      return fail!
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
          if pi.index(gw_r[0]) == 0
            if pi =~ gw_r[1]
              adapter_key = $~[1]
              path_params = $~[2]

              env[CKANNED_GATEWAY_PATH] = gw_r[0].dup.freeze
              env[CKANNED_GATEWAY_KEY] = gw_r[2].dup.freeze
              env[CKANNED_ADAPTER_KEY] = adapter_key.freeze
              env[CKANNED_PATH_PARAMS] = path_params.freeze

              gw = gateways[gw_r[2]]
              msg_hash, env, path_params = gw.adapter(adapter_key).
                parse_request(env, path_params)

              benchmark_and_log(gw, msg_hash, env) do
                performed, response = gw.call(msg_hash, env, path_params)
              end
            end
          end

          break if performed
        end
      end

      [ performed, response ]
    end

    Clognewlineregex = /\n/.freeze
    Clognewlinespacing = "\n    ".freeze
    Clognotperformed = "!performed".freeze
    def benchmark_and_log(gw, msg_hash, env, &block)
      rt = nil; ret = [ false, nil ]

      tm = Time.now.strftime(Clogtimestamp)
      request = Rack::Request.new(env)

      message = msg_hash[CMESSAGE][0,60].
        split(Clognewlineregex).join(Clognewlinespacing)

      logger.info { sprintf(Clogprocessingformat,
                            request.request_method.to_s.upcase,
                            request.path,
                            request.ip,
                            tm,
                            msg_hash[CSENDER_NUMBER],
                            msg_hash[CRECIPIENT_NUMBER],
                            msg_hash[CRECIPIENT_ID],
                            message) }

      rt = [ Benchmark.measure { ret = yield }.real, 0.0001 ].max

      logger.info { sprintf(Clogcompletedformat,
                            rt,
                            (1 / rt).floor,
                            ret[0] ? ret[1][0] : Clognotperformed,
                            request.request_method.to_s.upcase,
                            request.path) }
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
