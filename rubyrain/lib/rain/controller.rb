
require 'rain/catalog'
require 'rain/dropfile'

module Rain

  class Controller

    def initialize
      @catalog = Catalog.new
      @catalog.interface = self
    end

    attr :catalog
    attr :interface

    #
    def main
      interface.main
    end

    #
    def drops
      catalog.all_drops
    end

    # catalog commands

    def sync
      catalog.sync
    end

    # reaturn all entries in the catalog

    def entries
      catalog.entries
    end

    # look for an entry

    def lookup( str )
      catalog.lookup( str )
    end

    # install

    def install( file )
      if File.exists?( file )
        rf = DropFile.new( File.open( file ) )
      else
        rf = catalog.lookup( file )
      end
      if rf
        rf.interface = self
        rf.run
      else
        resource_not_found( file )
      end
    end

    # uninstall

    def uninstall( files )
    end


    def register_install( lfile, ldir )
      catalog.register_install( lfile, ldir )
    end


    def resource_not_found( str )
      warn "Resource not found for '#{str}'."
    end

    # for downloader

    def preparing_to_download( file, url, est_size )
      #return file, url, est_size
    end

    def lacks_checksum( checksum, type=:md5 )
      warn "Resource lacks #{type} checksum #{checksum}."
    end

    def lacks_size( size )
      warn "Resource lacks file size #{size}."
    end

    def downloaded( file )
      #puts "Downloaded #{file}."
    end

    def extracted( file )
      #puts "Extracted #{file}."
    end

    # installed

    def installed( file )
      #puts "Installed #{file}."
    end

    # if not an interface method

    def method_missing( sym, *args, &blk )
      warn "Interface does not respond to #{sym}."
    end

  end

end
