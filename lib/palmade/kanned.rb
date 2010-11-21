KANNED_LIB_DIR = File.expand_path(File.dirname(__FILE__))

module Palmade
  module Kanned
    autoload :Init, File.join(KANNED_LIB_DIR, 'kanned/init')
    autoload :Configurator, File.join(KANNED_LIB_DIR, 'kanned/configurator')

    autoload :Middleware, File.join(KANNED_LIB_DIR, 'kanned/middleware')
    autoload :App, File.join(KANNED_LIB_DIR, 'kanned/app')

    autoload :Controller, File.join(KANNED_LIB_DIR, 'kanned/controller')

    def self.init; @@init; end
    def self.init=(i); @@init = i; end

    def self.configure(&block)
      Configurator.configure(&block)
    end

    def self.run_app
      App.run
    end
  end
end
