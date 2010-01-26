
require 'markups/marker'
require 'redcloth'

module MarkUps::Markers

  #
  # RedCloth Section Marker (experimental)
  #
  class Red < Marker
   
#     def self.priority ; 800 ; end
#   
#     def self.match?(tag)
#       'red' == tag.downcase
#     end

    # instance methods

    def to_xml #( content, attributes )
      q = []
      q << "<redcloth>"
      q << RedCloth.new( content.join('') ).to_html
      q << "</redcloth>"
      q.join("\n")
    end

    def to_html #( content, attributes )
      return RedCloth.new( content.join('') ).to_html
    end

  end #class Red
  
end #module MarkUps::Markers
