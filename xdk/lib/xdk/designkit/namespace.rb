module XDK

  module DesignKit

    # Namespace class.

    class NameSpace
      attr_accessor :uri, :name
      #
      def initialize(uri, name=nil)
        @uri  = uri
        @name = name
      end
      #
      def to_xml
        attr = name ? "xmlns:#{name}" : "xmlns"
        %[#{attr}="#{uri}"]
      end
    end

  end

end
