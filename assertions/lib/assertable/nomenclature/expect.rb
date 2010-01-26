require 'ae/expect'
require 'ae/nomenclature'

class AE

  module Nomenclature

    # = Extended Expect Nomenclature
    #
    module Expect

      # Setup a predicate for this nomenclature.
      def self.define_predicate(pname)
        name = make_interjective(pname)
        name = case name
          when /^is/  then "#{name.sub('is_','')}"
          else "#{name}"
        end
        super('expect', name, pname)
      end

      # Returns the predicate name without the prefix
      # phrase that corresponds to this nomenclature.
      # If the term doesn't conform to this nomenclature
      # then returns nil.
      def self.make_neutral(name)
        case name
        when /^expect_/ then $'
        else nil
        end
      end

      # Expect is a nomenclature.
      # This is done last to prevent any Nomenclature
      # callbacks from triggering on the above definitions.
      extend Nomenclature

    end #module Expect

  end

end
