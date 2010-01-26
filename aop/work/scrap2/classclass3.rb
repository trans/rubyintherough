
#require 'tomslib/aop/aop-classclass'

#A = Aspect.new do
#  def x
#    print "["; super if defined?(super); print "]"
#  end
#end

class C
end

class C < C;
  def self.method_added(m)
    meth = self.instance_method(m)
    self.superclass.__send__(:define_method, m, meth)
    self.__send__(:remove_method, m)
  end
end

class C
  def x
    print "<"; super
  end
end

c = C.new
c.x

