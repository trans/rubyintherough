require 'ae/assertions/compare'

class InDeltaFailure < CompareFailure
  def self.assertion_name
    :in_delta
  end

  def self.fail_message(exp, act, delta)
    "Expected #{exp} to be within #{delta} of #{act}"
  end

  def self.fail_message!(exp, act, delta)
    "Expected #{exp} NOT to be within #{delta} of #{act}"
  end

  def self.check(exp, act, delta)
    (exp.to_f - act.to_f).abs <= delta.to_f
  end
end

module Assertable
  # Passes if expected_float and actual_float are equal within delta tolerance.
  #
  #   assert_in_delta 0.05, (50000.0 / 10**6), 0.00001
  #
  def self.in_delta(exp, act, delta, opts={})
    opts[:backtrace] ||= caller
    InDeltaFailure.assert(exp, act, delta, opts)
  end

  # Passes if expected_float and actual_float are equal not within delta tolerance.
  #
  #   assert_not_in_delta 0.05, (50000.0 / 10**6), 0.00001
  #
  def self.not_in_delta(exp, act, delta, opts)
    opts[:backtrace] ||= caller
    InDeltaFailure.assert!(exp, act, delta, opts)
  end
end
