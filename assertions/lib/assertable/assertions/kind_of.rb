require 'assertion'

module Assertable
  # Passes if object .kind_of? klass
  #
  #   assert_kind_of(Object, 'foo')
  #
  def self.kind_of(cls, obj, opts={})
    if !obj.kind_of?(cls)
      msg  = opts[:message]   || "Expected #{obj.inspect} to be a kind of #{cls}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

  # Passes if object .kind_of? klass
  #
  #   assert_kind_of(Object, 'foo')
  #
  def self.not_kind_of(cls, obj, opts={})
    if obj.kind_of?(cls)
      msg  = opts[:message]   || "Expected #{obj.inspect} NOT to be a kind of #{cls}"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end
end
