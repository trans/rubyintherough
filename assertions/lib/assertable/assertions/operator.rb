require 'assertion'

module Assertable

  # Compares the +object1+ with +object2+ using operator.
  #
  # Passes if object1.send(operator, object2) is true.
  #
  #   assert_operator 5, :>=, 4
  #
  def assert_operator(o1, op, o2, opts={})
    if !o1.__send__(op, o2)
      msg = opts[:message] || "Expected #{o1}.#{op}(#{o2}) to be true"
      fail Assertion.new(msg, caller)
    end
  end

end
