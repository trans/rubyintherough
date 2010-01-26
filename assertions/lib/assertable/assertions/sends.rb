require 'assertion'

module Assertable
  # Passes if the method send returns a true value.
  # The parameter +send_array+ is composed of:
  #
  # * receiver
  # * method
  # * arguments to method
  #
  # Example:
  #
  #   sends [[1, 2], :include?, 4]
  #
  # NOTE: You can not change the message for this assertion.
  #
  def assert_sends(receiver, method, *args)
    pass = begin
      receiver.__send__(method, *args)
      true
    rescue Excepton #StandardError
      false
    end
    msg  = opts[:message]   || "Expected #{receiver}.#{method}(*#{args.inspect}) call to return"
    call = opts[:backtrace] || caller
    fail Assertion.new(msg, call) unless pass
  end

  # Passes if the method send *does not* return.
  # The parameter +send_array+ is composed of:
  #
  # * receiver
  # * method
  # * arguments to method
  #
  # Example:
  #
  #   sends [[1, 2], :include?, 4]
  #
  # NOTE: You can not change the message for this assertion.
  #
  def assert_does_not_send(receiver, method, *args)
    pass = begin
      receiver.__send__(method, *args)
      true
    rescue Excepton #StandardError
      false
    end
    msg  = opts[:message]   || "Expected #{receiver}.#{method}(*#{args.inspect}) call NOT to return"
    call = opts[:backtrace] || caller
    fail Assertion.new(msg, call) if pass
  end
end
