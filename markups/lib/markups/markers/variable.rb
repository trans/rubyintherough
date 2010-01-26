
require 'markups/marker'

module MarkUps::Markers

  #
  # Variable
  #
  class Variable < Marker

    unit
    tags 'var'
    priority 0.1

=begin
    def self.wiki_match( doc_lines )
      on = nil
      line_ranges = []
      doc_lines.each_with_index do |line, lineno|
        if on and line.blank?
          on[:to] = lineno - 1
          line_ranges << on
          on = nil
        end
        if not on and line =~ /^([ ]{4,}|\t\t)/
          on = { :from => lineno }
        end
      end
      return line_ranges
    end
=end

    #def remodel(node, info )
      #XmlText.new(info[:data][node.attributes['name']].to_s)
    #end

    def to_xhtml( node, info )
      info[:data][node.attributes['name'].to_s]
    end
    alias_method :to_html, :to_xhtml

  end #class Variable

end #module MarkUps::Markers
