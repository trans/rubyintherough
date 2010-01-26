
class Module

  def method_added(meth)
    @__methods__ ||= {}
    if @__methods__.has_key?(meth)
      im = instance_method(meth)
      define_method(meth) do |*args|
        im.bind(self).call(*args)
        @__methods__[meth].bind(self).call(*args)
      end
    end
    @__methods__[meth] = instance_method(meth)
  end

end


class Test
  def x
    puts "x"
  end
end

t = Test.new
t.x

class Test
  def x
    puts "y"
  end
end
