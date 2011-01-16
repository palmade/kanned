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
    def throw_performed!; throw(:performed); end

    def self.perform(gw, msg_hash, env, path_params)
      self.new(gw).perform(msg_hash, env, path_params)
    end

    def initialize(gateway)
      @gateway = gateway
      @logger = gateway.logger

      @reply = nil
      @reply_code = 200

      @performed = false
    end

    def perform(message_hash, env, path_params)
      @message = Message.new(message_hash)
      @env = env
      @path_params = path_params

      # call before_filter
      before_filter

      # process commands and shortcodes
      unless performed?
        catch(:performed) do
          perform_commands_and_shortcodes
        end
      end

      # process catch-all message handler
      unless performed?
        catch(:performed) do
          perform_message
        end
      end

      # call after_filter
      after_filter

      # by default, we mark it as performed, whatever the response.
      performed! unless performed?

      return_response
    rescue Commands::UnknownCommandKey => e
      logger.warn { "  Perform command: Invalid command #{e.cmd_key}" }

      reply_final! "Invalid command #{e.cmd_key}"
      return_response
    end

    def perform_message
      raise NotImplemented, "perform message not implemented for #{self.class.name}"
    end

    protected

    def before_filter; end
    def after_filter; end

    # == Note, support for other types of response.
    #
    # NOTE: Replying here is assumed to be just plain/text which the gateway uses
    # to parse, as a reply SMS. Twilio/Clickatell might need to use a different,
    # reply. This needs to be implemented.
    #
    def return_response
      unless @reply.nil?
        response = [ @reply_code, { CContentType => CCTtext_plain }, [ @reply ] ]
      else
        response = [ @reply_code, { CContentType => CCTtext_plain }, [ CEmptyBody ] ]
      end

      [ performed?, response ]
    end

    def reply(msg, reply_code = 200)
      @reply = msg
      @reply_code = reply_code
    end

    def reply_nothing!
      @reply = nil
    end
    alias :reply_nothing :reply_nothing!

    def reply_final!(msg, reply_code = 200)
      performed!
      reply(msg, reply_code)
    end

    def error_exception(e)
      msg = "#{e.class.name}: #{e.message}"
      logger.error { "#{msg}\n\t#{e.backtrace.join("\n\t")}\n\n" }; msg
    end
  end
end
