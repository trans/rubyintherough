require 'xdk/designkit/element'

module XDK

  module DesignKit

    # Tag is the simplest element subclass. It has a tag name
    # and attributes.

    class Tag < Element

      class << self

        # Tags can have attributes.

        def attributes; @attributes ||= {}; end

        # Define an attribute for a tag. If option :required is
        # set to true, then a validator it created to make sure
        # the attribute is set.

        def attribute(key, *args)
          options = (Hash===args.last) ? args.pop : nil
          kind = args.pop || Attribute
          attributes[key.to_sym] = [kind, options]
        end

      end

      private

      # Collect attribute names for complete class hierarchy.

      def xml_schema_attributes
        eigenclass = (class << self; self; end)
        attributes = eigenclass.attributes
        eigenclass.ancestors.each do |ancestor|
          attributes = ancestor.attributes.merge(attributes)
          break if self.class == ancestor
        end
        attributes
      end

      # -- Instance -----------------------------------------------------------

      attr :element_attributes

      def initialize(name=nil, attributes=nil)
        super(name)
        @element_attributes = {}

        (attributes||{}).each{ |k,v| self[k] = v }
      end

      public

      # Get attribute.

      def [](key)
        element_attributes[key.to_sym]
      end

      # Set attribute.

      def []=(key, value)
        attr = xml_schema_attributes[key.to_sym]
        kind = attr ? attr[0] : Attribute
        element_attributes[key.to_sym] = kind.new(key, value)
      end

      # Common to all XML tags/elements.

      attribute "xml:base", nil #, :namespace => 'xml'
      attribute "xml:lang", nil #, :namespace => 'xml'

      # Convert to XML formatted string.

      def to_xml(ns=nil)
        atts = to_xml_attrs(ns)
        atts = ' ' + atts unless atts.empty?
        "<#{element_tagname}#{atts}/>"
      end

      private

      def to_xml_attrs(ns)
        # Build up attributes first.
        atts = []
        myns = xml_schema_namespace || ns
        if myns != ns
          atts << myns.to_xml
        end
        ns = myns
        atts += element_attributes.collect do |k, v|
          case v
          when nil
            nil
          when Attribute
            v.to_xml(ns)
          else
            %[#{k}="#{v}"]
          end
        end
        atts.compact.join(' ')
      end

    end

  end

end
