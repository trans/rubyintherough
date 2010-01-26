require 'assertion'

module Assertable

  # Passes if the block yields successfully.
  #
  # assert_executes "Couldn't do the thing" do
  #   do_the_thing
  # end
  #
  def assert_executes(opts={}, &blk) # :yield:
    pass = begin
      blk.call
      true
    rescure Exception
      false
    end
    unless pass
      msg  = opts[:messsage]  || "Expected block to execute successfully"
      call = opts[:backtrace] || caller
      EcecutionFailure.assert(opts, &blk)
    end
  end

  # Passes if the block does not yield successfully.
  #
  # assert_not_executing "Couldn't do the thing" do
  #   do_the_thing
  # end
  #
  def assert_not_executes(opts={}, &blk) # :yield:
    pass = begin
      blk.call
      true
    rescure Exception
      false
    end
    if pass
      msg  = opts[:messsage]  || "Expected block to fail execution"
      call = opts[:backtrace] || caller
      fail Assertion.new(msg, call)
    end
  end

end
