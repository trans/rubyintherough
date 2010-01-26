require 'ae/assertions/compare'

class InstanceOfFailure < CompareFailure
  def self.assertion_name
    :instance_of
  end

  def fail_message(cls, obj)
    "Expected #{obj} to be a #{cls}"
  end

  def fail_message!(cls, obj)
    "Expected #{obj} NOT to be #{cls}"
  end

  def self.check(exp, act)
    act.instance_of?(exp)
  end
end

module Assertable
  # Passes if object .instance_of? klass
  #
  #   assert_instance_of(String, 'foo')
  #
  def self.instance_of(cls, obj, opts={})
    opts[:backtrace] ||= caller
    InstanceOfFailure.assert(cls, obj, opts)
  end

  # Passes if object .instance_of? klass
  #
  #   assert_instance_of(String, 'foo')
  #
  def self.not_instance_of(cls, obj, opts={})
    opts[:backtrace] ||= caller
    InstanceOfFailure.assert!(cls, obj, opts)
  end
end
