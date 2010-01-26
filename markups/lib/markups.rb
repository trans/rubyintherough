
require 'yaml'
require 'facets'

#require 'facet/kernel/require_all'
#require 'facets/kernel/require'

require 'markups/document'
require 'markups/wiki_document'

require_all 'markups/markers/*'


module MarkUps

  ArtMLMarkers = Markers::Registry.new

  ArtMLMarkers << Markers::Document
  ArtMLMarkers << Markers::Section
  ArtMLMarkers << Markers::Paragraph
  ArtMLMarkers << Markers::Verbatim
  ArtMLMarkers << Markers::List
  ArtMLMarkers << Markers::Layout
  #ArtMLMarkers << Markers::Frame
  ArtMLMarkers << Markers::Variable
  ArtMLMarkers << Markers::Data
  #ArtMLMarkers << Markers::Red

end


# TODO remove execess whitespace for markup?
module MarkUps
  def self.markup( filename, adapter=:xml )
    out = MarkUps::WikiDocument.file( filename )
    out = out.unwikify
puts out
#exit 0
    out = out.parse
    out = out.markup( adapter ) if adapter != :xml
    puts out
  end

  def self.markup2( filename, adapter=:xml )
    out = MarkUps::XWikiDocument.file( filename )
    out = out.parse
    out = out.markup( adapter ) if adapter != :xml
    puts out
  end
end
