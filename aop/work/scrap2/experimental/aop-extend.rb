=begin

  aop/aop-extend.rb

  $Author: transami $
  $Date: 2003/12/06 13:56:57 $

  Copyright (C) 2002 transami

  This program is free software.
  You can distribute/modify this program under
  the terms of the Ruby Distribute License.

=end

class Aspect < Module; end

class Class
  alias_method :new_orig, :new
  def __aspects__
    a = superclass.instance_variable_get("@__aspects__") || []
    a.concat(@__aspects__) if @__aspects__
    a = nil if a.empty?
    return a
  end
  def new(*args, &block)
    #puts "#{self.inspect} : #{@__aspects__.inspect}"
    o = new_orig(*args, &block)
    a = __aspects__
    o.extend(*a) if a
    return o
  end
  def aspect(*mods)
    @__aspects__ ||= []
    @__aspects__.concat(mods.reverse)
  end
end

=begin
# OLD VERSION
class Class
  alias old_new new
  def new(*args, &block)
    o = old_new(*args, &block)
    asp = o.class.instance_variable_get("@__aspects__")
    o.extend(*asp) if asp
    return o
  end
  def aspect(*mods)
    @__aspects__ ||= []
    @__aspects__.concat(mods)
  end
end
=end


