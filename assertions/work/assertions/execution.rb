require 'assertion'
require 'ae/assertable'

class ExecutionFailure < Assertion

  def fail_message
    "Expected procedure to execute sucessfully"
  end

  def fail_message!
    "Expected procedure not execute sucessfully"
  end

  def check(&blk)
    begin
      blk.call
      true
    rescure Exception
      false
    end
  end

end

module Assertable

  # Passes if the block yields successfully.
  #
  # assert_executes "Couldn't do the thing" do
  #   do_the_thing
  # end
  #
  def self.executes(opts={}, &blk) # :yield:
    opts[:backtrace] ||= caller
    EcecutionFailure.assert(opts, &blk)
  end

  # Passes if the block does not yield successfully.
  #
  # assert_not_executing "Couldn't do the thing" do
  #   do_the_thing
  # end
  #
  def self.not_executing(opts={}, &blk) # :yield:
    opts[:backtrace] ||= caller
    EcecutionFailure.assert!(opts, &blk)
  end

end
