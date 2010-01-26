
class Module
  alias define_method_orig define_method
  def define_method(*args, &block)
    puts "Module.define_method #{self.inspect}"
    return define_method_orig(*args, &block)
  end
end

class Class
  #alias_method :new_orig, :new
  #def new(*args, &block)
  #  puts "Class/new #{self.inspect}"
  #  o = new_orig(*args, &block)
  #  return o
  #end
end

module A
  def m
    puts "A/m"
  end
end

class Object
  #def Object.new
  #  puts "Object.new #{self.inspect}"
  #  super
  #end
  def Object.r
  end
end

Os = class << Object
  self
end

class C
  #def C.new
  #  puts "C.new #{self.inspect}"
  #  super
  #end
  def C.w
  end
  def x
    puts "C/m #{self.inspect}"
  end
end

Cs = class << C
  #include A
  def self.z
    puts "C'.m #{self.inspect}"
  end
  def y
    puts "C'/m #{self.inspect}"
  end
  self
end

def inspection_for(obj, was=nil, indent=0, recurse=1)
  #puts obj, was
  return if !obj
  return if obj == was
q = gets
  i = "\t" * indent
  puts "#{i}#{obj.inspect} < #{obj.superclass.inspect}"
  puts "#{i}methods #{obj.methods(false).inspect}"
  puts "#{i}instance_methods #{obj.instance_methods(false).inspect}"
  puts "#{i}singleton_methods #{obj.singleton_methods(false).inspect}"
  puts "#{i}singleton_methods+ #{obj.singleton_methods(true).inspect}"
  puts "#{i}public_methods #{obj.public_methods(false).inspect}"

  #inspection_for(obj.class, obj, indent+1)

  inspection_for(obj.superclass, obj, indent+1, recurse-1) if recurse != 0

  sing = class << obj; self; end
  inspection_for(sing, obj, indent+1, recurse-1) if recurse != 0
end

#puts
#inspection_for(Object)
puts
inspection_for(C, nil, 0, 2)
puts

#c = C.new
#puts "c class #{c.class.inspect}"
#puts "c methods #{c.public_methods(false).inspect}"
#puts "c singleton methods #{c.singleton_methods(false).inspect}"


#C.y
#c.x


