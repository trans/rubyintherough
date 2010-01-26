
require 'markups/marker'

module MarkUps::Markers

  #
  # Marker Section
  #
  class Section < Marker

    priority 0.89
    count

    def wiki_start( state )
      i = state.text.index( /^[ ]{0,3}([=]+)\s*(\S+)\s*([=]*)/, state.offset )
      return i, $~.end(0), { :name => $~[2], :level => $~[1].size } if i
      return nil,nil,nil
    end

    def wik_stop( state )
      i = state.text.index( /^[ ]{0,3}([=]+)\s*(\S+)\s*([=]*)/, state.offset )

    end

    # The remodel method takes an Xml object as parameter.
    # Output is expected to be the same. Modify the node in place.
    # is preferred. An "information" hash is also passed in.
    def remodel( node, info={} )
      level = info[:count] || 1
      node.attributes['level'] = level
      node
    end

    def to_xhtml( node, info )
      i = node.attributes['level']
      t = node.attributes['title'] || node.attributes['name']
      %{<h#{i}>#{t}</h#{i}>#{parser.subconvert(node, :xhtml)}}
    end
    alias_method :to_html, :to_xhtml

  end #class Section

end #module MarkUps::Markers






#     def wiki( doc_lines, line_claim )
#       current = nil
#       stack = []
#       doc_lines.each_with_index do |line, lineno|
#         if line =~ /^[ ]{0,3}([=]+)\s*(\S+)\s*([=]*)/
#           level = $1.size
#           title = $2
#           while stack.last and stack.last >= level
#             stack.pop
#             line_claim[lineno].endtag self
#             doc_lines[lineno] = %{</section>}
#             current = nil
#           end
#           line_claim[lineno].tag self
#           doc_lines[lineno] = %{\n<section title="#{title}" level="#{level}">}
#           stack << lineno
#         end
#       end
#       while stack.last
#         stack.pop
#         line_claim[-1].endtag self
#         doc_lines[-1] << %{\n</section>}
#       end
#       return doc_lines, line_claim
#     end

#     def wiki( doc_lines )
#       doc = []
#       stack = []
#       doc_lines.each_with_index do |line, lineno|
#         if line =~ /^[ ]{0,3}([=]+)\s*(\S+)\s*([=]*)/
#           level = $1.size
#           while stack.last and stack.last >= level
#             s = stack.pop
#             doc << "</section>"
#           end
#           doc << %Q{<section title="#{$2}" level="#{level}">}
#           stack << level
#         else
#           doc << line
#         end
#       end
#       while stack.last
#         s = stack.pop
#         doc << "</section>"
#       end
#       return doc
#     end


#     def wiki_tag( state )
#       %r{^[ ]{0,3}([=]+)\s*(\S+)\s*([=]*)}
#     end
# 
#     def wiki_endtag( state )
# y state
#       m = state.reverse.find { |s| s.respond_to?(:token) && ! s.token === self }
#       if m
#         m.re_endtoken
#       else
#         %r{\Z}
#       end
#     end
