# -*- encoding: utf-8 -*-

module Palmade::Kanned
  class Controller
    module Commands
      class CommandAlreadyDefined < KannedError; end
      class CommandMethodNotDefined < KannedError; end
      class CommandMethodAlreadyDefined < KannedError; end
      class CommandKeyInvalid < KannedError; end

      DEFAULT_OPTIONS = {

      }

      # starts with a letter (any case) and can continue numbers afterwards
      ALLOWED_COMMAND_KEYS = /\A[a-zA-Z][a-zA-Z0-9]*\Z/.freeze

      COMMAND_REGEXP_MATCHER = /\A\/([a-zA-Z][a-zA-Z0-9]*)(\s+(.*))?\Z/m.freeze
      SHORTCODE_3CHARS_MATCHER = /\A([a-zA-Z][a-zA-Z0-9]{0,2})(\s+(.*))?\Z/m.freeze
      SHORTCODE_4CHARS_MATCHER = /\A([a-zA-Z][a-zA-Z0-9]{0,3})(\s+(.*))?\Z/m.freeze
      SHORTCODE_NCHARS_MATCHER = /\A([a-zA-Z][a-zA-Z0-9]*)(\s+(.*))?\Z/m.freeze

      module ClassMethods
        def command(cmd_key, *args, &block)
          _add_command(:command, cmd_key, *args, &block)
        end

        def shortcode(code_key, *args, &block)
          _add_command(:shortcode, code_key, *args, &block)
        end

        protected

        def _add_command(cmd_type, cmd_key, *args, &block)
          case cmd_type
          when :shortcode
            command_list = text_shortcodes
            if command_list.nil?
              command_list = self.text_shortcodes = { }
            end
          when :command
            command_list = text_commands
            if command_list.nil?
              command_list = self.text_commands = { }
            end
          else
            raise UnknownCommandType, "Unknown command type #{cmd_type}"
          end

          # normalize cmd_key, to lower version
          cmd_key = cmd_key.to_s.downcase.freeze

          unless cmd_key =~ ALLOWED_COMMAND_KEYS
            raise CommandKeyInvalid, "command key contains invalid characters"
          end

          unless command_list.include?(cmd_key)
            cmd_data = [ ]
            cmd_data[0] = cmd_key

            if args.last.is_a?(Hash)
              cmd_opts = DEFAULT_OPTIONS.merge(args.pop)
            else
              cmd_opts = { }.merge(DEFAULT_OPTIONS)
            end

            if block_given?
              cmd_method = "_#{cmd_type}_#{cmd_key}".to_sym

              if methods.include?(cmd_method)
                raise CommandMethodAlreadyDefined, "Command method #{cmd_method} for #{cmd_key} already defined. Please specify a different one."
              end

              define_method(cmd_method, &block)
              protected(cmd_method)
            else
              cmd_method = args.first.to_sym
            end

            if cmd_method.nil?
              raise CommandMethodNotDefined, "Command method for #{cmd_key} not defined. Either provide a block or a method name"
            end

            case cmd_type
            when :shortcode
              cmd_data[1] = /\A\s*(#{cmd_key})(\s+(.*))?\Z/m.freeze
            when :command
              cmd_data[1] = /\A\s*\/(#{cmd_key})(\s+(.*))?\Z/m.freeze
            end

            cmd_data[2] = cmd_method.freeze
            cmd_data[3] = cmd_opts

            command_list[cmd_key] = cmd_data
          else
            raise CommandAlreadyDefined, "Command #{cmd_key} already defined in #{cmd_type}"
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)

        class << base
          attr_accessor :text_commands
          attr_accessor :text_shortcodes
        end
      end

      protected

      def perform_commands_and_shortcodes
        msg = message.message
      end
    end
  end
end
