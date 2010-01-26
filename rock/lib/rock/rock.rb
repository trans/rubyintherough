# = rock.rb

require 'rbconfig'
require 'yaml'
require 'fileutils'
require 'zlib'
require 'digest/md5'

require 'roll/project'

require 'rock/pathhash'
require 'rock/rollable'

#
def __DIR__
  File.dirname( File.expand_path(__FILE__) )
end

# = Rock File
#
# A RockFile stores the contents of a directory much like a tar file, but it
# organizes the contents into a YAML document, which is gzipped and placed
# in the data section (after __END__) of a ruby script.
#
# Running the Rock file will decompress the file into a temproary location and
# install the project using setup.rb.
#
# == Future
#
# In the future, we will allow rbr's to be installed via a system's native
# package manager by routing via Sow. We may also offer the options of installing
# to special location, a la gems.

class RockFile

  EXT = '.rbr'

  DATADIR = File.join( Config::CONFIG['datadir'], 'rock_registry' )

  class PathHash
    include Rollable
  end


  def initialize( dir_or_store )
    @hashfs = nil
    @yamlfs = nil
    @gzipfs = nil
  end

  # Roll layout?

  def roll?() $ROLL end

  # Install rock data.

  def install( file, gzipfs=nil )
    dir = tmpdir( file )

    if gzipfs
      @gzipfs = gzipfs
    else
      read_envelope( file )
    end

    inflate
    hashize
    write( dir )

    # install
    project = project_info( dir )
    if deps = project.package.dependencies
      RockManager.install_dependencies( deps )
    end

    Dir.chdir( dir ) do
      # ensure setup.rb
      unless FileTest.file?( 'setup.rb' )
        FileUtils.cp( File.join(__DIR__,'setup.rb'), '.' )
      end
      system "ruby setup.rb"

      # register the install
      regdir = File.join( DATADIR, project.name, project.version ) 
      FileUtils.mkdir_p( regdir )
      FileUtils.cp( 'InstalledFiles', regdir )
    end
  end

  #

  def tmpdir( file )
    require 'tmpdir'
    dir = File.join( Dir.tmpdir, 'rock', File.basename(file).chomp(EXT) )
    FileUtils.rm_r dir if File.exist?( dir )
    FileUtils.mkdir_p dir
    dir
  end

#   # Validate rock file.
#
#   def valid?( file )
#     iscript = ''
#     comp, md5 = nil, nil
#     File.open( file, 'r' ) do |f|
#       md5 = f.gets.chomp("\n")[1..-1]
#       until f.eof?
#         l = f.gets
#         iscript << l
#         if l == "__END__\n"
#           comp = f.read
#           break
#         end
#       end
#     end
#     return false if iscript.strip != ISCRIPT.strip
#     return false if md5 != Digest::MD5.hexdigest(comp)
#     true
#   end

  # Create a rock file

  def create( folder )
    raise LoadError, "#{folder} not a folder" unless FileTest.directory?(folder)
    file = File.basename(folder) + EXT
    if FileTest.exist?(file)
      raise "#{file} already exists"
    end

    read( folder )
    yamlize
    deflate
    write_envelope( file )
  end

  # Extract a rock file.

  def extract( file )
    raise LoadError, "#{file} not a file" unless FileTest.file?( file )
    folder = file.chomp(File.extname(file))
    if FileTest.exist?(folder)
      raise "#{folder} already exists"
    end

    read_envelope( file )
    inflate
    hashize
    write( folder )
  end

  # Yamlize.

  def yamlize
    @yamlfs = @hashfs.to_yaml
  end

  # Hashize.

  def hashize
    @hashfs = YAML.load( @yamlfs )
  end

  # Deflate

  def deflate
    @gzipfs = Zlib::Deflate.deflate( @yamlfs, Zlib::BEST_COMPRESSION )
  end

  # Inflate

  def inflate
    @yamlfs = Zlib::Inflate.inflate( @gzipfs )
  end

  # Read

  def read( file )
    raise LoadError, "#{file} not a folder" unless FileTest.directory?( file )
    data = PathHash.read( file )
    roll( data, file ) if roll?
    @hashfs = data.to_h
  end

  # Write.

  def write( folder )
    PathHash[@hashfs].write( folder )
  end

  # Read envelope.

  def read_envelope( file )
    raise "not a file" unless FileTest.file?( path )
    md5, script, gzipfs = nil, '', nil
    File.open( file, 'r' ) do |f|
      md5 = f.gets.chomp("\n")[1..-1]
      until f.eof?
        l = f.gets
        script << l
        if l == "__END__\n"
          f.binmode
          gzipfs = f.read
          break
        end
      end
    end
    return @md5, @script, @gzipfs = md5, script, gzipfs
  end

#     comp = nil
#     File.open( path, 'r' ) do |f|
#       l = f.gets until l == "__END__\n"
#       f.binmode
#       comp = f.read
#     end
#     @gzipfs = comp
#   end

  # Write envelope.

  def write_envelope( path )
    md5 = Digest::MD5.hexdigest(@gzipfs)
    File.open( path, 'w' ) do |f|
      f << "##{md5}\n"
      f << SCRIPT
      f.binmode
      f.print @gzipfs
    end
    path
  end

  # Roll.

  def roll( data, path )
    project = project_info( path )
    if project
      data.roll( project.version )
      data.add_index( project )
    else
      raise LoadError, "can't roll without project file"
      # TODO if we had a version we could
      #data.roll( version )
    end
  end

  #

  def project_info( path )
    @project_info ||= Dir.chdir( path ){ break Roll::Project.load }
  end

  # Validate rock file.

  def valid?( file=nil )
    read_envelope( file ) if file
    return false if @script.strip != SCRIPT.strip
    return false if @md5 != Digest::MD5.hexdigest(@gzipfs)
    true
  end

end

# ISCRIPT Header

RockFile::SCRIPT = <<-END
require 'rock/rock'
RockFile.install($0,DATA)
__END__
END
