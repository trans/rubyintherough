require 'assertions'

module Assertable
  # Passes if +actual+ .equal? +expected+ (i.e. they are the same instance).
  #
  #   o = Object.new
  #   assert_identical(o, o)
  #
  def assert_identical(exp, act, opts={})
    pass = exp.equal?(act)
    unless pass
      msg  = opts[:message]   || "Expected #{act.inspect} to be identical to #{exp.inspect}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

  # Passes if ! actual .equal? expected
  #
  #   assert_not_identical(Object.new, Object.new)
  #
  def assert_not_identical(exp, act, opts={})
    pass = exp.equal?(act)
    if pass
      msg  = opts[:message]   || "Expected #{act.inspect} NOT to be identical to #{exp.inspect}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end
end
