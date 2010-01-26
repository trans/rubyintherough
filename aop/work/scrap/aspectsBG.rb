# = aspects.rb
#
# CREDIT George Moschovitis
# CREDIT Thomas Sawyer

require 'facets/core/integer/of'

# Aspects module holds the DSL for creating advice.
# Extend your classes/modules with this.

# TODO Will this work as the toplevel? Probably not. Ugh.

module Aspects

  class Advice
    attr :capacity
    attr :base
    attr :targets
    attr :action

    def initialize( capacity, base, targets, action )
      @capacity = capacity
      @base     = base
      @targets  = targets
      @action   = action
    end

    def match?( capacity, base, method )
      return false unless capacity == @capacity

      case capacity
      when :before, :after
        return false unless base <= @base
      else
        return false unless base == @base
      end

      unless @targets.include?(method.to_sym)
        case method.to_s
        when *@targets
        else
          return false
        end
      end

      return true
    end

    def inspect
      "#<Advice #{capacity} #{base} #{targets.join(',')}>"
    end

    def call(o, *a, &b)
      case action
      when Proc
        o.instance_eval(&action) # TODO use instance_exec
      else
        o.send(action, *a, &b)
      end
    end

    # Advice store.

    @advice = []

    # Advice cache.

    @cache = {}

    class << self

      # Define advice.

      def advice_set( capacity, base, targets, action )
        @cache = {}
        adv = Advice.new( capacity, base, targets, action )
        @advice << adv
        return adv
      end

      # Get advice.

      def advice_get( capacity, base, name )
        if cached = @cache[[capacity, base, name]]
          return cached
        else
          @cache[[capacity, base, name]] = @advice.select do |adv|
            adv.match?(capacity, base, name)
          end
        end
      end

      # Run the advice.

      def advise( capacity, object, method, *a, &b )
        advice = advice_get(capacity, object.class, method)
        case capacity when :before, :pre
          advice = advice.reverse
        end
        advice.each do |adv|
          adv.call(object, *a, &b)
        end
      end

    end

  end

  # Intercept module. This gets added to Aspected Modules/Classes.

  module Intercept

    def extended(base)
      base.module_eval do
        methods = instance_methods.select do |meth|
p meth
          meth =~ /^\w/ and meth !~ /^_/
        end
        methods.each do |meth|
          intercept_method(meth)
        end
      end
    end

    # Add intercepts to any newly defined method.
    #
    # FIXME $ASPECT_INTERCEPTING is not thread safe!!!

    def method_added( name )
      return if $ASPECT_INTERCEPTING
      $ASPECT_INTERCEPTING = true
      intercept_method(name)
      $ASPECT_INTERCEPTING = false
    end

    # Add intercepts to a method.

    def intercept_method( name )
      args = method_interface(name)
      module_eval %{
        alias_method "advised_#{name}", :#{name}
        def #{name}(#{args})
          Advice.advise(:before, self, :#{name}, #{args})
          Advice.advise(:pre, self, :#{name}, #{args})
          r = advised_#{name}(#{args})
          Advice.advise(:post, self, :#{name}, #{args})
          Advice.advise(:after, self, :#{name}, #{args})
          return r
        end
      }
    end

    # Produces a method interface based on a given method
    # which preserves arity.

    def method_interface(name)
      meth = instance_method(name)
      blck = (name.to_s !~ /=$/)
      if (arity = meth.arity) > 0
        args = arity.of{ |i| "a#{i}" }
        args << "&b" if blck
        args = args.join(", ")
      elsif arity == 0
        args = blck ? "&b" : ""
      else
        args = blck ? "*a, &b" : "*a"
      end

      return args
    end

  end

  # Parse arguments for #before and #after methods.

  def self.resolve(object, *targets, &block)
    case targets.last
    when Hash
      raise ArgumentError if block
      last = targets.pop
      advice = last.values[0]
      targets << last.keys[0]
    else
      raise ArgumentError unless block
      advice = block
    end
    targets = [/.*/] if targets.empty?
    return targets, advice
  end

end


class Module

  # Insert the advice before methods.

  def before(*targets, &block)
    extend Aspects::Intercept
    targets, advice = Aspects.resolve(self, *targets, &block)
    Aspects::Advice.advice_set(:before, self, targets, advice)
  end

  # Insert the advice pre methods.

  def pre(*targets, &block)
    extend Aspects::Intercept
    targets, advice = Aspects.resolve(self, *targets, &block)
    Aspects::Advice.advice_set(:pre, self, targets, advice)
  end

  # Insert the advice post methods.

  def post(*targets, &block)
    extend Aspects::Intercept
    targets, advice = Aspects.resolve(self, *targets, &block)
    Aspects::Advice.advice_set(:post, self, targets, advice)
  end

  # Insert the advice after methods.

  def after(*targets, &block)
    extend Aspects::Intercept
    targets, advice = Aspects.resolve(self, *targets, &block)
    Aspects::Advice.advice_set(:after, self, targets, advice)
  end

#   # This needs to be a little more robust.
#   # It also needs to go back and wrap all predefined methods.
#
#   def self.extended(base)
#     base.extend Aspects::Intercept
#     base.module_eval do
#       def self.included(base)
#         super if defined?(super)
#         base.extend Aspects::Intercept
#       end
#     end
#   end

end



#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#


#   module Q
#     extend Aspects
#
#     before :x => :y
#     def y; puts "before x"; end
#   end
#
#   class C
#     include Q
#     def x; puts "x"; end
#   end

=begin test

  require "spec"

  class Test
    extend Aspects

    before :the_name do
      @name << "dear"
    end

    after :the_name => :after1
    #after :the_name, :call => :after1

    def initialize
      @name = []
    end

    def the_name
      return @name
    end

    before :the_name => :before1
    #before :the_name, :call => :before1

  private

    def before1
      @name << "Hello"
    end

    def after1
      @name << "George"
    end
  end

  class AnotherTest
    extend Aspects

    attr_accessor :text
    attr_accessor :name

    # No target methods provided. Should work even before the
    # instance methods are defined.
    after do
      @text = "ok"
    end

    def index ; self ; end
    def hello ; self ; end

    def multi(val1, val2, val3)
    end

  private

    def priv
      false
    end
  end

  context "Advices" do

    setup do
      @test = Test.new
      @another = AnotherTest.new
    end

    specify "are wrapped arround the target" do
      @test.the_name.should == %w{Hello dear George}
    end

    specify "without targets are wrapped around all locally defined public methods" do
      AnotherTest.new.index.text.should == "ok"
      AnotherTest.new.hello.text.should == "ok"
      AnotherTest.new.send(:priv).should_be false
    end

    specify "can be dynamically wrapped" do
      AnotherTest.send(:define_method, :dyna, proc { false; self })
      AnotherTest.new.dyna.text.should == "ok"
    end

    specify "can wrap multiple targets and can be defined anywhere" do
      AnotherTest.before :index, :hello do
        @name = "George"
      end
      a = AnotherTest.new
      a.hello
      a.instance_variable_get("@name").should == "George"
    end
 
    specify "preserves the original method arity" do
      AnotherTest.before :multi do
        @name = "Stella"
      end
      AnotherTest.instance_method(:multi).arity.should == 3
    end
  end

=end


=begin demo

  class C
    before :x => :y
    def x; puts "x"; end
    def y; puts "y"; end
  end

  class D < C
    def x; super; end
  end

  D.new.x

=end
