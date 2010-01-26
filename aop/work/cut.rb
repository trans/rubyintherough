class Class
  attr_accessor :cut
end


class Cut

  def self.new(class_delegate, &block)
    if class_delegate.cut
      cut = Class.new(class_delegate.cut, &block)
    else
      cut = Class.new(class_delegate, &block)
    end

    class_delegate.cut = cut

    def cut.new(*a,&b)
      Class.instance_method(:new).bind(self).call(*a,&b)
    end

    def class_delegate.new(*a,&b)
      cut.new(*a,&b)
    end

    # Instance level.

    cut.class_eval do
      def class
        super.superclass
      end

      #def inspect
      #  ???
      #end
    end

    return cut
  end

end



=begin example

  class X
    def x() "x" end
  end

  cX = Cut.new(X) do
    def x() '{' + super + '}' end
  end

  x = X.new
  p x
  p x.class
  puts x.x

=end
