
require 'markups/marker'
require 'soap/marshal'

module MarkUps::Markers

  #
  # Data Marker
  #
  class Data < Marker

    priority 0.88
    nosubcycle

    def wiki( doc_lines, line_claim )
      current = nil
      sections = []
      doc_lines.each_with_index do |line, lineno|
        if line =~ /^[ ]*\-\-\-/
          line_claim[lineno].tag self
          doc_lines[lineno] = %{<wiki:data>}
          current = true
        elsif current and line =~ /^[ ]*\.\.\./
          line_claim[lineno].endtag self
          doc_lines[lineno] = %{</wiki:data>}
          current = false
        end
      end
      return doc_lines, line_claim
    end

    def dewiki( text, attributes, info={} )
      d = YAML.load( text )

      xd = XmlElement.new('data')
      xd << xml(SOAP::Marshal.dump( d ))
      xd
    end

    def to_xhtml( node, info )
      d = SOAP::Marshal.load( node[0].to_s )
      info[:data].update(d)
      ''
    end
    alias_method :to_html, :to_xhtml

  end #class Data

end #module MarkUps::Markers


#     def wiki_tag( state )
#       %r{^[ ]*\-\-\-}
#     end
# 
#     def wiki_endtag( state )
#       %r{^[ ]*\.\.\.}
#     end
