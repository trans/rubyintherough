#!/usr/bin/env ruby

require 'yaml'
require 'facets/arguments'
require 'icli/abstract_host'

# special host services
require 'icli/rubyforge.rb'

module ICli

  class Command

    def self.start
      new.run
    end

    def initialize()
      @command_arguments, @command_options = *CLI::Arguments.parameters

      @config_options   = file_options(@command_options['use'])

      parse_general_options(@command_options)

      @host             = @command_arguments.shift
      @command          = @command_arguments.shift

      if @host
        @host_options     = @config_options[@host].merge(:dryrun=>@dryrun, :trace=>@trace)
        @command_options  = @command_options.merge(@config_options[@host][@command] || {})
      end
    end

    def run
      host = host_class(@host).new(@host_options)
      if host.commands.include?(@command)
        host.send(@command, @command_options)  # TODO Add command_arguments?
      else
        puts "Unknown command -- #{@command}"
      end
    end

    private

      def parse_general_options(options)
        @dryrun = %w{dryrun dry-run noharm}.any?{ |o| options.delete(o) }
        @trace = %w{trace}.any?{ |o| options.delete(o) }
      end


      def dryrun? ; @dryrun ; end
      def trace?  ; @trace  ; end


      # Print help usage to stadout.
      def help
        puts DATA.read
      end

      #
      def host_class(name)
        ICli.factory(name)
      end

      def file_options(fname=nil)
        file = config_file(fname)
        if file
          YAML::load(File.open(file))
        elsif fname
          raise ArgumentError, "Parameter file not found -- #{fname}" unless file
        else
          {}
        end
      end

      def config_file(fname=nil)
        if fname
          Dir.glob("#{fname}{.yaml,.yml,}").first
        else
          Dir.glob("{meta/icli,.icli}{.yaml,.yml,}").first
        end
      end

#       #
#
#       def config_load(section=nil)
#         if file = config_file
#           options = YAML::load(File.open(file))
#         else
#           options = {}
#         end
#         # merge in the selected section
#         if section
#           options.merge!(options[section.to_s] || {})
#         end
#         # remove subsections (should we bother?)
#         options = options.delete_if{ |k,v| Hash === v }
#         # return
#         return options
#       end


  end
end


=begin

    class CommonOptions < Console::Command::Options
      attr_accessor :host,
                    :domain,
                    :username
    end

    class ReleaseOptions < CommonOptions
      attr_accessor :store,      # Package folder.
                    :files,      # Files to release.
                    :package,    # Package name.
                    :version,    # Package version.
                    :release,    # Release name. Defaults to +version+.
                    :date,       # Release Date. Defaults to +Time.now+.
                    :processor,  # Processor type. Deafults to +Any+.
                    :changelog,  # ChangeLog file.
                    :notelog,    # Notes file.
                    :is_public   # Is this release public?
    end

    class PublishOptions < CommonOptions
      attr_accessor :root        # directory with website files
    end

    class AnnounceOptions < CommonOptions
      attr_accessor :subject,
                    :message
    end

    #

    options :publish,  PublishOptions
    options :release,  ReleaseOptions
    options :announce, AnnounceOptions
    options :touch,    CommonOptions

    # Publish
    #
    #     root        directory with website files

    def publish
      options = config_load('publish')

      # merge in any commandline options
      options.merge!(PublishOptions.parse.to_h)

      name = options['host'] || options['domain']
      host = host_class(name).new(options)

      host.publish(options)
    end

    # Release options. This is a hash of options:
    #
    #     store        Location of packages.
    #     version      Package version.
    #     files        Files to release. (defaults to source/package-version.*)
    #     package      Package name (defaults to +project+).
    #     release      Release name (defaults to +version+).
    #     date         Release Date (defaults to to +Time.now+).
    #     processor    Processor type (deafults to +Any+).
    #     changelog    ChangeLog file.
    #     notelog      Notes file.
    #     is_public    Is this release public?
    #

    def release
      options = config_load('release')

      # merge in any commandline options
      options.merge!(@options.to_h) #(ReleaseOptions.parse.to_h)

      #options = {}
      #options.update info.gather('rubyforge')
      #options.update info.gather('release')
      #options.update info.select('version', 'changelog', 'notelog', 'processor'=>'arch')
      #options['files'] = Dir[File.join(info.package_store,"*#{options['version']}.*")]

      store = options['store']
      name  = options['package']
      vers  = options['version']

      options['files'] ||= Dir[File.join(store,"#{name}-#{ver}.*")]

      name = options['host'] || options['domain']
      host = host_class(name).new(options)

      host.release(options)
    end

    # Annouce to news.

    def announce
      options = config_load('announce')

      # merge in any commandline options
      options.merge!(AnnounceOptions.parse.to_h)

      name = options['host'] || options['domain']
      host = host_class(name).new(options)

      host.announce(options)
    end

    # Test connection. Simply login and logout.

    def touch
      options = config_load

      # merge in any commandline options
      options.merge!(@options.to_h) #(CommonOptions.parse.to_h)

      name = options['host'] || options['domain']
      host = host_class(name).new(options)

      host.touch
    end


    # Default action (no subcommand)

    alias_method :default, :help


#     def start
#       config = File.file?(CONFIG_FILE) ? YAML::load(f) : {}
#       section = (@args[0] || 'all').to_s.downcase
#
#       if section == 'all'
#         config.each do |name, settings|
#           settings.update(@keys)
#           press(settings)
#         end
#       else
#         settings = config[section]
#         settings.update(@keys)
#         press(settings)
#       end
#     end*/
=end


__END__

Forge v0.2.0

Usage: icli <command> <options>

Commands:

  touch
    Test connection. This simply attempts to login and logout.

  release
    Release a package.

  announce
    Make an announcement via news.

  publish
    Publish website files.

Common Options:

  --host
    The host name (eg. rubyforge). If LaForge supports the
    host name then a specialized adatapter will be used.

  --domain
    The domain name of the host. If the host is not build in
    you can supply the domain name instead of the host name.
    The generic GForge adapter will be used.

  --username
    Your username on the host.

For more information, http://proutils.rubyforge.org.
