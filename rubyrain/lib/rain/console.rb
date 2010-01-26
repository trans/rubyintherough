
require 'facets'
require 'facet/string/margin'

require 'rain/controller'
require 'optparse'

module Rain

  class Console

    def initialize
      @interface = 'console'
      @verbose = false
      @debug = false
      @cmd = nil
      setup_options
    end

    # Setup all the command options.
    def setup_options

      # Setup from command line arguments.

      parser = OptionParser.new do |opts|

        opts.banner = '  Options:'

        ifaces = %w{ console web }
        opts.on('-I', '--interface', ifaces, "Interface type (#{ifaces.join(',')}).") do |iface|
          @interface = iface
        end

        #opts.on('-V', '--verbose', 'Verbose mode.') do
        #  @verbose = true
        #end

        opts.on('-i', '--install', 'Install drop package.') do
          @cmd = "install"
        end

        opts.on('-u', '--uninstall', 'Uninstall drop package.') do
          @cmd = "uninstall"
        end

        opts.on('-d', '--debug', 'Run in debug mode.') do
          @debug = true
        end

        opts.on('-v', '--version', 'Show version.') do
          puts "Rain #{Rain::VERSION}"
          exit
        end

        opts.on('-h', '--help', 'Show this information.') do
          help
          puts opts
          puts
          exit
        end

      end

      parser.parse!(ARGV)

      return self
    end

    # Display help information.
    def help
      puts %{
      |
      |  Ruby Rain v#{Rain::VERSION}
      |
      |  Usage: rain [options] [command] [file]
      |
      |  Commands:
      |    install     Install package(s).
      |    remove      Remove package(s).
      |    uninstall   Same as 'remove'.
      |    sync        Sync local package catalog with master catalog.
      |    update      Same as 'sync'.
      |    upgrade     Upgrade package(s) to latest versions.
      |    list        List all packages by name.
      |    lookup      Search for a package by name.
      |    detail      Like lookup but gives complete details.
      |    help        Show this info (Same as options -h, --help).
      |
      }.margin
      puts
    end

    # Run Rain
    def go
      exit if ARGV.empty?

      ctrl = ConsoleController.new

      if @cmd
        cmd = @cmd
        files = ARGV
      else
        cmd = ARGV[0].downcase
        files = ARGV[1..-1]
      end

      case cmd
      when 'install'
        ctrl.install( files.first )
      when 'uninstall'

      when 'sync', 'update'
        ctrl.sync
      when 'upgrade'

      when 'search'

      when 'ls'
        ctrl.ls
      when 'list'
        ctrl.list
      when 'show'
        ctrl.show( files.first )
      when 'detail'
        ctrl.detail( files.first )
      else
        puts "Unrecognized command."
      end
    end

  end #class Main


  class ConsoleController < Controller

    def ls
      entries.sort.each { |e| puts e }
    end

    def list
      puts "\n*** Catalog ***\n"
      entries.sort.each { |e| show( e ) }
      puts
    end

    def show( str )
      drop = lookup( str )
      if drop
        puts "\n#{drop.name} (#{drop.version})\n    #{drop.title}. #{drop.description}\n"
      else
        resource_not_found( str )
      end
    end

    def detail( str )
      drop = lookup( str )
      if drop
        puts drop.to_yaml
      else
        resource_not_found( str )
      end
    end


    def resource_not_found( str )
      puts "Resource not found for '#{str}'."
    end

    # general reporting

    def report( msg ); puts msg ; end

    # for downloader

    def preparing_to_download( file, url, est_size )
      print "File: #{ file } "
      if est_size and est_size != 0
        print %{(#{est_size} KBytes)}
      end
      puts
      puts "URL: #{url}"
    end

    def lacks_checksum( checksum, type=:md5 )
      puts "Warn: Resource lacks #{type} checksum #{checksum}."
    end

    def lacks_size( size )
      puts "Warn: Resource lacks file size #{size}."
    end

    def downloaded( file )
      #puts "Downloaded #{file}."
    end

    def extracted( file )
      puts "Extracted #{file}."
    end

    # installed

    def installed( file )
      puts "Installed #{file}."
    end

  end

end

