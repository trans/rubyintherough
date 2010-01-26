require 'ae/will'
require 'ae/nomenclature'

class AE

  module Nomenclature

    # = Extended Will Nomenclature
    #
    module Will #:nodoc:

      # Define a predicate for this nomenclature.
      def self.define_predicate(pname)
        name = make_subjunctive(pname)
        super('will', name, pname)
        case name
        when /^will_not/
          alias_method "wont_{$'}", name
        end
      end

      # Returns the predicate name without the prefix
      # phrase that corresponds to this nomenclature.
      # If the term doesn't conform to this nomenclature
      # then returns nil.
      def self.make_neutral(name)
        case name
        when /^will_have_been_/ then "has_#{$'}"
        when /^will_be_/ then $'
        when /^will_/ then $'
        else nil
        end
      end

      # Will is a nomenclature.
      extend Nomenclature

    end #module Will

  end

end
