module Aspectable

  # TODO Need to make included override more robust (what if one already exists?)

  def self.included(base)
    case base
    when Class
      base.instance_eval %{
        alias :create :new

        def new(*a,&b)
          obj = allocate
          obj.extend @aspect if @aspect
          obj.send(:initialize,*a,&b)
          return obj
        end
      }
    when Module
      base.instance_eval %{
        def included(base)
          Aspectable.included(base)
        end
      }
    end
  end

end


class Module

  def aspect_module
    @aspect ||= Aspect.new(self)
  end

  def aspect(*modules, &block)
    include Aspectable
    aspect_module.instance_eval{ include *modules } unless modules.empty?
    aspect_module.module_eval(&block) if block
    aspect_module
  end

  def advice(&block)
    include Aspectable
    #mods.each{ |m| aspect_module.module_eval{ include m } }
    aspect_module.module_eval(&block) if block
    aspect_module
  end

  def before(*names, &block)
    include Aspectable
    if Hash === names.last
      last = names.pop
      block = last[:call] if last[:call]
    end
    names.each do |name|
      aspect_module.define_before_advice(name, block)
    end
  end

  def after(*names, &block)
    include Aspectable
    if Hash === names.last
      last = names.pop
      block = last[:call] if last[:call]
    end
    names.each do |name|
      aspect_module.define_after_advice(name, block)
    end
  end
end


# Aspect defines around advice as methods, and stores before and after advice.

class Aspect < Module
  #class << self
  #  alias :new :create
  #end

  attr_reader :base

  def initialize(base)
    @base = base
    base.ancestors[1..-1].reverse.each do |anc|
      include anc.aspect_module
    end
    @before_advice = Hash.new{|h,k| h[k]=[]}
    @after_advice  = Hash.new{|h,k| h[k]=[]}
  end

  def before_advice(name=nil)
    name ? @before_advice[name.to_sym] : @before_advice
  end

  def after_advice(name=nil)
    name ? @after_advice[name.to_sym] : @after_advice
  end

  def before(name)
    @before_advice[name.to_sym]
    #adv = super if defined?(super)
    #base.ancestors.reverse.collect do |ancector|
    #  ancector.aspect_module.before_advice[name.to_sym]
    #end
  end

  def after(name)
    @after_advice[name.to_sym]
    #base.ancestors.reverse.collect do |ancector|
    #  ancector.aspect_module.after_advice[name.to_sym]
    #end
  end

  def define_before_advice(name, method, &block)
    advice = method || block
    define_advice(name)
    before_advice(name).unshift(advice)
  end

  def define_after_advice(name, method, &block)
    advice = method || block
    define_advice(name)
    after_advice(name) << advice
  end

  def define_advice(name)
    return if !before(name).empty? or !after(name).empty?
    args = method_interface(name)
    module_eval %{
      def #{name}(#{args})
        aspect = self.class.aspect_module
        aspect.execute_before(self, :#{name}, #{args})
        result = super
        aspect.execute_after(self, :#{name}, #{args})
        return result
      end
    }
  end

  # Produces a method interface based on a given method
  # which preserves arity.

  def method_interface(name)
    return "*a, &b" unless base.method_defined?(name)
    meth = base.instance_method(name)
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

  # Execution

  def execute_before(object, name, *a, &b)
    execute_advice(object, before(name), *a, &b)
  end

  def execute_after(object, name, *a, &b)
    execute_advice(object, after(name), *a, &b)
  end

  def execute_advice(object, advice, *a, &b)
    advice.each do |f|
      case f
      when Proc
        object.instance_eval(&f)
      else
        object.send(f, *a, &b)
      end
    end
  end

end




#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#

=begin test

  require 'test/unit'

  class TestAspects_Around < Test::Unit::TestCase

    class X
      include Aspectable
      def f ; "f" ; end
      advice do
        def f; '{' + super + '}'; end
      end
    end

    def test_x
      assert_equal("{f}", X.new.f)
    end

    class Y < X
      def f ; super + "!" ; end
      advice do
        def f; '[' + super + ']'; end
      end
    end

    def test_y
      assert_equal("[{f!}]", Y.new.f)
    end

    module M
      def f; "<" + super + ">"; end
    end

    class Z < X
      aspect M
      def f ; super + "?" ; end
    end

    def test_z
      assert_equal("<{f?}>", Z.new.f)
    end

  end


  class TestAspects_Before < Test::Unit::TestCase

    class X
      include Aspectable
      attr_reader :a, :b
      def f ; "f" ; end
      before :f do
        @a = true
      end
      before :f do
        @b = true
      end
    end

    def test_x
      x = X.new
      x.f
      assert(x.a)
      assert(x.b)
    end
  end

=end

=begin spec

  require "spec"

  class TestAspects1

    before :the_name do
      @name << "dear"
    end

    #after :the_name => :after1
    after :the_name, :call => :after1

    def initialize
      @name = []
    end

    def the_name
      return @name
    end

    #before :the_name => :before1
    before :the_name, :call => :before1

  private

    def before1
      @name << "Hello"
    end

    def after1
      @name << "George"
    end
  end

  class TestAspects2

    attr_accessor :text
    attr_accessor :name

    # No target methods provided. Should work even before the
    # instance methods are defined.
    after :dyna do
      @text = "ok"
    end

    def index ; self ; end
    def hello ; self ; end

    def multi(val1, val2, val3, val4); end

    before :multi => :jump

    def jump(*a); end

  private

    def priv
      false
    end
  end


  context "Advices" do

    setup do
      @test1 = TestAspects1.new
      @test2 = TestAspects2.new
    end

    specify "are wrapped arround the target" do
      @test1.the_name.should == %w{Hello dear George}
    end

    specify "can wrap multiple targets and can be defined anywhere" do
      TestAspects2.before :index, :hello do
        @name = "George"
      end
      a = TestAspects2.new
      a.hello
      a.instance_variable_get("@name").should == "George"
    end

    specify "can be dynamically wrapped" do
      TestAspects2.send(:define_method, :dyna, proc{ false; self })
      TestAspects2.new.dyna.text.should == "ok"
    end

    specify "preserves the original method arity" do
      TestAspects2.before :multi do
        @name = "Stella"
      end
      TestAspects2.instance_method(:multi).arity.should == 3
    end

    specify "without targets are wrapped around all locally defined public methods" do
      TestAspects2.new.index.text.should == "ok"
      TestAspects2.new.hello.text.should == "ok"
      TestAspects2.new.send(:priv).should_be false
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
