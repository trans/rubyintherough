
require 'markups/marker'
#require 'string/blank'

module MarkUps::Markers

  #
  # Paragraph Marker
  #
  class Paragraph < Marker

    priority 0.6
    tags 'p'

=begin
    def self.wiki_match( doc_lines )
      line_ranges = []
      in_paragraph = false
      from_line = 0
      doc_lines.each_with_index do |line, line_no|
        if in_paragraph and line.blank?
          line_ranges << (from_line..(line_no - 1))
          in_paragraph = false
        end
        if not in_paragraph and not line.blank?
          in_paragraph = true
          from_line = line_no
        end
      end
      return line_ranges
    end
=end

    def wiki( doc_lines, line_claim )
      current = nil
      doc_lines.each_with_index do |line, lineno|
        if current
          if line.blank?
            line_claim[lineno-1].endtag self
            doc_lines[lineno] = %{</paragraph>\n}
            current = false
          elsif line =~ %r{^[ ]*[pP]\.}
            line_claim[lineno-1].endtag self
            doc_lines[lineno] = %{</paragraph>\n#{line}}
            current = false
          end
        end
        if !current and line =~ /^[ ]*[pP]\./
          line_claim[lineno].tag self
          doc_lines[lineno] = %{<paragraph>\n#{line.gsub(/^([ ]*)[pP]\.[ ]?/){ $1 }}}
          current = true
        end
      end
      if current
        line_claim[-1].endtag self
        doc_lines[-1] << %{\n</paragraph>}
      end
      return doc_lines, line_claim
    end

    # instance methods

    #def to_xml #( content, attributes )
    #  return "<paragraph>#{content.to_xml}</paragraph>"
    #end

    def to_xhtml( node, info )
      return "<p>#{parser.subconvert(node,:xhtml)}</p>"
    end
    alias_method :to_html, :to_xhtml

  end #class Paragraph

end #module MarkUps::Markers

