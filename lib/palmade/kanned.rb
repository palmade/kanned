require 'logger'
require 'benchmark'

KANNED_LIB_DIR = File.expand_path('..', __FILE__)
KANNED_ROOT_DIR = File.expand_path('../../..', __FILE__)

module Palmade
  module Kanned
    autoload :Constants, File.join(KANNED_LIB_DIR, 'kanned/constants')
    autoload :Init, File.join(KANNED_LIB_DIR, 'kanned/init')
    autoload :Config, File.join(KANNED_LIB_DIR, 'kanned/config')
    autoload :Configurator, File.join(KANNED_LIB_DIR, 'kanned/configurator')

    autoload :Middleware, File.join(KANNED_LIB_DIR, 'kanned/middleware')
    autoload :Adapters, File.join(KANNED_LIB_DIR, 'kanned/adapters')
    autoload :App, File.join(KANNED_LIB_DIR, 'kanned/app')

    autoload :Gateway, File.join(KANNED_LIB_DIR, 'kanned/gateway')
    autoload :Controller, File.join(KANNED_LIB_DIR, 'kanned/controller')
    autoload :Message, File.join(KANNED_LIB_DIR, 'kanned/message')
    autoload :MessageAttachment, File.join(KANNED_LIB_DIR, 'kanned/message_attachment')
    autoload :Texter, File.join(KANNED_LIB_DIR, 'kanned/texter')

    autoload :Http, File.join(KANNED_LIB_DIR, 'kanned/http')

    class KannedError < StandardError; end
    class ConfigError < KannedError; end
    class UnknownAdapter < KannedError; end
    class NotImplemented < KannedError; end
    class MalformedRequest < KannedError; end
    class UnsupportedEncoding < KannedError; end
    class IncompleteRequest < KannedError; end
    class CantSend < KannedError; end
    class HttpServiceRequired < KannedError; end
    class SendSmsFail < KannedError; end
    class InvalidRequest < KannedError; end
    class UnsupportedRequest < KannedError; end

    def self.init; @@init; end
    def self.init=(i); @@init = i; end

    def self.configure(&block)
      Configurator.configure(&block)
    end

    def self.run_app
      App.run
    end

    def self.gw(gw_k)
      init.gw(gw_k)
    end
  end
end
