class RockFile

  # = PathHash
  #
  # PathHash stores files in a hash organized
  # according to the path hierarchy.
  #
  #   foo/bar.txt
  #   foo/bar/gee.txt
  #
  # would be
  #
  #   ph['foo']['bar.txt']
  #   ph['foo']['bar']['gee.txt']
  #

  class PathHash < Hash

    # Read.

    def self.read( path, glob="**/*" )
      raise LoadError, "#{path} not a folder" unless File.directory?( path )
      data = new
      Dir.chdir( path ) do
        entries = Dir.glob(glob)
        entries.each do |path|
          if File.directory?(path)
            data[path] = self.new
          elsif File.file?(path)
            File.open(path, 'rb'){|f| data[path] = f.read }
          end
        end
      end
      data
    end

    #

    def []( path )
      dir = File.dirname(path)
      dir = nil if dir  == '.'
      if dir
        base = File.basename(path)
        self[dir] ||= PathHash.new
        self[dir][base]
      else
        super
      end
    end

    #

    def []=( path, value )
      dir = File.dirname(path)
      dir = nil if dir  == '.'
      if dir
        base = File.basename(path)
        self[dir][base] = value
      else
        super
      end
    end

    alias :fetch :[]
    alias :store :[]=

    def to_h
      Hash[self]
    end

    # Write.

    def write( path )
      FileUtils.mkdir_p( path )
      Dir.chdir(path) do
        each do |fn,c|
          case c
          when PathHash
            c.write( fn )
          else
            File.open( fn, 'wb' ){ |f| f << c }
          end
        end
      end
    end

  end

end
