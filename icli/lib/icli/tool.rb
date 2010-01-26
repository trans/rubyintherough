require 'fileutils'
require 'facets/ziputils'

p "TOOL!"

module Forge

    # Tool class provides a base class
    # for packaging tools.

    class Tool
      attr_accessor :dryrun
      attr_accessor :trace
      attr_accessor :force
      attr_accessor :quiet
      attr_accessor :mode

      attr_reader :settings

      # New Tool.

      def initialize( settings )
        @settings = settings
        settings.each do |k,v|
          send("#{k.to_s.downcase}=",v)
        end

        if dryrun?
          extend FileUtils::DryRun
          extend ZipUtils::DryRun
        else
          extend FileUtils
          extend ZipUtils
        end
      end

      def dryrun?  ;  @dryrun ; end
      def trace?   ;  @trace  ; end
      def force?   ;  @force  ; end
      def quiet?   ;  @quiet  ; end
      def verbose? ; !@quiet  ; end
      def mode     ;  @mode   ; end

      # Verbosity mode allows for gradations of output
      # types. Generally recognized values are:
      #
      #   quiet    (same as quiet flag)
      #   normal   (default mode)
      #   verbose  (give details)
      #   progress (use progress bar)
      #
      # You add another mode if you need. any task that
      # doesn't recognize the current mode should fallback
      # to normal.

      def mode
        return 'quiet' if quiet?
        (@mode || 'normal').downcase
      end

      # Shell out.

      def sh(cmd)
        puts cmd unless quiet?
        system(cmd) unless dryrun?
      end

      # Extra filesystem util

      def cd(dir, &block)
        status "cd #{dir}"
        Dir.chdir(dir, &block)
      end

      # Internal status report.
      # Only output if dryrun or trace mode.

      def status(message)
        puts message if dryrun? or trace?
      end

      # Standard message to user.
      # Output unless quiet.

      def say(message)
        puts message unless quiet?
      end
    end

end


=begin
    #   # Dump project information.
    #   #
    #   def dump( type='yaml' )
    #     case type.to_s.downcase
    #     when 'xoxo'
    #       puts metadata.to_xoxo
    #     else
    #       puts metadata.to_yaml
    #     end
    #   end

    # apply naming policy
    #
    def apply_naming_policy(name, ext)
      return name unless info.naming_policy
      policies = info.naming_policy.split(' ')
      policies.each do |policy|
        case policy
        when 'downcase'
          name = name.downcase
        when 'upcase'
          name = name.upcase
        when 'capitalize'
          name = name.capitalize
        when 'extension'
          name = name + ".#{ext}"
        when 'plain'
          name = name.chomp(File.extname(name))
        end
      end
      return name
    end
=end

# CREDIT Thomas Sawyer
