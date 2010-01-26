require 'assertion'

module Assertable
  # Passes if object nil?
  #
  #   assert_nil [1, 2].uniq!
  #
  def assert_nil(exp, opts={})
    if !obj.nil?
      msg  = opts[:message]   || "Expected #{exp} to be nil"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

  # Passes if object is not nil?
  #
  #   assert_not_nil '1 two 3'.sub!(/two/, '2')
  #
  def self.not_nil(exp, opts={})
    if obj.nil?
      msg  = opts[:message]   || "Expected #{exp} NOT to be nil"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end
end
