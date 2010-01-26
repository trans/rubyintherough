require 'assertion'

module Assertable
  # Passed if object is +true+.
  #
  def assert_true(obj, opts)
    msg  = opts[:message]   || "Expected #{exp} to be true"
    call = opts[:backtrace] || caller
    fail Assertion.new(msg, call) unless TrueClass === act
  end

  # Passed if object is not +true+.
  #
  #   assert_not_true(false)
  #
  def assert_not_true(obj, opts)
    msg  = opts[:message]   || "Expected #{exp} NOT to be true"
    call = opts[:backtrace] || caller
    fail Assertion.new(msg, call) if TrueClass === act
  end
end
