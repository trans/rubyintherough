require 'xdk/designkit/elements/map'

module XDK

  module DesignKit

    # The Full element is a "complete" XML element class.
    # It supports all possible features -- attributes,
    # sub-elements and free roaming text nodes.

    class Full < Map

      class << self

        # Text node class.

        def text(klass=nil)
          return @textclass unless klass
          raise unless klass <= Text
          @textclass = klass
        end

      end

      #

      def text!(text)

      end

    end


#     # Text node for general text content.
#
#     class Text < Node
#       attr_reader :value
#
#       #
#       def initialize(value, parent)
#         @value  = value
#         @parent = parent
#       end
#
#       # TODO: Namespace here?
#
#       def to_xml(ns=nil)
#         xml_escape(value.to_s)
#       end
#
#       #
#
#       def to_rexml
#         REXML::Text.new(text)
#       end
#
#       #
#
#       def method_missing(s, *a, &b)
#         value.send(s, *a, &b)
#       end
#     end

  end

end

