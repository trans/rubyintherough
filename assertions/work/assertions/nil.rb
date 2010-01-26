require 'assertion'
require 'ae/assertable'

class IsNilFailure < Assertion
  def self.assertion_name
    :nil
  end

  def fail_message(exp)
    "Expected #{exp} to be nil"
  end

  def fail_message!(exp)
    "Expected #{exp} to NOT be nil"
  end

  def self.check(obj)
    obj.nil?
  end
end

module Assertable
  # Passes if object nil?
  #
  #   assert_nil [1, 2].uniq!
  #
  def self.nil(obj, opts={})
    opts[:backtrace] ||= caller
    IsNilFailure.assert(obj, opts)
  end

  # Passes if object is not nil?
  #
  #   assert_not_nil '1 two 3'.sub!(/two/, '2')
  #
  def self.not_nil(obj, opts={})
    opts[:backtrace] ||= caller
    IsNilFailure.assert!(obj, opts)
  end
end
