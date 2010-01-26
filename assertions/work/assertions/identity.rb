require 'ae/assertions/compare'

class IdentityFailure < CompareFailure
  def self.assertion_name
    :identical
  end

  def fail_message(exp, act)
    "Expected #{act.inspect} to be identical to #{exp.inspect}"
  end

  def fail_message!(exp, act)
    "Expected #{act.inspect} NOT to be identical to #{exp.inspect}"
  end

  def self.check(exp, act)
    exp.equal?(act)
  end
end

module Assertable
  # Passes if +actual+ .equal? +expected+ (i.e. they are the same instance).
  #
  #   o = Object.new
  #   assert_identical(o, o)
  #
  def self.identical(exp, act, opts={})
    opts[:backtrace] ||= caller
    Identityfailure.assert(exp, act, opts)
  end

  # Passes if ! actual .equal? expected
  #
  #   assert_not_identical(Object.new, Object.new)
  #
  def self.not_identical(exp, act, opts={})
    opts[:backtrace] ||= caller
    IdentityFailure.assert!(exp, act, opts)
  end
end
