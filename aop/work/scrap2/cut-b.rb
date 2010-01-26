# Cuts, Transparent Subclasses
# Copyright (c) 2004 Thomas Sawyer
# cut.rb


class Class
  def cut; @cut; end
  def cut=(c); @cut=c; end
  alias_method :cnew, :new
  def new(*args, &blk)
    if @cut
      @cut.new(*args, &blk)
    else
      self.cnew(*args, &blk)
    end
  end
end


class Cut < Module
  attr :superclass
  attr :supercut
  
  def initialize(superclass, &blk)
    @superclass = superclass
    @supercut = superclass.cut
    @cut = Class.new( (@supercut ? @supercut : @superclass), &blk )
    @superclass.cut = @cut
  end
  
  # returns the "superest" cut lacking a given method
  def clearcut(meth)
    r = @supercut.clearcut(meth) if @supercut
    return ( r ? r : ( instance_methods.include?(meth) ? nil : self ) )
  end

end


# ---- test ----

class C
  def m1; "c"; end
end

# cut A < C
A = Cut.new(C) do
  def m1; "c" + super; end
end

c = C.new
puts c.m1
