require 'ae/assertions/execution'

class ThrowFailure < ExecutionFailure
  def self.assertion_name
    :throws
  end

  def self.assertion_name!
    :not_thown
  end

  def self.assert(sym, msg=nil, call=nil) #:yeild:
    msg = msg || fail_message(sym)
    test = true
    catch(sym) do
      begin
        yield
      rescue ArgumentError => err     # 1.9 exception
        msg += ", not #{err.message.split(/ /).last}"
        test = false
      rescue NameError => err         # 1.8 exception
        msg += ", not #{err.name.inspect}"
        test = false
      end
    end
    fail new(msg, call||caller) unless test
  end

  # FIXME: How to get the opposite?
  def self.assert!(sym, msg=nil, call=nil) #:yield:
    msg = msg || fail_message(sym)
    test = false
    catch(sym) do
      begin
        yield
      rescue ArgumentError => err     # 1.9 exception
        #msg += ", not #{err.message.split(/ /).last}"
        test = true
      rescue NameError => err         # 1.8 exception
        #msg += ", not #{err.name.inspect}"
        test = true
      end
    end
    fail new(msg, call||caller) unless test
  end

  def fail_message(sym)
    "Expected #{sym} to have been thrown"
  end

  def fail_message!(sym)
    "Expected #{sym} NOT to have been thrown"
  end

  # Note: This is not used by the #assert method.
  def self.check(sym) #:yield:
    test = true
    catch(sym) do
      begin
        yield
      rescue ArgumentError => err     # 1.9 exception
        test = false
      rescue NameError => err         # 1.8 exception
        test = false
      end
    end
    test
  end

  # Note: This is not used by the #assert! method.
  def self.check!(sym) #:yield:
    test = false
    catch(sym) do
      begin
        yield
      rescue ArgumentError => err     # 1.9 exception
        test = true
      rescue NameError => err         # 1.8 exception
        test = true
      end
    end
    test
  end
end

module Assertable
  # Passes if the block throws expected_symbol
  #
  #   assert_throws :done do
  #     throw :done
  #   end
  #
  def assert_throws(sym, opts, &blk)
    opts[:backtrace] ||= caller
    ThrowFailure.assert(sym, opts, &blk)
  end

  # Passes if the block throws expected_symbol
  #
  #   assert_not_thrown :done do
  #     throw :chimp
  #   end
  #
  def assert_not_thrown(sym, opts, &blk)
     opts[:backtrace] ||= caller
    ThrowFailure.assert!(sym, opts, &blk)
  end
end
