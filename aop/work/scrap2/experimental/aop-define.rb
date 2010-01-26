=begin

 aop/aop-define.rb

 $Author: transami $
 $Date: 2003/12/06 13:56:57 $

 Copyright (C) 2002 transami

 This program is free software.
 You can distribute/modify this program under
 the terms of the Ruby Distribute License.

=end
# this presents an idea of allowing methods to be defined
# such that they stack one on top of the other, rather then overwriting.

class Module

  def define(mSym, &block)
    @__methods__ ||= {}
    if !method_defined?(mSym)
      @__methods__[mSym] = []
      @__methods__[mSym] << block
      class_eval %Q{
        def #{mSym}(*args, &block)
          @__methods_counter__ ||= {}
          @__methods_counter__[:#{mSym}] = self.class.instance_variable_get("@__methods__")[:#{mSym}].length
          #{mSym}_super(*args, &block)
        end
        def #{mSym}_super(*args, &block)
          @__methods_counter__[:#{mSym}] -= 1
          i = @__methods_counter__[:#{mSym}]
          if i >= 0
            m = self.class.instance_variable_get("@__methods__")[:#{mSym}][i]
            instance_eval &m
          end
        end
        private :#{mSym}_super
      }
    else
      @__methods__[mSym] << block
    end
  end

  def redefine(mSym, &block)
    @__methods__[mSym] = []
    define(mSym, &block)
  end

end

