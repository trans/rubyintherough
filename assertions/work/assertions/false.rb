require 'ae/assertable'

class IsFalseFailure < Assertion
  def self.assertion_name
    :false
  end

  def fail_message(exp)
    "Expected #{exp} to be false"
  end

  def fail_message!(exp)
    "Expected #{exp} NOT to be false"
  end

  def self.check(act)
    FalseClass === act
  end
end

module Assertable
  # Passed if object is +false+.
  #
  def self.false(obj, opts={})
    opts[:backtrace] ||= caller
    IsFalseFailure.assert(obj, opts)
  end

  # Passed if object is not +false+.
  #
  #   assert_not_false(false)
  #
  def self.not_false(obj, opts={})
    opts[:backtrace] ||= caller
    IsFalseFailure.assert!(obj, opts)
  end
end
