require 'ae/assertions/compare'

class EqualityFailure < CompareFailure
  def self.assertion_name
    :equal
  end

  def self.assertion_operator
    :==
  end

  def self.fail_message(exp, act)
    "Expected #{act.inspect} == #{exp.inspect}"
  end

  def self.fail_message!(exp, act)
    "Expected #{act.inspect} != #{exp.inspect}"
  end

  def self.check(exp, act)
    exp == act
  end

  def self.check!(exp, act)
    exp != act
  end
end

module Assertable
  # Passes if expected == +actual.
  #
  # Note that the ordering of arguments is important,
  # since a helpful error message is generated when this
  # one fails that tells you the values of expected and actual.
  #
  #   assert_equal 'MY STRING', 'my string'.upcase
  #
  def assert_equal(exp, act, opts={})
    opts[:backtrace] ||= caller
    EqualityFailure.assert(exp, act, opts)
  end

  # Passes if expected != actual
  #
  #  assert_not_equal 'some string', 5
  #
  def assert_not_equal(exp, act, opts)
     opts[:backtrace] ||= caller
     EqualityFailure.assert!(exp, act, opts)
  end
end
