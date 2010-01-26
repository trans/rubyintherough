
class Advice
   attr_accessor :__super__

   def initialize( obj, mod, &blk )
     @__obj__ = obj 
     @__super__ = blk
     extend mod
   end

   def inspect(*args) ; @__obj__.inspect(*args) ; end
   def to_s(*args) ; @__obj__.to_s(*args) ; end
   def to_a(*args) ; @__obj__.to_a(*args) ; end
   def ==(*args) ; @__obj__.==(*args) ; end
   def =~(*args) ; @__obj__.=~(*args) ; end
   def ===(*args) ; @__obj__.===(*args) ; end
   
   def super!(*args)
     @__super__.call(*args)
   end

   def method_missing( meth, *args )
     @__obj__.send( meth, *args )
   end
   
end


class Module
  def advice( advice_module=nil, &blk )
    if advice_module or blk
      advice_module = Module.new( &blk ) if block_given?
      @__advice__ = advice_module
    else
      @__advice__
    end
  end
end

class Object
  def advice( mod=self.class, &super_block )
    Advice.new( self, mod.advice, &super_block )
  end
end


# Example

class C
  def m1 ; "Charlie" ; end
end

module M
  advice {
    def bracket
      "<" + super! + ">"
    end  
  }
end

class Cc < C
  include M

  def m1
    p advice{ super }.bracket
    p advice{ super }.bracket2
    p advice(M){ super }.bracket
    p bracket
  end

  def cheese
    "Cheese"
  end

  def bracket
    "HERE"
  end

  advice {
    def bracket
      "{" + super! + "}"
    end
    def bracket2
      cheese
    end
  }
  
end

c = Cc.new
c.m1

