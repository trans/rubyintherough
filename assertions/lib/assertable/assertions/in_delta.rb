require 'assertion'

module Assertable
  # Passes if expected_float and actual_float are equal within delta tolerance.
  #
  #   assert_in_delta 0.05, (50000.0 / 10**6), 0.00001
  #
  def assert_in_delta(exp, act, delta, opts={})
    pass = (exp.to_f - act.to_f).abs <= delta.to_f
    unless pass
      msg  = opts[:message]   || "Expected #{exp} to be within #{delta} of #{act}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

  # Passes if expected_float and actual_float are equal not within delta tolerance.
  #
  #   assert_not_in_delta 0.05, (50000.0 / 10**6), 0.00001
  #
  def self.not_in_delta(exp, act, delta, opts)
    pass = (exp.to_f - act.to_f).abs <= delta.to_f
    if pass
      msg  = opts[:message]   || "Expected #{exp} NOT to be within #{delta} of #{act}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end
end
