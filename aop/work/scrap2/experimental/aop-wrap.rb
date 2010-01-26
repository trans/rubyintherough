=begin

  aop/aop-wrap.rb

  $Author: transami $
  $Date: 2003/12/06 13:56:57 $

  Copyright (C) 2002 transami

  This program is free software.
  You can distribute/modify this program under
  the terms of the Ruby Distribute License.

=end

class Module

  def wrap(mSym, &block)
    raise "wrap method not defined" if !method_defined?(mSym)
    @__methods__ ||= {}
    if @__methods__[mSym]
      @__methods__[mSym] << block
    else
      alias_method "#{mSym}_orig".intern, mSym
      @__methods__[mSym] = [lambda { send("#{mSym}_orig") }]
      @__methods__[mSym] << block
      class_eval %Q{
        def #{mSym}_sub(*args, &block)
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
        alias_method :#{mSym}, :#{mSym}_sub
        private :#{mSym}_orig, :#{mSym}_super, :#{mSym}_sub
      }
      def self.method_added(mSym)
        @@suspend_method_added ||= false
        if !@@suspend_method_added
          @@suspend_method_added = true
          alias_method "#{mSym}_orig".intern, mSym
          alias_method mSym, "#{mSym}_sub".intern
          public mSym
          @@suspend_method_added = false
        end
      end
    end
  end

  def unwrap(mSym)
    @__methods__[mSym] = [lambda { send("#{mSym}_orig") }]
  end

end

