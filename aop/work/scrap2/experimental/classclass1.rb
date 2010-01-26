
require 'suby/aop/aop-classclass'

# define a normal module

module I
  def x
    print "I"; super if defined?(super); print "I"
  end
end

# define reusable aspects

A = Aspect.new do
  def x
    print "["; super if defined?(super); print "]"
  end
end

B = Aspect.new do
  def x
    print "<"; super if defined?(super); print ">"
  end
end

# define a class

class C
  def x
    print "X"; super if defined?(super); print "X"
  end
end

# define a the class as "aspectable"
# you have to do this first
# this would be like Wrapper

class C < C
  @__aspect__ = true
end

# okay, let's play

c = C.new
print "c  : "; c.x; puts

class C
  aspect A
end

print "Ac : "; c.x; puts

class C
  aspect B
end

print "BAc: "; c.x; puts

d = C.new
print "d: "; d.x; puts

class C
  include I
end

print "ABcI: "; c.x; puts
print "d: "; d.x; puts

e = C.new
print "e: "; e.x; puts

class Z < C
  def x
    print "*"; super if defined?(super); print"*"
  end
end

z = Z.new
print "z: "; z.x; puts
