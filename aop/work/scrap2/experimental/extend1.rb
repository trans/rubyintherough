
  require 'suby/aop/aop-extend'

  class MyClass
    def x
      print "X"
    end
  end

  puts "Sample of #extend_advice"

  mc = MyClass.new
  mc.x; puts
  mc.extend_advice /x/ do
    print "("
    super
    print ")"
  end
  mc.x; puts

  module MyAspect
    def x
      print "["
      super
      print "]"
    end
  end

  class MyClass
    aspect MyAspect
  end

  mc.x; puts

  mc2 = MyClass.new
  mc2.x; puts
