require 'yaml'

module Palmade::Kanned
  class Config
    attr_reader :config
    attr_reader :gateways

    def self.load_file(config_path)
      self.new(YAML.load_file(config_path))
    end

    def initialize(config_hash)
      @config = { }
      @gateways = { }

      parse!(config_hash)
    end

    protected

    def parse!(config_hash)
      if config_hash.include?('gateways') &&
          config_hash['gateways'].size > 0
        config_hash['gateways'].each do |gw_k, gw_hash|
          parse_gateway(gw_k.to_s, gw_hash)
        end

        config_hash.delete('gateways')
      else
        raise "Config file do not contain gateway settings."
      end

      # just copy the remaining config hash values
      @config = config_hash
    end

    def parse_gateway(gw_k, gw_hash)
      unless @gateways.include?(gw_k)
        @gateways[gw_k.dup.freeze] = { }
      end

      # this part, makes a up to 2-level deep copy
      gw_hash.each do |k, v|
        case v
        when Array
          v = v.collect { |n| n.dup }
        when Hash
          v = v.inject({ }) { |h, d| h[d[0].dup.freeze] = d[1].dup; h }
        else
          v = v.dup
        end

        @gateways[gw_k][k.dup.freeze] = v
      end

      @gateways[gw_k]
    end
  end
end
