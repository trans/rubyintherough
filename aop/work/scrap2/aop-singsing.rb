

class Aspect < Module; end

class Class
  alias_method :new_orig, :new
  def new(*args, &block)
    #puts "#{self.inspect} : #{@__aspects__.inspect}"
    p self
    @__wrapper__ ||= Module.new
    Class.new_orig(self)
    o = @__wrapper__.new_orig(*args, &block) do
    class << o
      include @__wrapper__
    end
    return o
  end
end

class Module
  #private
  #alias_method :append_features_orig, :append_features
  #def append_features(mod)
  #  base = mod.ancestors.find { |a| !a.aspect? and a.kind_of?(Class) }
  #  if base
  #    append_features_orig(base)
  #  else
  #    append_features_orig(mod)
  #  end
  #end
  def prepend_features(mod)
    wrapper = (class << mod; class << self; self; end; end)
    puts "prepend_features:: self: #{self.inspect}, module: #{mod.inspect}, wrapper: #{wrapper.inspect}"
    self.__send__(:append_features, wrapper)
  end
  def aspect(*modules)
    puts "aspect:: self: #{self.inspect}, modules: #{modules.inspect}"
    modules.reverse_each do |mod|
      mod.__send__(:prepend_features, self)
    end
  end
  def aspect_modules
    wrapper = (class << self; class << self; self; end; end)
    a = wrapper.included_modules.select { |a| a.is_a?(Aspect) }
    puts "aspect_modules:: self: #{self.inspect}, included_modules: #{wrapper.included_modules.inspect}, aspects: #{a.inspect}"
    return a
  end
  def wrapper
    (class << self; class << self; self; end; end)
  end
end

