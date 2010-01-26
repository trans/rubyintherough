require 'ae/kernel/assert'
require 'ae/nomenclature'

class AE

  module Nomenclature

    # = Extended Assert Nomenclature
    #
    module Assert
      # Define predicate +pname+ for this nomenclature.
      #
      def self.define_predicate(pname)
        #puts "Assert::define_predicate(#{pname.inspect})" if $DEBUG
        name = make_interjective(pname)
        name = case name
          when /^is/  then "#{name.sub('is_','')}"
          else "#{name}"
        end
        super('assert', name, pname)
        case name
        when /^assert_not/
          alias_method "refute_{$'}", name
        when /^assert_no/
          alias_method "refute_{$'}", name
        end
      end

      # Returns the predicate name without the prefix
      # phrase that corresponds to this nomenclature.
      # If the term doesn't conform to this nomenclature
      # then returns nil.
      def self.make_neutral(name)
        case name
        when /^assert_/ then $'
        else nil
        end
      end

      # Assert is a Nomenclature.
      # This is done last to prevent any Nomenclature
      # callbacks from triggering on the above definitions.
      extend Nomenclature
    end

  end

end
