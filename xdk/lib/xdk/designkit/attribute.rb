require 'xdk/designkit/node'

module XDK

  module DesignKit

    # Attribute. All tag attributes are either an instance of this class,
    # or an instance of a subclass of this class. The attribute's value
    # is delegated to via method_missing.

    class Attribute < Node
      attr_reader :name, :value
      #
      def initialize(name, value)
        @name  = name
        @value = value
      end

      # FIXME: How to handle namespace here ?

      def to_xml(ns=nil)
        %[#{xml_escape(name.to_s)}="#{xml_escape(value.to_s)}"]
      end

      def to_rexml
        REXML::Attribute.new(name, value)
      end

      #
      def method_missing(s, *a, &b)
        value.send(s, *a, &b)
      end
    end

  end

end
