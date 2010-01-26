
require 'suby/aop/aop-classclass'

A = Aspect.new do
  def x
    print "("; super if defined?(super); print ")"
  end
end

S = Aspect.new do
  def x
    print "{"; super if defined?(super); print "}"
  end
end

class C
  def x
    print "C"; super if defined?(super); print "C"
  end
end
class C < C
  @__aspect__ = true
end

class B < C
  def x
    print "B"; super if defined?(super); print "B"
  end
end
class B < B
  @__aspect__ = true
end

c = C.new
c.x; puts

b = B.new
b.x; puts

class C
  aspect A
end

c.x; puts
b.x; puts

class B
  aspect S
end

c.x; puts
b.x; puts

