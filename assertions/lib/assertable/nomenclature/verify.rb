require 'ae/verify'
require 'ae/nomenclature'

class AE

  module Nomenclature

    # = Extended Verify Nomenclature
    #
    module Verify

      # Setup a predicate for this nomenclature.
      def self.define_predicate(pname)
        name = make_interjective(pname)
        name = case name
          when /^is/  then "#{name.sub('is_','')}"
          else "#{name}"
        end
        super('verify', name, pname)
      end

      # Returns the predicate name without the prefix
      # phrase that corresponds to this nomenclature.
      # If the term doesn't conform to this nomenclature
      # then returns nil.
      def self.make_neutral(name)
        case name
        when /^verify_/ then $'
        else nil
        end
      end

      # Verify is a nomenclature.
      extend Nomenclature

    end #module Verify

  end

end
