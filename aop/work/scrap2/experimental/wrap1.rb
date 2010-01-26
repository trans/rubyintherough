
  require 'suby/aop/aop-wrap'

  class Test1
    def x; print "X"; end
  end
  t1 = Test1.new
  t1.x; puts

  class Test1
    wrap :x do
      print "("; x_super; print ")"
    end
  end
  t1.x; puts

  class Test1
    wrap :x do
      print "["; x_super; print "]"
    end
  end
  t1.x; puts

  class Test1
    def x; print "Y"; end
  end
  t1.x; puts

  class Test1
    unwrap(:x)
  end
  t1.x; puts 
