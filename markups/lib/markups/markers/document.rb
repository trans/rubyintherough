
require 'markups/marker'

module MarkUps::Markers

  class Document < Marker

    priority 1.0

#     def wiki( doc_lines, line_claim )
#       first_line = doc_lines.find{ |line| ! line.blank? }
#       #if /^[ ]*\[Document\]/m !~ doc
#       if first_line and first_line.strip !~ /^[ ]*\<document/
#         line_claim[0].tag self
#         doc_lines[0] = %{<document>} + doc_lines[0]
#         line_claim[-1].endtag self
#         doc_lines[-1] = doc_lines[-1] + %{\n</document>}
#       end
#       return doc_lines, line_claim
#     end

    # conversion

    def to_xhtml( node, info={} )
      %{<html><body>#{parser.subconvert(node, :xhtml)}</body></html>}
    end
    alias_method :to_html, :to_xhtml

  end #class Document

end #module MarkUps::Markers
