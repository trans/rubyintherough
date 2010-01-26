require "facets/core/module/class_extension"
require "facets/more/inheritor"

# Support Aspect Oriented Programming (AOP).
#
# === Examples
#
# before :save do 
#   @time = Time.now
# end
# before :insert, :call => :timestamp
# before :read, :create, :call => :check_user_login
# after :read, do 
#   puts "Article hit"
# end
# before instance_methods, :call => :log
#
# The aspects are inherited.
#
# Check this page for more details on the method aliasing trick:
# http://zimbatm.oree.ch/2006/12/25/various-method-aliasing-methods-in-ruby

module Aspects

  # Insert the advice before the method.

  def before(*args, &block)
    meths, advice, options = Aspects.resolve(self, args, block)

    for meth in meths
      advices! << [:before_method, meth, advice]
    end
    
    return self
  end
  alias_method :pre, :before

  # Insert the advice after the method. Works exactly like
  # #before.
  
  def after(*args, &block)
    meths, advice, options = Aspects.resolve(self, args, block)
    
    for meth in meths
      advices! << [:after_method, meth, advice]
    end
    
    return self
  end
  alias_method :post, :after

  def before_method(meth, advice) # :nodoc:
    old_method = instance_method(meth)

    if advice.is_a? Proc
      define_method(meth) do |*args|
        advice.call()
        old_method.bind(self).call(*args)
      end
    else
      define_method(meth) do |*args|
        send(advice)
        old_method.bind(self).call(*args)
      end      
    end
  end

  def after_method(meth, advice) # :nodoc:
    old_method = instance_method(meth)

    if advice.is_a? Proc
      define_method(meth) do |*args|
        old_method.bind(self).call(*args)
        advice.call()
      end
    else
      define_method(meth) do |*args|
        old_method.bind(self).call(*args)
        send(advice)
      end      
    end
  end

  class << self

    attr_accessor :advised_classes
      
    # Apply all aspects to the  advised classes
    
    def setup
      for c in @advised_classes
        apply(c)
      end
    end
    
    # Apply aspects to the given class.
    
    def apply(klass)
      if klass.respond_to? :advices
        for a in klass.advices
          klass.send(*a)          
        end
      end
    end

    def resolve(klass, args, block) # :nodoc:
      advice = nil
      
      if args.last.is_a? Hash
        options = args.pop
        advice = options[:call] || options[:advice] 
      end

      @advised_classes ||= []
      @advised_classes.push(klass).uniq!
      
      unless klass.respond_to? :advices
        klass.inheritor(:advices, [], :+)
      end
        
      advice = block if block
       
      return args, advice, options 
    end

  end # self
  
end

# Add AOP support to all modules.

class Module
  include Aspects
end


if $0 == __FILE__

class Test

  before :hello do 
    puts "before hello"
  end

  before :hello, :lala, :call => :callback
  after :lala do
    puts "after lala"
  end

  def hello(x)
    puts "hello #{x}"
  end

  def lala
    puts "lala"
  end

  def callback
    puts "before hello, lala and call"
  end

end

class Test2 < Test
  def lala
    super
  end
end

Aspects.setup

t = Test.new
t.hello(5)
t.lala

puts

t2 = Test2.new
t2.hello(5)
t2.lala

end
