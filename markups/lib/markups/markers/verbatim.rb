
require 'markups/marker'

module MarkUps::Markers

  #
  # Verbatim Marker
  #
  class Verbatim < Marker

    priority 0.65

    def wiki( doc_lines, line_claim )
      current = nil
      doc_lines.each_with_index do |line, lineno|
        if line =~ /^[ ]*\"\"\"/
          if current
            line_claim[lineno].endtag self
            doc_lines[lineno] = '</verbatim>'
            current = false
          else
            line_claim[lineno].tag self
            doc_lines[lineno] = '<verbatim>'
            current = true
          end
        end
      end
      # trailing verbatim
      if current
        line_claim[-1].endtag self
        doc_lines[-1] += "\n</verbatim>"
      end
      return doc_lines, line_claim
    end

    def remodel( node, info )
      node.attributes.delete('xml:cdata')
    end

    def to_xhtml( node, info )
      %{<pre#{node.attributes}>\n#{node.text}\n</pre>}
    end
    alias_method :to_html, :to_xhtml

  end #class Verbatim

end #module MarkUps::Markers
