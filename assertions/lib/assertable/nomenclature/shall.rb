require 'ae/shall'
require 'ae/nomenclature'

class AE

  module Nomenclature

    # = Extended Shall Nomenclature
    #
    module Shall

      # Setup a predicate for this nomenclature.
      def self.define_predicate(pname)
        name = make_subjunctive(pname)
        super('shall', name, pname)
      end

      # Returns the predicate name without the prefix
      # phrase that corresponds to this nomenclature.
      # If the term doesn't conform to this nomenclature
      # then returns nil.
      def self.make_neutral(name)
        case name
        when /^shall_/ then $'
        else nil
        end
      end

      # Shall is a nomenclature.
      extend Nomenclature

    end #module Shall

  end

end
