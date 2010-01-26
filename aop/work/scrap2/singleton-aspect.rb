#

class Object
  def extend_advice(match, &block)
    extmod = Module.new_unwrapped
    self.public_methods(true).each do |m|
      if m.to_s =~ match
        extmod.module_eval { define_method(m, &block) }
      end
    end
    if extmod.instance_methods(false) != []
      self.extend(extmod)
    end
  end
end

class Class
  alias_method(:new_unwrapped, :new)
  def new(*args, &block)
#q = gets; exit 0 if q =~ /q/
    obj = new_unwrapped(*args, &block)
    #obj_sing = (class << obj; self; end)
    @__wrapper__ ||= Module.new_unwrapped
    obj.extend(@__wrapper__)
    #@__wrapper__.__send__(:append_features, obj_sing)
    puts "Created new object #{obj.inspect} of class #{self.inspect} with wrapper #{@__wrapper__.inspect}" if $DEBUG
    return obj
  end
  def aspect_modules
    @__wrapper__.included_modules
  end
  def wrapper
    @__wrapper__
  end
  def aspect(*modules)
    @__wrapper__ ||= Module.new_unwrapped
    @__wrapper__.__send__(:include, *modules)
  end
  #def aspect(*modules)
  #  @__wrapper__ ||= Module.new_unwrapped
  #  puts "Aspecting #{self.inspect} with modules #{modules.inspect} in wrapper #{@__wrapper__.inspect}" if $DEBUG
  #  modules.reverse_each{|m| m.__send__(:append_features, @__wrapper__)}
  #end
end
