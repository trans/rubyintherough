module XDK

  module DesignKit

    # Give all the nodes a common base class. This provides
    # the common DesignKit namespace, and any methods
    # shared by all types of nodes.

    class Node

      include DesignKit

      #

      def self.validations ; @validations ||= [] ; end

      # Define a validation procedure.

      def self.validate(&block) ; validations << block ; end

      #

      def xml_schema_validations
        validations = []
        eigenclass = (class << self; self; end)
        validations.concat(eigenclass.validations)
        eigenclass.ancestors.each do |ancestor|
          validations.concat(ancestor.validations)
          break if Node == ancestor
        end
        validations.uniq
      end

      # Does node pass validation tests?
      #--
      # TODO: Should self be passed to validator rather then instance eval?
      #       Or depend on arity?
      #++

      def valid?
        xml_schema_validations.all?{ |v| instance_eval(&v) }
      end

      # XML string escape.

      def xml_escape(input)
        result = input.dup
        result.gsub!("&", "&amp;" )
        result.gsub!("<", "&lt;"  )
        result.gsub!(">", "&gt;"  )
        result.gsub!("'", "&apos;")
        result.gsub!('"', "&quot;")
        return result
      end
    end

  end

end
