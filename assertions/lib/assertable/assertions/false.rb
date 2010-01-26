require 'assertion'

module Assertable
  # Passed if object is +false+.
  #
  def assert_false(exp, opts={})
    pass = (FalseClass === exp)
    unless pass
      msg  = opts[:message]   || "Expected #{exp} to be false"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

  # Passed if object is not +false+.
  #
  #   assert_not_false(false)
  #
  def assert_not_false(obj, opts={})
    pass = (FalseClass === exp)
    if pass
      msg  = opts[:message]   || "Expected #{exp} NOT to be false"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end
end
