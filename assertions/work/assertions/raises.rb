require 'ae/assertions/execution'

class RaiseFailure < ExecutionFailure
  def self.assertion_name
    :raises
  end

  def self.assertion_name!
    :not_raised
  end

  def self.assert(exp, msg=nil, call=nil) #:yeild:
    begin
      yield
      msg = msg || fail_message(exp)
      test = false
    rescue Exception => err
      msg = msg || fail_message(exp, err)
      test = (exp === err)
    end
    fail new(msg, call||caller) unless test
  end

  def self.assert!(exp, msg=nil, call=nil) #:yield:
    begin
      yield
      test = true
    rescue Exception => err
      msg = msg || fail_message!(exp, err)
      test = (exp === err)
    end
    fail new(msg, call||caller) unless test
  end

  def self.fail_message(exp, err=nil)
    if err
      "Expected #{exp} to be raised, but got #{err.class}"
    else
      "Expected #{exp} to be raised"
    end
  end

  def self.fail_message!(exp)
    "Expected #{exp} NOT to be raised"
  end

  # Note: This is not used by the #assert method.
  def self.check(*exp)
    begin
      yield
      false
    rescue Exception => e
      exp.any?{ |x| x === e }
    end
  end

  # Note: This is not used by the #assert! method.
  def self.check(*exp)
    begin
      yield
      true
    rescue Exception => e
      !exp.any?{ |x| x === e }
    end
  end

end

module Assertable
  # Passes if the block raises a given exceptions.
  #
  #   assert_raises RuntimeError do
  #     raise 'Boom!!!'
  #   end
  #
  def self.raises(exp, msg=nil, call=nil, &blk) #:yeild:
    RaiseFailure.assert(exp, msg=nil, call=nil, &blk)
  end

  # Passes if the block *does not* raise a given exceptions.
  #
  #   assert_not_raised IOError do
  #     raise 'Boom!!!'
  #   end
  #
  def self.not_raised(exp, msg=nil, call=nil, &blk) #:yeild:
    RaiseFailure.assert!(exp, msg, call, &blk)
  end
end
