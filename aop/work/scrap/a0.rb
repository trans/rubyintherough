require 'facets/more/cut.rb'

module Aspects

  # Store advice.

  def aspect
    @aspect ||= (
      if ancestors[1].respond_to?(:aspect)
        anc_cut = ancestors[1].aspect
        Cut.new(self){ include anc_cut }
      else
        Cut.new(self){}
      end
    )
  end

  def before_advice
    @@before_advice ||= Hash.new{|h1,k1| h1[k1]=[]}
  end

  def after_advice
    @@after_advice ||= Hash.new{|h1,k1| h1[k1]=[]}
  end

  # Insert the advice before methods.

  def before(*targets, &block)
    targets, advice = Aspects.resolve(*targets, &block)

    targets.each do |target|
      before_advice[target].unshift advice
      before_advice[target].uniq!

      define_advice(target) unless aspect.method_defined?(target)
    end
  end
  alias_method :pre, :before

  # Insert the advice after methods.

  def after(*targets, &block)
    targets, advice = Aspects.resolve(*targets, &block)

    targets.each do |target|
      after_advice[target] << advice
      after_advice[target].uniq!

      define_advice(target) unless aspect.method_defined?(target)
    end
  end
  alias_method :post, :after

  #

  def define_advice(target)
    aspect.class_eval %{
      def #{target}(*a,&b)
        self.class.before_advice[:#{target}].each do |t|
          Proc === t ? t.call(*a,&b) : send(t,*a,&b)
        end
        super
        self.class.after_advice[:#{target}].each do |t|
          Proc === t ? t.call(*a,&b) : send(t,*a,&b)
        end
      end
    }
  end

  #

  def self.resolve(*targets, &block)
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
    return targets, advice
  end

end



if $0 == __FILE__

class Test
  extend Aspects

  before :hello do 
    puts "before hello"
  end

  before :hello, :lala => :callback
  after :lala do
    puts "after lala"
  end

  def hello(x)
    puts "hello #{x}"
  end

  def lala
    puts "lala"
  end

  def callback(*a)
    puts "before hello, lala and call"
  end

end

class Test2 < Test
  def lala
    puts "lala2"
  end
end

#Aspects.setup

t = Test.new
t.hello(5)
t.lala

puts

t2 = Test2.new
t2.hello(5)
t2.lala

end
