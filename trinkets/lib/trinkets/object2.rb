
# Add open_accessor.

  class Module
    private
    def open_accessor(r)
      class_eval %{
        def #{r}=(v)
          o = (class << self; self; end)
          if Func === v
            o.send(:define_method,:#{r}, &v)
          else
            o.send(:attr_reader, :#{r})
            @#{r} = v
          end
        end
      }
    end
  end

# All objects are open.

  class Object
    def method_missing( s, *a, &b )
      w = s.to_s
      if w[-1,1] == '='
        r = w.chomp('=')
        v = a[0]
        o = (class << self; self; end)
        o.send(:open_accessor, r)
        send(w,v)
      else
        super
      end
    end
  end

# Func is a Proc, but we need a distinction to determine
# when one represents a new method vs passing a proc as object.

  class Func < Proc
    def to_proc
      Proc.new(self)
    end
  end

# Create a new object of +classification+.

  def obj(classification=Object)
    classification.new
  end

# Define a function.

  def fn(&b)
    Func.new(&b)
  end

# Show off.

  if $0 == __FILE__

    o = obj()

    o.a = 1
    p o.a

    o.b = fn{ puts "hello" }
    o.b

  end
