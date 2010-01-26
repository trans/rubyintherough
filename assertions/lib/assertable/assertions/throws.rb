require 'assertion'

module Assertable
  # Passes if the block throws expected_symbol
  #
  #   assert_throws :done do
  #     throw :done
  #   end
  #
  def assert_throws(sym, opts, &blk)
    msg  = "Expected #{sym} to have been thrown"
    pass = true
    catch(sym) do
      begin
        yield
      rescue ArgumentError => err     # 1.9 exception
        msg += ", not #{err.message.split(/ /).last}"
        pass = false
      rescue NameError => err         # 1.8 exception
        msg += ", not #{err.name.inspect}"
        pass = false
      end
    end
    unless pass
      msg  = opts[:message]   || msg
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

  # Passes if the block throws expected_symbol
  #
  #   assert_not_thrown :done do
  #     throw :chimp
  #   end
  #
  # FIXME: Is this correct?
  #
  def assert_not_thrown(sym, opts, &blk)
    msg  = "Expected #{sym} NOT to have been thrown"
    pass = false
    catch(sym) do
      begin
        yield
      rescue ArgumentError => err     # 1.9 exception
        #msg += ", not #{err.message.split(/ /).last}"
        pass = true
      rescue NameError => err         # 1.8 exception
        #msg += ", not #{err.name.inspect}"
        pass = true
      end
    end
    unless pass
      msg  = opts[:message]   || msg
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end
end
