require 'assertion'
require 'ae/assertable'

class AE

  #
  module Nomenclature

    # Store list of currently active nomenclatures.
    ACTIVE = []

    private

    def self.extended(nomenclature)
      setup_nomenclature(nomenclature)
    end

    # Setup pre-existing predicates.
    #
    def self.setup_nomenclature(nomenclature)
      ACTIVE << nomenclature
      #(@nomenclatures ||= []) << nomenclature
      Assertable.private_instance_methods(false).each do |name|
        next if :define_predicate == name.to_sym
        nomenclature.define_predicate(name)
      end
    end

    # Converts
    def make_subjunctive(name)
      name = name.to_s
      name = case name
      #when /^not_/  then "not_be_#{$'}"
      when /^no_/   then "not_have_#{$'}"
      when /^is_/   then "be_#{$'}"
      when /^in_/   then "be_#{name}"
      when /^like_/ then "be_#{name}"
      when /^has_/  then "have_been_#{$'}"
      when /_of$/   then "be_#{name}"
      else name
      end
      name = name.chomp('s') if /s$/ =~ name
      name
    end

    # Converts
    def make_interjective(name)
      name = name.to_s
      name = case name
      when /^not_be_/    then "not_#{$'}"
      when /^not_have_/  then "no_#{$'}"
      when /^be_/        then "#{$'}"
      #when /^be_in_/     then "in_#{$'}"
      #when /^be_like_/   then "like_#{$'}"
      when /^have_been_/ then "has_#{$'}"
      else name
      end
      #name = name.chomp('s') if /s$/ =~ name
      name
    end

    # Predicate definition. This must be overriden
    # in nomenclature submodules.
    #
    def define_predicate(prefix, name, pname)
      return if :singleton_method_added == pname.to_sym
      return if :make_subjunctive  == pname.to_sym
      return if :make_interjective == pname.to_sym
      return if :define_predicate  == pname.to_sym

      puts "Nomenclature#define_predicate(#{prefix.inspect}, #{name.inspect}, #{pname.inspect})" if $DEBUG

      Assertable.module_eval <<-END, __FILE__, __LINE__
        private
        def #{prefix}_#{name}(*a,&b)
          Assertable.#{pname}(*a,&b)
        end
      END
    end

  end

end
