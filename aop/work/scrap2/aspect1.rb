
require 'suby/aop/aop'

# define a normal module

module M
  def x
    print "{"; super if defined?(super); print "}"
  end
end

# define reusable aspects

A1 = Aspect.new do
  def x
    print "["; super; print "]"
  end
end

A2 = Aspect.new do
  def x
    print "<"; super; print ">"
  end
end

# define a class

class C1
  def x
    print "X"; super if defined?(super); print "X"
  end
end

# okay, let's play

c1 = C1.new
print "c1: "; c1.x; puts

class C2 < C1
  def x
    print "/"; super; print "/"
  end
end

puts "HER): #{C2.superclass.inspect}"

class C1
  aspect A1
end

print "c1 w/ A: "; c1.x; puts

class C1
  aspect A2
end

print "c1 w/ B: "; c1.x; puts

#class C1
#  include M
#end

#print "c1 w/ I: "; c1.x; puts

#c1.extend_advice(/x/) do
#  print "*"; super; print "*"
#end

#print "c1 w/ E: "; c1.x; puts

c2 = C2.new
print "c2: "; c2.x; puts

