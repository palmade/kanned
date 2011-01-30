# -*- encoding: utf-8 -*-

module Palmade::Kanned
  class Controller
    # Compound commands are of the format:
    #
    #   VERB [ADJECTIVE] NOUN [WHOM]
    #
    #   e.g. LIST INVITATIONS
    #        LIST INCOMING INVITATIONS
    #        LIST OUTGOING INVITATIONS
    #
    #   VERB WHAT [PREDICATE] WHAT
    #
    #        ADD username
    #        ADD username TO @@carebears
    #        ADD JOB001 TO FAVORITES
    #        SHARE JOB001 TO @username
    #
    #   How to use:
    #
    # compound_shortcode(:list, :verb_which_what) do
    #   map(/invitations/i,
    #       :list_invitations,
    #       :which => %w(incoming outgoing))
    # end
    #
    module CompoundCommands
      class KannedError < Palmade::Kanned::KannedError; end

      class CompoundTypeNotSupported < KannedError; end
      class CommandTypeNotSupported < KannedError; end
      class UnknownCommandKey < KannedError; end

      class CompoundCommand
        attr_reader :cmd_key

        def initialize(cmd_key, &block)
          @cmd_key = cmd_key
          @default_map = nil
          @mapping = [ ]

          instance_eval(&block) if block_given?
        end

        def map(regex, method = nil, options = { }, &block)
          @mapping.push([ regex, method, options, block ])
        end

        def default_map(method = nil, options = { }, &block)
          @default_map = [ method, options, block ]
        end

        def match(controller)
          matched = nil
          cmd_params = controller.cmd_params

          unless cmd_params.nil?
            cmd_params = cmd_params.lstrip

            unless @mapping.empty?
              @mapping.each do |map|
                if cmd_params =~ map[0]
                  matched = [ $~.dup ] + map[1..-1]
                  break
                end
              end
            end
          end

          if matched.nil? && !@default_map.nil?
            matched = [ nil ] + @default_map
          end

          matched
        end
      end

      class CompoundCommandVerbWhichWhatWhom < CompoundCommand
        def map(what, method = nil, options = { }, &block)
          which = options[:which]

          if which.nil?
            regex = /\A(#{what})(\s+(\S+))?(\s+(.*))?\Z/im.freeze
          else
            regex = /\A((#{which.join('|')})\s+)?(#{what})(\s+(\S+))?(\s+(.*))?\Z/im.freeze
          end

          super(regex, method, options, &block)
        end

        def match(controller)
          matched = super(controller)

          unless matched.nil?
            regex_matches = matched[0]

            unless regex_matches.nil?
              # Return a matched array as:
              #
              # [ WHICH, WHAT, WHOM, REST ]
              #
              if matched[2].include?(:which)
                matched[0] = [ regex_matches[2].nil? ? nil : regex_matches[2].to_sym,
                               regex_matches[3],
                               regex_matches[5],
                               regex_matches[7] ]
              else
                matched[0] = [ nil,
                               regex_matches[1],
                               regex_matches[3],
                               regex_matches[5] ]
              end
            end
          end

          matched
        end
      end

      module ClassMethods
        def compound_command_and_shortcode(cmd_key, *args, &block)
          compound_command(cmd_key, *args, &block)
          compound_shortcode(cmd_key, *args, &block)
        end

        def compound_command(cmd_key, *args, &block)
          _add_compound_command(:command, cmd_key, *args, &block)
        end

        def compound_shortcode(code_key, *args, &block)
          _add_compound_command(:shortcode, code_key, *args, &block)
        end

        def _add_compound_command(cmd_type, cmd_key, *args, &block)
          case cmd_type
          when :command
            cmd_key, *rest = command(cmd_key, :process_compound_command)
          when :shortcode
            cmd_key, *rest = shortcode(cmd_key, :process_compound_command)
          else
            raise CommandTypeNotSupported, "Unsupported cmd type: #{cmd_type}"
          end

          type = args.first
          case type
          when nil
            cc = CompoundCommand.new(cmd_key, &block)
          when :verb_which_what_whom
            cc = CompoundCommandVerbWhichWhatWhom.new(cmd_key, &block)
          when :verb_what_what
            cc = CompoundCommandVerbWhatWhat.new(cmd_key, &block)
          else
            raise CompoundTypeNotSupported, "Unsupported type: #{type}"
          end

          if text_compound_commands.nil?
            cl = self.text_compound_commands = { }
          else
            cl = self.text_compound_commands
          end

          cl[cmd_key] = cc
        end
      end

      def self.included(base)
        base.extend(ClassMethods)

        class << base
          attr_accessor :text_compound_commands
        end

        base.class_eval do
          attr_reader :cmd_matched
        end
      end

      protected

      def text_compound_commands
        self.class.text_compound_commands
      end

      def process_compound_command
        if text_compound_commands.include?(cmd_key)
          cc = text_compound_commands[cmd_key]

          matched = cc.match(self)
          unless matched.nil?
            @cmd_matched = matched

            logger.debug do
              "  SMS compound command ##{@cmd_key}, params: #{@cmd_matched[0].inspect}"
            end

            if !matched[3].nil?
              instance_eval(&matched[3])
            elsif !matched[1].nil?
              send(matched[1], *matched[0])
            end

            # let's mark it performed, since we found a match
            performed! unless performed?
          end
        else
          raise UnknownCommandKey, "Unknown command key: #{cmd_key}"
        end
      end
    end
  end
end
