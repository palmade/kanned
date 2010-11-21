module Palmade::Kanned
  class Configurator
    def self.configure(&block)
      self.new.configure(&block)
    end

    def initialize
      @init = nil
    end

    def configure(&block)
      self.instance_eval(&block)
      self
    end

    def init(root_path, env)
      @init = Init.init(root_path, env)
    end

    def configure(config_path = nil)
      init_required
      @init.configure(config_path)
    end

    def set_logger(l)
      init_required
      @init.set_logger(l)
    end

    protected

    def init_required
      raise "init required for this stage" if @init.nil?
    end
  end
end
