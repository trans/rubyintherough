require 'xdk/designkit/node'
require 'xdk/designkit/namespace'
require 'xdk/designkit/attribute'
require 'xdk/designkit/instruction'
require 'xdk/designkit/comment'

module XDK

  module DesignKit

    # Element base class.

    class Element < Node

      class << self

        # Get/set element's namespace.

        def namespace(uri=nil, name=nil)
          if uri
            @namespace = NameSpace.new(uri, name)
          else
            @namespace
          end
        end

      end

      #

      def tag? ; @element_tagname ; end

      private

      #

      def initialize(name=nil)
        @element_tagname    = name || self.class.name.split('::').last.downcase
      end

      #

      attr :element_tagname

      # Namespace.

      def xml_schema_namespace
        @xml_schema_namespace ||= (
          self.class.ancestors.each do |ancestor|
            break nil if ancestor == Element
            if ns = ancestor.namespace
              break ns
            end
          end
        )
      end

    end

  end

end
