require 'xdk/designkit/node'

module XDK

  module DesignKit

    # XML Processing instruction.

    class Instruction < Node
      attr :tagname
      attr :content
      attr :attributes

      def initialize(tag,*args)
        @tagname    = tag
        @attributes = (Hash === args.last) ? args.pop : {}
        @content    = args.join(' ')
      end

      def to_xml
        atts = attributes.collect{ |k,v| %{#{k}="#{v}"} }.join(' ')
        "<?#{tag} #{content} #{atts}?>"
      end
    end

  end

end
