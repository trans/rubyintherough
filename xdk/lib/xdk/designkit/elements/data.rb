require 'xdk/designkit/elements/tag'

module XDK

  module DesignKit

    # Data element is like Tag but contains a single value.
    # The value can be of any type. It will be converted to a
    # String via #to_s when outputed as XML.

    class Data < Tag

      attr_reader :element_value

      def initialize(name, value, attributes=nil)
        super(name, attributes)
        @element_value = value
      end

      # def method_missing(s, *a, &b)
      #   @element_value.send(s, *a, &b)
      # end

      public

      # Convert to XML formatted string.

      def to_xml(ns=nil)
        body = to_xml_body(ns)
        atts = to_xml_attrs(ns)
        atts = ' ' + atts unless atts.empty?
        if body.empty?
          "<#{element_tagname}#{atts}/>"
        else
          "<#{element_tagname}#{atts}>#{body}</#{element_tagname}>"
        end
      end

      private

      # Build up content.
      # TODO: Add respond_to?(:to_xml) ?

      def to_xml_body(ns)
        string = element_value.to_s.strip
        xml_escape(string)
      end
    end

  end

end
