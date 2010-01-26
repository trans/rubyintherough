class Aspect < Module
end

class Module
  def aspect?; @aspect; end
  def aspect=(b); @aspect = (b ? true : false); end
end

class Module
  alias include_orig include
  def include(*args)
    base = self.ancestors.find { |a| !a.aspect? and a.kind_of?(Class) }
    puts "base: #{base.inspect}"
    #base.include_orig(*args)
    base.class_eval { include_orig(*args) }
  end
  def aspect(*args)
    include_orig(*args)
  end
end


# define a normal module

module MyModule
  def x
    print "{"; super if defined?(super); print "}"
  end
end

# define reusable aspects

module MyAspectA
  #self.aspect = true
  def x
    print "["; super; print "]"
  end
end

module MyAspectB
  #self.aspect = true
  def x
    print "<"; super; print ">"
  end
end

# define a class

class MyClass
  def x
    print "X"; super if defined?(super); print "X"
  end
end

# define a base aspect for the class

class MyClass < MyClass
  self.aspect = true
end

# okay, let's play

mca = MyClass.new
print "mca: "; mca.x; puts

class MyClass
  aspect MyAspectA
end

print "mca: "; mca.x; puts

class MyClass
  aspect MyAspectB
end

print "mca: "; mca.x; puts

mcb = MyClass.new
print "mcb: "; mcb.x; puts

class MyClass
  include MyModule
end

print "mca: "; mca.x; puts
print "mcb: "; mcb.x; puts


