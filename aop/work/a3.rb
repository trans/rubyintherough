class Module

  # Access before advice.

  def advice_before
    @advice_before ||= Hash.new{|h,k| h[k]=[]}
  end

  # Access after advice.

  def advice_after
    @advice_after ||= Hash.new{|h,k| h[k]=[]}
  end

  #

  def before(*names, &block)
    options = (Hash === names.last ? names.pop : {})
    advice = options[:call] || block

    Aspect.advise(self)

    if names.empty?
      advice_before[:_].unshift(advice)
    else
      names.each do |name|
        advice_before[name.to_sym].unshift(advice)
      end
    end
  end

  #

  def after(*names, &block)
    options = (Hash === names.last ? names.pop : {})
    advice = options[:call] || block

    Aspect.advise(self)

    if names.empty?
      advice_after[:_].push(advice)
    else
      names.each do |name|
        advice_after[name.to_sym].push(advice)
      end
    end
  end

end


class Aspect # < Module

  instance_methods.each{ |m| undef_method(m) unless m =~ /^__/ }

  def initialize(base, *a, &b)
    @base = base
    @self = base.new_without_aspect(*a, &b)
  end

  def method_missing(s, *a, &b)
    local = @base.public_instance_methods(false).include?(s.to_s)
    Aspect.execute_advice(@self, @base.advice_before[:_], *a, &b) if local
    Aspect.execute_advice(@self, @base.advice_before[s], *a, &b)
    result = @self.send(s, *a,&b)
    Aspect.execute_advice(@self, @base.advice_after[s], *a, &b)
    Aspect.execute_advice(@self, @base.advice_after[:_], *a, &b)  if local
    return result
  end

  def self.execute_advice(object, advice, *a, &b)
    advice.each do |f|
      case f
      when Proc
        object.instance_eval(&f)
      else
        object.send(f, *a, &b)
      end
    end
  end

  def self.advise(base)
    case base
    when Class
      return if base.respond_to?(:new_without_aspect)
      class << base
        alias :new_without_aspect :new

        def new(*a,&b)
          Aspect.new(self, *a, &b)
        end
      end
    #when Module
    #  base.instance_eval %{
    #    def included(base)
    #      Aspectable.included(base)
    #    end
    #  }
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

    attr_accessor :text, :all
    attr_accessor :name

    after :dyna do
      @text = "ok"
    end

    # No target methods provided. Should work even before the
    # instance methods are defined.
    after do
      @all = "ok"
    end

    def index ; self ; end
    def hello ; self ; end

    def multi(val1, val2, val3, val4); end

    before :multi, :call => :jump

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
      TestAspects2.instance_method(:multi).arity.should == 4
    end

    specify "without targets are wrapped around all locally defined public methods" do
      TestAspects2.new.index.all.should == "ok"
      TestAspects2.new.hello.all.should == "ok"
      TestAspects2.new.send(:priv).should_be false
    end
  end

=end

=begin demo

  class X
    before do
      print "["
    end

    before :tryit do
      print "{"
    end

    def tryit
      print "!"
    end

    after :tryit do
      print "}"
    end

    after do
      print "]"
    end
  end

  x = X.new
  x.tryit; puts

  p x.class

=end
