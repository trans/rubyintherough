# = Assertable
#
# Singleton methods defined against Assertable
# are transformated into assertions corresponding
# to active nomenclatures and then defined as instance
# methods of Assertable.
#
# Example
#
#   require 'ae/nomenclature/assert'
#   require 'ae/nomenclature/should'
#
#   def Assertable.should_be_like_mike(name)
#     raise CompareFailure.new("Not a Mike!", caller) unless /mike/i =~ name
#   end
#
#   include Assertable
#
#   assert_like_jimmy("Jim Bo")
#   should_be_like_jimmy("Jim Bo")
#
module Assertable

  #module ::Kernel
  #  # Fail always fails.
  #  #
  #  #   fail 'Not done testing yet.'
  #  #
  #  def fail(msg=nil)
  #    raise Assertion.new(msg, caller)
  #  end
  #end

  private

  # By adding an assertion predicate to the
  # Predicate module, it is automatically
  # added to all active nomenclatures.
  #
  def self.singleton_method_added(name)
    return if :singleton_method_added == name.to_sym
    return if :define_predicate == name.to_sym
    return if :make_subjunctive == name.to_sym
    return if :make_neutral == name.to_sym

    puts "Assertable::singleton_method_added(#{name.inspect})" if $DEBUG

    pname = nil
    AE::Nomenclature::ACTIVE.find do |nomenclature|
      pname = nomenclature.make_neutral(name)
      break if pname
    end
    name = pname if pname
    AE::Nomenclature::ACTIVE.each do |nomenclature|
      nomenclature.define_predicate(name)
    end
  end

end
