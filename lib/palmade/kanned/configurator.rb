module Palmade::Kanned
  class Configurator
    def self.configure(&block)
      self.new.configure(&block)
    end

    def initialize
      @init = nil
      @configured = false
      @finalized = false
    end

    def configure(&block)
      self.instance_eval(&block)
      finalize unless @finalized

      self
    end

    def init(root_path, env)
      @init = Init.init(root_path, env)
    end

    def config(config_path = nil)
      init_required
      @configured = true
      @init.configure(config_path)
    end

    def set_logger(l)
      init_required
      @init.set_logger(l)
    end

    def set_route(gw_k, route_opts = { })
      init_required
      @init.set_route(gw_k, route_opts)
    end

    def finalize
      init_required
      config unless @configured

      @finalized = true
      @init.finalize
    end

    protected

    def init_required
      raise "init required for this stage" if @init.nil?
    end
  end
end
