
require 'test/unit'
require 'aop/cut'


# pre-setup
  
  class C
    def m1; "c"; end
  end
  
  # cut A < C
  A = Cut.new(C) do
    def m1; "c" + super; end
  end
  
  # cut B < C
  B = Cut.new(C) do
    def m1; "b" + super; end
  end


# test case

class TC_Cut < Test::Unit::TestCase

  def setup
    @c = C.new
  end
  
  def test_run
    assert_equal("bcc", @c.m1)
    assert_equal(A, C.clearcut(:dne))
    assert_equal(nil, C.clearcut(:m1))
  end
    
end 

