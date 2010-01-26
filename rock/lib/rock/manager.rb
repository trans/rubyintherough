

module Rock

  class DependencyError < LoadError
  end

  #
  #

  class DependencyManager

    ROCK_CATALOG_ADDR = ""

    def self.install( deps )
      rmgr = new
      rmgr.install_dependencies( deps )
    end

    attr_reader :tmpdir, :catdir, :catfile

    def initialize
      @tmpdir = File.join( Dir.tmpdir, 'rock' )
      @catdir = File.join( @tmpdir, 'catalog' )
      @catfile = File.join( @catdir, File.basename(ROCK_CATALOG_ADDR) )
    end

    #

    def install_dependencies( deps )
      deps.each do |dep|
        fname = download( dep )
        unless fname
          raise DependencyError, "Depenedency could not be found -- #{dep}"
        end
        rfile = Rockfile.new
        unless rfile.valid?( fname )
          raise DependencyError, "Depenedency failed verifications -- #{dep}"
        end
        filelist << rfile
      end
      filelist.each do |rfile|
        rfile.install
      end
    end

    #

    def dependency( name, version=nil )
      vers = catalog[name]
      if version
        # ...
      else
        addr = vers.max{ |k,v| k }
      end
      download( addr )
    end

    #

    def catalog
      return @catalog if @catalog
      download( ROCK_CATALOG_ADDR ) unless catalog?
      @catalog = YAML.load( File.new( catfile ) )
    end

    #

    def catalog?
      if File.exist?( catfile )
        return catfile
      else
        nil
      end
    end

    #

    def download( addr, subdir=nil )
      fname = File.basename(addr)
      dir = File.join( *[tmpdir, subdir, fname].compact )
      mkdir_p dir
      Dir.chdir( dir ) do
        File.open( fname, 'w' ) do |fw|
          open( addr ){ |f| fw << f.read }
        end
      end
      File.join( dir, fname )
    end

    #

    def install( file )
      RockFile.new.install( file )
    end

  end

end
