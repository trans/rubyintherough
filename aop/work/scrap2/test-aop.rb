
require 'test/unit'
require 'suby/aop/aop'


class TC_AOP < Test::Unit::TestCase

  module Module1
    def method1
      "[1:" + ((super if defined?(super)) || '') + ":1]"
    end
  end

  Aspect1 = Aspect.new do
    def method1
      "<1:" + ((super if defined?(super)) || '') + ":1>"
    end
  end

  class Class1
    def method1
      "{1:" + ((super if defined?(super)) || '') + ":1}"
    end
  end

  class Class2 < Class1
    def method1
      "{2:" + ((super if defined?(super)) || '') + ":2}"
    end
  end

  def test_class1
    c = Class1.new
    assert_equal("{1::1}", c.method1)
  end

  def test_class2
    c = Class2.new
    assert_equal("{2:{1::1}:2}", c.method1)
  end

  class Class1
    aspect Aspect1
  end

  def test_class1_aspect1
    c = Class1.new
    assert_equal("<1:{1::1}:1>", c.method1)
  end

  def test_class2_aspect1
    c = Class2.new
    assert_equal("{2:<1:{1::1}:1>:2}", c.method1)
  end

end
