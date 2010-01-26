
=begin
  module W
    def x; print "W"; super if defined?(super); end
  end

  module A
    def x; print "A"; super if defined?(super); end
  end

  class C
    def x; print "C"; super if defined?(super); end
  end

  c1 = C.new
  class << c1; include W; end

  print "1. WC == "; c1.x; puts

  module W
    include A
  end

  print "2. WAC == "; c1.x; puts

  c2 = C.new
  class << c2; include W; end

  print "3. WAC == "; c2.x; puts

  exit 0
=end

require 'suby/aop/aop'

#A = Aspect.new do
module A
  def x
    print "("; super if defined?(super); print ")"
  end
end

#module B
#  def x
#    print "["; super; print "]"
#  end
#end

class C
  def x
    print "X"
  end
end
c1 = C.new
print "c1.x "; c1.x; puts
class C
  aspect A
end
print "c1.x "; c1.x; puts

c2 = C.new
print "c2.x "; c2.x; puts

class K
  aspect A
  def r
    print "Rite!"
  end
end
k = K.new
print "k.r "; k.r; puts
print "k.x "; k.x; puts

#class B < A
#  def x
#    print "<"; super; print ">"
#  end
#end
#
#b = B.new
#b.x; puts
#puts
#
#class B
#  aspect AspectB
#end
#
#a.x; puts
#b.x; puts
