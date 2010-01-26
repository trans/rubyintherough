
require 'carat/1st'
require 'test/unit'

class Tester
  def self.hello
    puts "Hello from Tester"
  end
  def hello
    puts "Hello from a tester#ameth."
  end
  def _hello
    puts "Hello from a tester#_ameth."
  end
end

class TC_1st < Test::Unit::TestCase

  def setup
    @t = Tester.new
  end

  def test_method_identity
    m1 = @t.method(:hello)
    m2 = @t.method(:hello)
    assert_equal(m1, m2, "not identical method objects")
    m1 = @t.class.instance_method(:hello)
    m2 = @t.class.instance_method(:hello)
    assert_equal(m1, m2, "not identical instance method objects")
  end

  def test_method_type
    m1 = @t.method(:hello)
    assert_kind_of(Method, m1)
    m2 = @t.class.instance_method(:hello)
    assert_kind_of(UnboundMethod, m2)
  end
  
#   def test_captials
#     m1 = @t.method(:hello)
#     m2 = @t.Hello
#     assert_same(m1, m2)
#     m1 = @t.class.instance_method(:hello)
#     m2 = @t.class::Hello
#     assert_same(m1, m2)
#     m1 = @t.method(:_hello)
#     m2 = @t._Hello
#     assert_same(m1, m2)
#     #m2 = @t.class.instance_method(:_hello)
#     #m2 = @t.class::_Hello
#     #assert_same(m1, m2)
#   end

end