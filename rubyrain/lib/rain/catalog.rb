
require 'ftools'
require 'yaml'

require 'rbconfig'
require 'fileutils'

require 'facet/downloader'


module Rain

  # CatalogClass
  #
  class Catalog

    DATADIR = File.join( Config::CONFIG['datadir'], 'site_ruby/rain' )

    attr_accessor :region, :catalog_urls

    def initialize( catfile=nil )
      catfile ||= File.join( DATADIR, 'catalog.run' )
      unless FileTest.exists?( catfile )
        raise IOError, "Could not find catalog run file:\n#{catfile}"
      end
      @catdir = File.join( DATADIR, 'catalog' )
      @locdir = File.join( DATADIR, 'local' )
      @insdir = File.join( DATADIR, 'installed' )
      @catrun = File.read(catfile)
      @cache = {}
    end

    def interface ; @interface ; end
    def interface=(iface)
      @interface = iface
    end

    # synchronizies local copy of catalog with remote master catalog
    def sync
      File.makedir_p( @catdir ) unless File.directory?( @catdir )
      rf = DropFile.new( @catrun )
      rf.interface = interface
      success = rf.run
      success
    end

    def entries( local=false )
      dir = local ? @locdir : @catdir
      Dir.chdir( dir ) { Dir["[^.]*"] }
    end

    def drops( local=false )
      entries( local ).collect { |e| get(e) }
    end

    # Search catalog entries by name
    def search( pattern, local=false )
      pat = "^#{pattern}".gsub('*','.*')
      entries( local ).grep( Regexp.new(pat, Regexp::IGNORECASE) )
    end

    # Search catalog entries by criteria
    #def grep( pattern )
    #end

    # read in a dropfile, either from the catalog or local
    def get( rname, local=false )
      dir = local ? @locdir : @catdir
      fname = File.join(dir, rname)
      return nil unless File.exists?( fname )
      unless @cache[rname]
        @cache[rname] = DropFile.new( File.new( fname ) )
      end
      return @cache[rname]
    end

    # Find catalog entry by name
    def lookup( reference, local=false )
      dir = local ? @locdir : @catdir
      rname = resolve_name( reference, local )
      return nil if ! rname
      unless @cache[rname]
        @cache[rname] = DropFile.new( File.new( File.join(dir, rname) ) )
      end
      return @cache[rname]
    end

    # resolves a program name making sure it exists and getting latest + version.
    def resolve_name( reference, local=false )
      dir = local ? @locdir : @catdir
      resolved_name = nil  # will return nil if can't resolve
      possible_name = reference.strip
      if File.exists?( File.join(dir, possible_name) )
        resolved_name = possible_name
      else
        #if possible_name[-1..-1] == '+'
        # okay lets see what recipes fit the bill
        pattern = "#{possible_name}*"
        possiblities = search( pattern )
        if possiblities.length > 0
          # get the latest version
          latest_name = possiblities.sort.reverse[0]  # TODO this isn't perfect (fix using #natcmp)
          # is it later then whats wanted?
          if latest_name > possible_name
            resolved_name = latest_name
            #puts "Using best match...#{resolved_name}" if Settings.opt_verbose
          end
        end
        #else  # okay the name is good but does it exist?
        #  resolved_name = possible_name if File.exists?(File.join(Settings.catalog_dir, possible_name))
        #end
      end
      return resolved_name
    end

    #
    def resolve_names( *references )
      resolved = []; unresolved = []
      references.each do |unresolved_name|
        resolved_name = resolve_name(unresolved_name)
        if resolved_name
          resolved << resolved_name  # :)
        else
          unresolved << unresolved_name  # :(
        end
      end
      return resolved, unresolved
    end

    # Once installed by dropfile this will register the install
    # in the local catalog.
    def register_install( dropfile, repdir )
      instfile = File.join( repdir, 'InstalledFiles' )
      if File.exists?( instfile ) # did anything actually change?
        FileUtils.cp( dropfile, @locdir )
        # make install record dir
        name = File.basename( repdir )
        instdir = File.join( DATADIR, 'installed', name, Time.now.strftime("%Y_%m_%d_%H_%M_%S") )
        FileUtils.mkdir_p( instdir )
        # copy drop file to install record
        FileUtils.cp( dropfile, instdir )
        # copy setup.rb list of installed file to install record
        FileUtils.mv( instfile, instdir )
      end
    end

#     # new recipe from template file
#     # currently only 'simple' recipe type (the name of file in templates dir)
#     def template(recipe_type, recipe_name, recipe_version)
#       recipe_version = '1.0.0' if recipe_version.strip == ''
#       from_file = File.join(Settings.templates_dir,"#{recipe_type}")
#       to_file = File.join(Settings.catalog_dir,"#{recipe_name}--#{recipe_version}")
#       if FileTest::exists?(to_file)
#         raise BakerError, "source recipe already exists"
#       elsif !FileTest::exists?(from_file)
#         raise BakerError, "template recipe does not exist"
#       end
#       File.syscopy(from_file, to_file)
#       if FileTest::exists?(to_file)
#         return "#{recipe_name}--#{recipe_version}"
#       else
#         raise "could not write for #{to_path}, permissions correct?"
#       end
#     end

  end  #Catalog

end  # Baker
