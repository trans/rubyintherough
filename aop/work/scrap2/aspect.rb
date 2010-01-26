# aspect.rb

class Aspect < Module
  class << self
    @@__aspects__ = {}
    def [](klass)
      @@__aspects__[klass] ||= []
    end
    def []=(klass, asps)
      @@__aspects__[klass] = asps
    end
  end
  
  def initialize(*klasses)
    @classes = klasses
    @classes.each { |k| Aspect[k] = Aspect[k] | [self] }
    super()
  end
  
  def classes
    return @classes.dup.freeze
  end
end

class Class
  alias_method :inherited_preaop, :inherited
  def inherited(subklass)
    superklass = self
    subklass.module_eval do
puts "Class#inherited #{self}#{Aspect[superklass].inspect} < #{superklass}"
      include *Aspect[superklass].reverse if Aspect[superklass]
    end
    inherited_preaop(subklass)
  end
end
  
module Kernel
  def aspect(a_c=nil, &blk)
    if a_c.kind_of?(Hash)
      aspect_name = nil; klasses = nil
      a_c.each {|a,c| aspect_name = a; klasses = [c].flatten }
      self.class.module_eval { const_set( aspect_name, Aspect.new(*klasses, &blk) ) }
    else
      # aspect singleton
    end
  end
end



class C
  def c1; "c"; end
end

class D
  def d1; "d"; end
end

aspect :A => [C, D] do
#A = Aspect.new( C, D ) do
  def c1
    '{' + super + '}'
  end
  def d1
    '[' + super + ']'
  end
end

#puts "A's classes"
#p A.classes

class K < C
  def c1
    "\n---- K ----\n" + super + "\n--- end ---\n"
  end
end

k = K.new
puts k.c1

aspect :B => [C] do
  def c1
    '<' + super + '>'
  end
end

puts k.c1

class Q < C
  def c1
    "\n---- Q ----\n" + super + "\n--- end ---\n" 
  end
end

q = Q.new
puts q.c1

