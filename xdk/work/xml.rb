# = TITLE:
#
#   XML
#
# = SUMMARY:
#
#   XML Markup library.
#
# = AUTHORS:
#
#   - 7rans
#
# = COPYRIGHT:
#
#   Copyright (c) 2007 7rans
#
# = LICENSE:
#
#   Ruby License
#
#   This module is free software. You may use, modify, and/or redistribute this
#   software under the same terms as Ruby.
#
#   This program is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#   FOR A PARTICULAR PURPOSE.
#
# = NOTES:
#
#   I considered the use of DesignKit's OpenElement in place of this, Eg.
#
#     require 'blow/designkit'
#     module Blow
#       class Xml < XmlDesignKit::OpenElement
#         def self.doc(name, attrs=nil, &block)
#           new(name, attrs, &block)
#         end
#       end
#     end
#
#  But this does not pass musted, b/c it doesn't track node order.

require 'facets/buildingblock.rb'

module Blow

  # = Xml
  #
  # Xml is a utility module which provides methods the ease the
  # creation of XML markup.
  #
  # == Usage
  #
  #   puts Xml.element( :a, Xml.element( :b, "X" ) )
  #
  # produces
  #
  #   <a><b>X</b></a>
  #

  module Xml
    extend self

    # Follows the <em>Builder Pattern</em> allowing XML markup to be
    # constructed via Ruby method calls and block structures.
    # See BuildingBlock for more details.

    def self.new
      BuildingBlock.new(self, :element)
    end

    #

    def self.doc(root_tag, atts=nil, &blk)
      x = BuildingBlock.new(self, :element)
      x.xml #(atts)
      x.build!(root_tag, atts, &blk)
    end

    # Empty XML document.

    def document(options)
      doc = ''
      if options[:version]
        doc << xml(options[:version], options[:encoding])
      end
    end
    #alias_method :new, :document

    # XML declaration.

    def xml(atts=nil)
      atts ||= {}
      atts[:version]  ||= '1.1'
      atts[:encoding] ||= "ISO-8859-1"
      instruct(:xml, atts)
    end

    # Element.

    def element(tag, *body) #body=nil, **atts)
      atts = (Hash===body.last) ? body.pop : {}
      atts = atts.collect{ |k,v| %{ #{k}="#{v}"} }.join('')
      if body.empty?
        "<#{tag}#{atts} />"
      else
        "<#{tag}#{atts}>#{body}</#{tag}>"
      end
    end

    # Comment.

    def comment(remark)
      "<!-- #{remark} -->"
    end

    # Proccessing instruction.

    def instruct(tag, *args)
      atts = Hash === args.last ? args.pop : {}
      atts = atts.collect{ |k,v| %{ #{k}="#{v}"} }.join('')
      body = ' ' + args.join(' ')
      "<?#{tag}#{body}#{atts}?>"
    end
    alias_method :instruction, :instruct
    alias_method :pi, :instruct

    # Text.

    def text( str )
      str
    end

    # CData.

    def cdata!( data )
      raise ArgumentError, "CDATA contains ']]>'" if data.index(']]>')
      "<![CDATA[#{data}]]>"
    end

    # TODO

    # DOCTYPE DTD declaration.

    def doctype!( *args )
      "<!DOCTYPE"
    end

    # ELEMENT DTD declaration.

    def element!( *args )
      '<!ELEMENT'
    end

    # ATTLIST DTD declaration.

    def attlist!( *args )
      '<!ATTLIST'
    end

    # ENTITY DTD declaration.

    def entity!( *args )
      '<!ENTITY'
    end

    # NOTATION DTD declaration.

    def notation!( *args )
      '<!NOTATION'
    end

  end

end


if $0 == __FILE__
  puts Blow::Xml.doc(:root) {
    tom(:age=>37)
  }
end


