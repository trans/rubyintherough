require 'ae/assertions/compare'

class SameFailure < CompareFailure
  def self.assertion_name
    :same
  end

  def fail_message(exp, act)
    "Expected #{act.inspect} to be the same as #{exp.inspect}"
  end

  def fail_message!(exp, act)
    "Expected #{act.inspect} to NOT be the same as #{exp.inspect}"
  end

  def check(exp, act)
    exp.eq?(act)
  end
end

module Assertable
  # Passes if +expected+ .eq? +actual+.
  #
  # Note that the ordering of arguments is important,
  # since a helpful error message is generated when this
  # one fails that tells you the values of expected and actual.
  #
  #   assert_equal 'MY STRING', 'my string'.upcase
  #
  def self.same(exp, act, opts={})
    opts[:backtrace] ||= caller
    SameFailure.assert(exp, act, opts)
  end

  # Passes if not +expected+ .eq? +actual+.
  #
  #  assert_not_equal 'some string', 5
  #
  def self.not_the_same(exp, act, opts={})
    opts[:backtrace] ||= caller
    SameFailure.assert!(exp, act, opts)
  end
end
