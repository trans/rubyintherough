
class Module

  def codepack( name, &block )
    @__codepack__ ||= {}
    return @__codepack__ unless block_given?
    @__codepack__[name.to_sym] = block
  end

  def provide_features( base, *selection )
    if selection.empty?
      @__codepack__.each { |k,codepack|
        base.class_eval( &codepack )
      }
    else
      selection.each do |s|
        base.class_eval( &@__codepack__[s.to_sym] )
      end
    end
  end

  def use( codepack, *selection )
    if String === codepack or Symbol === codepack
      codepack = constant(codepack)
    end
    codepack.provide_features( self, *selection )
  end

end


#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#

=begin test

  require 'test/unit'

  class TCModule < Test::Unit::TestCase

    module MyPackages
      package :foo do
        def foo
          "yes"
        end
      end
    end

    class Y
      use MyPackages, :foo
    end

    def  test_package
      y = Y.new
      assert_equal( "yes", y.foo )
    end

  end

=end
