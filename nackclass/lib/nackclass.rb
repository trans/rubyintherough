# = nackclass.rb
#
# == Copyright (c) 2005 Thomas Sawyer
#
#   Ruby License
#
#   This module is free software. You may use, modify, and/or redistribute this
#   software under the same terms as Ruby.
#
#   This program is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#   FOR A PARTICULAR PURPOSE.
#
# == Author(s)
#
# * Thomas Sawyer
#
# == Developer Notes
#
# TODO I beleive this class has even more potential yet.
#      It would be interesting to see if a catch/try correction
#      facility could be built into it too.

# Author::    Thomas Sawyer
# Copyright:: Copyright (c) 2005 Thomas Sawyer
# License::   Ruby License

# = NackClass
#
# The NackClass is is like the NilClass except one step down.
# Nack is never used to to mean nothingness or emptiness.
# The Nack class is only used to report something is "a miss" w/o
# the system raising an Exception. It's a mechanism for
# lazy error evaluation.
#
# == Usage
#
#   def scalar( x )
#     if x.kind_of?(Enumerable)
#       return nack(ArgumentError, "Value must not be enumerable")
#     end
#     x
#   end
#
#   a = scaler( 1 )            #=> 1
#   b = scaler( [1,2] )        #=> nack
#   b.first                    #=> ArgumentError (previous)
#
#   a = nail scaler( 1 )       #=> 1
#   b = nail scaler( [1,2] )   #=> ArgumentError
#

class InvalidNackError < ArgumentError
end

#
#
#
class NackClass

  attr_reader :error, :data

  def initialize(error=nil, *data, &ctrl)
    if Class === error and error <= Exception
      @error = error.new(*data)
    elsif error.kind_of?( Exception )
      @error = error
    elsif error.kind_of?( String )
      @error = StandardError.new(error)
    elsif error == nil
      @error = StandardError.new
    else
      raise InvalidNackError
    end
    @data = data
    @ctrl = ctrl
  end

  def call(*args)
    @ctrl.call(*args)
  end

  def call_with_data
    @ctrl.call(*@data)
  end

  def raise_error
    raise @error
  end

  def to_s; "n/a"; end

  def ==(x)
    x.is_a?(NackClass)
  end

  def method_missing(meth, *args)
    raise_error
  end

end

module Kernel
  def nack(err=nil, *data, &ctrl)
    NackClass.new(err, *data, &ctrl)
  end
end

# A private Object method which will raise a NackClass' error.
def nail( arg )
  if NackClass === arg
    arg.raise_error
  else
    return arg
  end
end



#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#

=begin testing

  require 'test/unit'

  class TC_Nack < Test::Unit::TestCase

    def scalar( x )
      if x.kind_of?(Enumerable)
        return nack(ArgumentError, "Value cannot not be enumerable")
      end
      x
    end

    def test000
      assert_equal( 1, scalar(1) )
    end

    def test001
      assert_equal( nack, scalar([1,2]) )
    end

    def test002
      assert_equal( 1, nail(scalar(1)) )
    end

    def test003
      assert_raises(ArgumentError) { nail(scalar([1,2])) }
    end

  end

=end
