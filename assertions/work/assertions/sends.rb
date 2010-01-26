require 'ae/assertions/execution'

class SendFailure < ExecutionFailure
  def self.assertion_name
    :sends
  end

  def self.assertion_name!
    :does_not_send
  end

  def self.assert(receiver, methods *args)
    msg = fail_message(receiver, method, *args)
    fail new(msg, call||caller) unless check(receiver, method, *args)
  end

  def self.assert!(receiver, methods *args)
    msg  = msg || fail_message!(receiver, method, *args)
    fail new(msg, call||caller) unless check!(receiver, method, *args)
  end

  def self.fail_message(reciever, method, *args)
    "Expected #{receiver}.#{method}(*#{args.inspect}) call to return true"
  end

  def self.fail_message!(reciever, method, *args)
    "Expected #{receiver}.#{method}(*#{args.inspect}) call to return false"
  end

  def self.check(receiver, method, *args)
    begin
      receiver.__send__(method, *args)
      true
    rescue Excepton #StandardError
      false
    end
  end
end

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
    SendFailure.assert(receiver, method, *args)
  end

  # Passes if the method send *does not* returns a true value.
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
    SendFailure.assert!(receiver, method, *args)
  end
end
