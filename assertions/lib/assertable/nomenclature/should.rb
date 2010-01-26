require 'ae/kernel/should'
require 'ae/nomenclature'

class AE

  module Nomenclature

    # = Extended Should Nomenclature
    #
    module Should

      # Setup a predicate for this nomenclature.
      def self.define_predicate(pname)
        name = make_subjunctive(pname)
        super('should', name, pname)
      end

      # Returns the predicate name without the prefix
      # phrase that corresponds to this nomenclature.
      # If the term doesn't conform to this nomenclature
      # then returns nil.
      def self.make_neutral(name)
        case name
        when /^should_/ then $'
        else nil
        end
      end

      # Should is a nomenclature.
      extend Nomenclature

    end #module Should

  end

end
