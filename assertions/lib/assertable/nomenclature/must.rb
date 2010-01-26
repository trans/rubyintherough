require 'ae/must'
require 'ae/nomenclature'

class AE

  module Nomenclature

    # = Extended Must Nomenclature
    #
    module Must

      # Setup a predicate for this nomenclature.
      def self.define_predicate(pname)
        name = make_subjunctive(pname)
        super('must', name, pname)
      end

      # Returns the predicate name without the prefix
      # phrase that corresponds to this nomenclature.
      # If the term doesn't conform to this nomenclature
      # then returns nil.
      def self.make_neutral(name)
        case name
        when /^must_/ then $'
        else nil
        end
      end

      # Must is a nomenclature.
      extend Nomenclature

    end

  end

end
