require 'assertion'

class CompareFailure < Assertion
  def self.assertion_name
    :like
  end

  def self.fail_message(exp, act)
    "Expected #{act.inspect} to be like #{exp.inspect}"
  end

  def self.fail_message!(exp, act)
    "Expected #{act.inspect} NOT to be like #{exp.inspect}"
  end

  def self.check(exp, act)
    exp.equals?(act) ||
    exp.eq?(act)     ||
    exp.==(act)      ||
    exp.===(act)
  end
end

module Assertable
  # Passes if +actual+ .equte? +expected+.
  #
  #   o = Object.new
  #   assert_like(o, o)
  #
  def self.like(exp, act, opts={})
    opts[:backtrace] ||= caller
    CompareFailure.assert(exp, act, opts)
  end

  # Passes if ! actual .equte? expected
  #
  #   assert_not_like(Object.new, Object.new)
  #
  def self.not_like(exp, act, opts)
    opts[:backtrace] ||= caller
    CompareFailure.assert(exp, act, opts)
  end
end
