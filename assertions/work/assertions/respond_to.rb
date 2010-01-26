require 'ae/assertions/execution'

class RespondToFailure < ExecutionFailure
  def self.assertion_name
    :respond_to
  end

  def self.assertion_name!
    :not_respond_to
  end

  def fail_message(reciever, method)
    "Expected #{reciever} (#{reciever.class}) to respond to ##{method}"
  end

  def fail_message!(reciever, method)
    "Expected #{reciever} (#{reciever.class}) to not respond to ##{method}"
  end

  def self.check(reciver, method)
    #flip = (Symbol === obj) && ! (Symbol === meth) # HACK for specs
    #obj, meth = meth, obj if flip
    reciever.respond_to?(method)
  end
end

module Assertable
  # Passes if +object+ respond_to? +methods+.
  #
  #   assert_respond_to 'bugbear', :slice
  #
  def assert_respond_to(reciever, method, opts={})
    opts[:backtrace] ||= caller
    RespondToFailure.assert(reciever, method, opts)
  end

  # Passes if +object+ does not respond_to? +methods+.
  #
  #   assert_not_respond_to 'bugbear', :slice
  #
  def assert_not_respond_to(reciever, method, opts={})
    opts[:backtrace] ||= caller
    RespondToFailure.assert!(reciever, method, opts)
  end
end
