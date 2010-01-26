require 'assertion'

module Assertable
  # Passes if object .instance_of? klass
  #
  #   assert_instance_of(String, 'foo')
  #
  def self.instance_of(cls, obj, opts={})
    pass = act.instance_of?(exp)
    unless pass
      msg  = opts[:message]   || "Expected #{obj} to be a #{cls}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

  # Passes if object .instance_of? klass
  #
  #   assert_instance_of(String, 'foo')
  #
  def self.not_instance_of(cls, obj, opts={})
    pass = act.instance_of?(exp)
    if pass
      msg  = opts[:message]   || "Expected #{obj} NOT to be a #{cls}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end
end
