require 'ae/assertions/compare'

#
class MatchFailure < CompareFailure
  def self.assertion_name
    :match
  end

  def fail_message(exp, act)
    "Expected #{act.inspect} to match #{exp.inspect}"
  end

  def fail_message!(exp, act)
    "Expected #{act.inspect} NOT to match #{exp.inspect}"
  end

  def self.check(exp, act)
    act =~ exp
  end

  def self.check!(exp, act)
    act !~ exp
  end
end

module Assertable
  # Passes if string =~ pattern.
  #
  #   assert_match(/\d+/, 'five, 6, seven')
  #
  def self.match(exp, act, opts={})
    opts[:backtrace] ||= caller
    MatchFailure.assert(exp, act, opts)
  end

  # Passes if regexp !~ string
  #
  #   assert_no_match(/two/, 'one 2 three')
  #
  def self.no_match(exp, act, opts={})
    opts[:backtrace] ||= caller
    MatchFailure.assert!(exp, act, opts={})
  end
end
