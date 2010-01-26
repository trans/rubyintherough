
require 'markups/fileloader'
#require 'string/lines'

module MarkUps

  # Wiki Document
  #
  # This is the wiki document object which serves as a
  # starting point of transformation.
  #
  class WikiDocument < String
    extend FileLoader

    def initialize( text, markers=nil )
      @markers = markers || ::MarkUps::ArtMLMarkers
      self.replace( text )
    end

    def unwikify
      text_lines = self.lines
      line_claims = Array.new(text_lines.size){ TagClaimPair.new }
      @markers.markers.each { |m|
        m.wiki( text_lines, line_claims ) if m.respond_to?(:wiki)
      }

#       str = []
#       line_claims.each_with_index{ |l, i|
#         unless l.tag.empty?
#           str << l.tag.join("\n")
#         end
#         str << text_lines[i]
#         unless l.endtag.empty?
#           str << l.endtag.join("\n")
#         end
#       }

      XWikiDocument.new( text_lines.join("\n"), @markers )
    end
  end #class WikiDocument






















  class TagClaimPair
    def initialize
      @tag = []
      @endtag = []
    end
    def tag( marker=nil )
      if marker
        @tag.push marker
      end
      @tag
    end
    def endtag( marker=nil )
      if marker
        @endtag.push marker
      end
      @endtag
    end
  end

#   class TagClaimPair
#     def initialize
#       @tag = []
#       @tag_marker = []
#       @endtag = []
#       @endtag_marker = []
#     end
#     def tag( tagtext=nil, marker=nil )
#       raise ArgumentError if tagtext and !marker
#       if tagtext
#         @tag.push tagtext
#         @tag_marker.push marker
#       end
#       @tag
#     end
#     def endtag( tagtext=nil, marker=nil )
#       raise ArgumentError if tagtext and !marker
#       if tagtext
#         @endtag.push tagtext
#         @endtag_marker.push marker
#       end
#       @endtag
#     end
#     def tag_marker
#       @tag_marker
#     end
#     def endtag_marker
#       @endtag_marker
#     end
#   end


end
