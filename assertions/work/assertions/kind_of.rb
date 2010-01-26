require 'ae/assertions/compare'

# Passes if object .kind_of? cls
#
#   assert_kind_of(Object, 'foo')
#
# === Contemporary
#
#   'foo'.assert.kind_of?(Object)
#
class KindOfFailure < CompareFailure
  def self.assertion_name
    :kind_of
  end

  def fail_message(cls, obj)
    "Expected #{obj.inspect} to be a kind of #{cls}"
  end

  def fail_message!(cls, obj)
    "Expected #{obj.inspect} to NOT be a kind of #{cls}"
  end

  def check(cls, obj)
    obj.kind_of?(cls)
  end
end

module Assertable
  # Passes if object .kind_of? klass
  #
  #   assert_kind_of(Object, 'foo')
  #
  def self.kind_of(cls, obj, opts={})
    opts[:backtrace] ||= caller
    KindOfFailure.assert(cls, obj, opts={})
  end

  # Passes if object .kind_of? klass
  #
  #   assert_kind_of(Object, 'foo')
  #
  def self.not_kind_of(cls, obj, opts={})
    opts[:backtrace] ||= caller
    KindOfFailure.assert!(cls, obj, opts)
  end
end
