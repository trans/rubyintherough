=begin

  aop/aop.rb

  $Author: transami $
  $Date: 2003.12.15 $

  This program is free software.
  You can distribute/modify this program under
  the terms of the Ruby Distribute License.

=end

class Aspect < Module; end

class Class
  alias_method :new_orig, :new
  def __aspect__; @__aspect__; end
  def new(*args, &block)
    #class_eval do
      #def self.inherited(sub)
      #  raise if self == SyntaxError
      #  puts "Inheriting #{sub} < #{self}, #{self.__aspect__}" #if $DEBUG
      #  if @__apspect__ != false
      #    sub.class_eval %Q{
      #      class << self
      #        alias superclass_orig superclass
      #        def superclass
      #          p superclass_orig
      #          #{self}.__aspect__
      #        end
      #      end
      #    }
      #  end
      #end
    #end
    if @__aspect__
      ia = @__aspect__.included_modules.select { |a| a.is_a? Aspect }
      sub.class_eval{ include(*ia) } if !ia.empty?
    end
    @__aspect__ = false
    @__aspect__ ||= Class.new_orig(self)
    @__aspect__.new_orig(*args, &block)
  end
  def aspect(*args)
    raise TypeError if !args.all?{|a| a.is_a? Aspect }
    @__aspect__.class_eval { include(*args) }
  end
end

class Object
  def extend_advice(match, &block)
    extmod = Module.new
    self.public_methods(true).each do |m|
      if m.to_s =~ match
        extmod.module_eval {
          define_method(m, &block)
        }
      end
    end
    if extmod.instance_methods(false) != []
      self.extend(extmod)
    end
  end
end
