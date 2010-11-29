# -*- encoding: utf-8 -*-

module Palmade::Kanned
  class Controller
    module Commands
      class CommandAlreadyDefined < KannedError; end
      class CommandMethodNotDefined < KannedError; end
      class CommandMethodAlreadyDefined < KannedError; end
      class CommandKeyInvalid < KannedError; end

      class UnknownCommandKey < KannedError
        attr_reader :cmd_key

        def initialize(cmd_key)
          super "Unknown command key #{cmd_key}"
          @cmd_key = cmd_key
        end
      end

      DEFAULT_OPTIONS = {

      }

      # NOTES: The following matchers below, can be different
      # if matching non US-ASCII characters. Such as those
      # found in Japanese or Korean charsets.

      # starts with a letter (any case) and can continue with
      # numbers afterwards, with at least 1 character
      ALLOWED_KEY_CHARS = '[a-zA-Z][a-zA-Z0-9]'.freeze
      ALLOWED_COMMAND_KEYS = /\A#{ALLOWED_KEY_CHARS}*\Z/.freeze

      GENERIC_SHORTCODE_REGEXP_MATCHER = '\A\s*(%s)(\s+(.*))?\Z'.freeze
      GENERIC_COMMAND_REGEXP_MATCHER = '\A\s*\/(%s)(\s+(.*))?\Z'.freeze

      COMMAND_REGEXP_MATCHER = /\A\s*\/(#{ALLOWED_KEY_CHARS}*)(\s+(.*))?\Z/m.freeze
      SHORTCODE_CHARS_MATCHER = /\A\s*(#{ALLOWED_KEY_CHARS}{2,3})(\s+(.*))?\Z/m.freeze
      SHORTCODE_NCHARS_MATCHER = /\A\s*(#{ALLOWED_KEY_CHARS}*)(\s+(.*))?\Z/m.freeze

      module ClassMethods
        protected

        def allow_nchars_shortcodes!
          self.text_shortcodes_matcher = SHORTCODE_NCHARS_MATCHER
        end

        def command(cmd_key, *args, &block)
          _add_command(:command, cmd_key, *args, &block)
        end

        def shortcode(code_key, *args, &block)
          _add_command(:shortcode, code_key, *args, &block)
        end

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

          # normalize cmd_key, to lower case version
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
                raise(CommandMethodAlreadyDefined,
                      "Command method #{cmd_method} for #{cmd_key} already defined. Please specify a different one.")
              end

              define_method(cmd_method, &block)
              protected(cmd_method)
            else
              if args.first.nil?
                cmd_method = cmd_key.to_sym
              else
                cmd_method = args.first.to_sym
              end
            end

            if cmd_method.nil?
              raise(CommandMethodNotDefined,
                    "Command method for #{cmd_key} not defined. Either provide a block or a method name.")
            end

            case cmd_type
            when :shortcode
              cmd_data[1] = Regexp.new(sprintf(GENERIC_SHORTCODE_REGEXP_MATCHER, cmd_key),
                                       Regexp::MULTILINE).freeze
            when :command
              cmd_data[1] = Regexp.new(sprintf(GENERIC_COMMAND_REGEXP_MATCHER, cmd_key),
                                       Regexp::MULTILINE).freeze
            end

            cmd_data[2] = cmd_method.freeze
            cmd_data[3] = cmd_opts

            command_list[cmd_key] = cmd_data
          else
            raise(CommandAlreadyDefined,
                  "Command #{cmd_key} already defined in #{cmd_type}")
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)

        class << base
          attr_accessor :text_commands
          attr_accessor :text_shortcodes
          attr_accessor :text_shortcodes_matcher
        end

        base.class_eval do
          protected

          attr_reader :cmd_key
          attr_reader :cmd_params

          def cmd_shortcode?
            defined?(@cmd_shortcode) && @cmd_shortcode
          end

          def cmd_shortcode!
            @cmd_shortcode = true
          end

          def text_commands
            self.class.text_commands
          end

          def text_shortcodes
            self.class.text_shortcodes
          end
        end
      end

      protected

      def perform_commands_and_shortcodes
        cmd_meth = nil

        # first, parse commands, 2nd try shortcodes
        unless text_commands.nil? || text_commands.empty?
          cmd_meth = parse_commands
        end

        unless !cmd_meth.nil? || text_shortcodes.nil? || text_shortcodes.empty?
          cmd_meth = parse_shortcodes
        end

        unless cmd_meth.nil?
          send(cmd_meth)

          # let's mark it performed, unless explicitly set
          performed! unless performed?
        end
      end

      def parse_commands
        msg = message.message

        if msg =~ COMMAND_REGEXP_MATCHER
          cmd_key = $~[1].downcase
          cmd_params = $~[2]

          if text_commands.include?(cmd_key)
            cmd_data = text_commands[cmd_key]

            @cmd_key = cmd_key.freeze
            @cmd_params = cmd_params.freeze

            # let's return the cmd_method
            cmd_data[2]
          else
            raise UnknownCommandKey, cmd_key
          end
        end
      end

      def parse_shortcodes
        msg = message.message

        shortcode_regexp = self.class.text_shortcodes_matcher || SHORTCODE_CHARS_MATCHER

        if msg =~ SHORTCODE_CHARS_MATCHER
          cmd_key = $~[1].downcase
          cmd_params = $~[2]

          if text_shortcodes.include?(cmd_key)
            cmd_data = text_shortcodes[cmd_key]

            @cmd_key = cmd_key.freeze
            @cmd_params = cmd_params.freeze
            self.cmd_shortcode!

            # let's return the cmd_method
            cmd_data[2]
          else
            nil
          end
        end
      end
    end
  end
end
