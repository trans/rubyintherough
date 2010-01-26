
class Meth
  def initialize(sym, &blk)
    @name = sym
    @call = blk
  end
  def call(*args, &blk)
    @call.call(*args, &blk)
  end
end

class Module
  def __methods__
    @__methods__ ||= {}
  end
  def meth(sym, &blk)
    __methods__[sym] = Meth.new(sym, &blk)
  end
  def method_missing(sym, *args, &blk)
    @__methods__[sym].call(*args, &blk)
  end
end

class Object
  def method_missing(sym, *args, &blk)
    p self.class.__methods__[sym]
    self.class.__methods__[sym].call(*args, &blk) if self.class.__methods__.has_key?(sym)
  end
end

# --- test ---

  class A
    
    meth :t do
      puts "hello"
    end

  end
  
  a = A.new
  a.t

