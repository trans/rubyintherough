require 'assertion'
require 'ae/assertable'

class IsTrueFailure < Assertion
  def self.assertion_name
    :true
  end

  def fail_message(exp)
    "Expected #{exp} to be true"
  end

  def fail_message!(exp)
    "Expected #{exp} NOT to be true"
  end

  def self.check(act)
    TrueClass === act
  end
end

module Assertable
  # Passed if object is +true+.
  #
  def assert_true(obj, opts)
    options[:backtrace] ||= caller
    IsTrueFailure.assert(obj, opts)
  end

  # Passed if object is not +true+.
  #
  #   assert_not_true(false)
  #
  def assert_not_true(obj, opts)
    opts[:backtrace] ||= caller
    IsTrueFailure.assert!(obj, opts)
  end
end
