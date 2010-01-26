require 'assertion'
require 'ae/assertable'

NoArgument = Object.new

class ReturnFailure < Assertion

  def self.assert(exp, opts={}, &blk) #:yeild:
    msg = fail_message(exp)
    res = yield
    if :"N/A" == exp
      chk = (res ? true : false)
    else
      chk = (exp == res)
      msg = msg + ", but was #{res}"
    end
    fail new(opts[:message]||msg, opts[:backtrace]||caller) unless chk
  end

  def self.assert!(exp, opts={}, &blk) # :yield:
    msg = fail_message!(exp)
    res = yield
    if :"N/A" == exp
      chk = (res ? false : true)
    else
      chk = (exp != res)
      msg = msg + ", but was #{res}"
    end
    fail new(opts[:message]||msg, opts[:backtrace]||caller) unless chk
  end

  def fail_message(exp)
    if :"N/A" == exp
      "Expected block to return a value"
    else
      "Expected block to return #{exp}"
    end
  end

  def fail_message!(exp)
    if :"N/A" == exp
      "Expected block not to return a value"
    else
      "Expected block not to return #{exp}"
    end
  end

  def check(exp) #:yield:
    case exp
    when :"N/A"
      yield ? true : false
    else
      exp == yield
    end
  end

end

module Assertable

  # Passes if the block yields a specified value (Compares with #==).
  #
  # assert_executes "Couldn't do the thing" do
  #   do_the_thing
  # end
  #
  def assert_returns(exp=:"N/A", opts={}, &blk) # :yield:
    opts[:backtrace] ||= caller
    ReturnFailure.assert(exp, opts, &blk)
  end

  # Passes if the block does not yield a specific value.
  #
  # assert_not_executing "Couldn't do the thing" do
  #   do_the_thing
  # end
  #
  def assert_does_not_return(exp=:"N/A", opts={}, &blk) # :yield:
    opts[:backtrace] ||= caller
    ReturnFailure.assert!(exp, opts, &blk)
  end

end
