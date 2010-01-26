
#require 'facets/string/lines'
require 'markups/fileloader'
require 'markups/parser'

module MarkUps

  # XWiki Document
  #
  # A transitionary phase between wiki and canonical XML.
  # But the format can also be used on its own, bypassing
  # the wiki format.
  #
  class XWikiDocument < String
    extend FileLoader

    def initialize( text, markers=nil )
      @markers = markers || ::MarkUps::ArtMLMarkers
      @parser = Parser.new( @markers )
      self.replace( text )
    end

    def parse
      text = @parser.parse( self )
      XDocument.new( text, @markers, @parser )
    end
  end

  # X Document
  #
  # This is the canonical XML product. From here this document
  # can be converted into any number of formats.
  #
  class XDocument < String
    extend FileLoader

    def initialize( text, markers=nil, parser=nil )
      @markers = markers || ::MarkUps::ArtMLMarkers
      @parser = parser || Parser.new( @markers )
      self.replace( text )
    end

    def markup( adapter=:xhtml )
      text = self.dup  # probably don't need
      @parser.convert( text, adapter )
    end
  end

end
