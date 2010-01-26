
# Marker

require 'facets'
#require 'module/basename'
#require 'string/blank'
#require 'string/tabto'
#require 'comparable/clip'

require 'markups/registry'


module MarkUps

  module Markers

    #
    # Marker
    #
    class Marker

      class << self
        #def wiki? ; @wiki ; end
        #def wiki(b=true)  ; @wiki = b  ; end

        # tag's priority
        def priority(x=nil)
          @priority = x if x
          @priority
        end

        # do not parse content
        def nosubcycle? ; @nosub ; end
        def nosubcycle(b=true)  ; @nosub = b  ; end

        # keep nested count of occurances of this tag
        def count? ; @count ; end
        def count(b=true) ; @count = b ; end

        # is it a unit token
        def unit? ; @unit ; end
        def unit(b=true)  ; @unit = b  ; end

        # stores alternate tag names
        def tags(*tags) ; @tags ||= [] ; @tags |= tags ; end

      end

      attr :registry

      def initialize( registry )
        #@registry = registry
      end

      def parser
        #@registry.parser
        $parser
      end

      def <=>(other)
        self.class.priority <=> other.class.priority
      end

      #def wiki?  ; self.class.wiki?  ; end
      def count? ; self.class.count? ; end
      def unit?  ; self.class.unit?  ; end
      def nosubcycle?  ; self.class.nosubcycle?  ; end

      def tag ; [ self.class.basename.downcase ] | self.class.tags ; end

#       # start tag regular expression
#       def re_tag( state )
#         if respond_to?(:wiki_tag)
#           Regexp.new( "(<(#{tag.join("|")}).*?>|#{wiki_tag( state ).source})" )
#         else
#           Regexp.new( "(<(#{tag.join("|")}).*?>)" )
#         end
#       end
#
#       # end tag regular expression
#       def re_endtag( state )
#         if respond_to?(:wiki_endtag)
#           Regexp.new( "(</(#{tag.join("|")})>|#{wiki_endtag( state ).source})" )
#         else
#           Regexp.new( "(</(#{tag.join("|")})>)" )
#         end
#       end

#       # next start, either xml-tag or wiki
#       def start( text, offset, state )
#         i,m,h = nil,nil,{}
#
#         if respond_to?(:wiki_tag)
#           i = text.index( wiki_tag( state ), offset )
#           if i
#             m = $~
#             h = wiki_tag_info( m )
#           end
#         end
#
#         xre = Regexp.new( "(<(#{tag.join("|")}).*?>)" )
#         j = text.index( xre, offset )
#         if j and ( !i or j < i )
#           i, m, h = j, $~, {}
#         end
#
#         return( i, m.end(0), h ) if i
#         return nil, nil, nil
#       end
#
#       # next stop, either xml-tag or wiki
#       def stop( text, offset, state )
#         Regexp.new( "(</(#{tag.join("|")})>" )
#
#         i = text.index( re_endtag( state ), offset )
#         return( i, $~.end(0) ) if i
#         return nil, nil
#       end
#
#       # data to pass along wiki tag
#       def wiki_tag_info( match ) ; {} ; end

      # The wiki method ....
      #
      #  def wiki( doc_lines )
      #    return doc_lines
      #  end

      # The dewiki method ....
      #
      #   def dewiki( content, attributes, info={} )
      #     %{<name>#{parser.subparse(...)}</name>}
      #   end

      # The remodel method takes a Xml object as parameter.
      # Output is expected to be the same. Modifying the node in place
      # is acceptable. An "information" hash is also passed in that
      # contains state info per the marker.
      #
      #   def remodel( node, info={} )
      #     return node
      #   end

    end #class Marker

  end # module Markers

end #module MarkUps
