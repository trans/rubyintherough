
module MarkUps

  module FileLoader
    def file( fname, markers=nil )
      str = ''
      File.open( fname ) { |f| str = f.gets(nil) }
      self.new( str, markers )
    end
  end

end
