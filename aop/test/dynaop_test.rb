#
# Tests for dynaop.rb
#

require 'test/unit'
require 'aop/dynaop'


# setup

class Logging < AOP::Weaving::Aspect

  attr_reader :a

  def crosscut(jp)
    return :log if jp.klass.name == 'T' && jp.meth == :test1
    return :modify if jp.klass.name == 'T' && jp.meth == :test2
  end

  def log(target, *args)
    @a = target.call
    return "<#{@a}>"
  end
  passive :log
  
  def modify(target, *args)     
    @a = target.call
    return "<#{@a}>"
  end
  
end

# The weave method instantiates the Aspect
$logger = Logging.weave

class T
  def initialize
    @testvar = true
  end
  def test1; "t1"; end
  def test2; "t2"; end
end

# test case

class TC_DYNAOP < Test::Unit::TestCase

  def test_1
    t = nil
    assert_nothing_raised { t = T.new }
    assert_equal( "t1", t.test1 )
    assert_equal( "t1", $logger.a )
  end
  
  def test_2
    t = nil
    assert_nothing_raised { t = T.new }
    assert_equal( "<t2>", t.test2 )
    assert_equal( "t2", $logger.a )
  end
  
end
