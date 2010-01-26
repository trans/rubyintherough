require 'assertion'

module Assertable
  # Passes if string =~ pattern.
  #
  #   assert_match(/\d+/, 'five, 6, seven')
  #
  def self.match(exp, act, opts={})
    if act !~ exp
      msg  = opts[:message]   || "Expected #{act.inspect} to match #{exp.inspect}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

  # Passes if regexp !~ string
  #
  #   assert_no_match(/two/, 'one 2 three')
  #
  def self.no_match(exp, act, opts={})
    if act =~ exp
      msg  = opts[:message]   || "Expected #{act.inspect} NOT to match #{exp.inspect}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end
end
