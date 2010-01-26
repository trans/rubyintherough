require 'assertion'
require 'ae/assertable'

class OperatorFailure < ExecutionFailure

  # Compares the +object1+ with +object2+ using operator.
  #
  # Passes if object1.send(operator, object2) is true.
  #
  #   assert_operator 5, :>=, 4
  #
  def self.operator(o1, op, o2, msg="")
    test = o1.__send__(op, o2)
    msg = "Expected #{o1}.#{op}(#{o2}) to be true" unless msg
    raise Assertion.new(msg, caller) unless test
  end

end
