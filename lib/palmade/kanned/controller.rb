# -*- encoding: utf-8 -*-

module Palmade::Kanned
  class Controller
    include Constants

    attr_reader :gateway
    attr_reader :message
    attr_reader :env
    attr_reader :path_params

    attr_reader :logger

    autoload :Commands, File.join(KANNED_LIB_DIR, 'kanned/controller/commands')
    include Commands

    autoload :Messages, File.join(KANNED_LIB_DIR, 'kanned/controller/messages')
    include Messages

    def performed?; @performed; end
    def performed!; @performed = true; end

    def self.perform(gw, msg_hash, env, path_params)
      self.new(gw).perform(msg_hash, env, path_params)
    end

    def initialize(gateway)
      @gateway = gateway
      @logger = gateway.logger

      @reply = nil
      @performed = false
    end

    def perform(message_hash, env, path_params)
      @message = Message.new(message_hash)
      @env = env
      @path_params = path_params

      # process commands and shortcodes
      unless performed?
        perform_commands_and_shortcodes
      end

      # process catch-all message handler
      unless performed?
        perform_message
      end

      # by default, we mark it as performed, whatever the response.
      performed!

      return_response
    end

    def perform_message
      raise NotImplemented, "perform message not implemented for #{self.class.name}"
    end

    protected

    def return_response
      unless @reply.nil?
        response = [ 200, { CContentType => CCTtext_plain }, @reply ]
      else
        response = [ 200, { CContentType => CCTtext_plain }, CEmptyBody ]
      end

      [ performed?, response ]
    end

    def reply(msg)
      @reply = msg
    end

    def no_reply!
      @reply = nil
    end
  end
end
