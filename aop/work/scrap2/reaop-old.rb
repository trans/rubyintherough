# reaop.rb

require 'succ/binding'


# Something ishy about set_trace_func, false#name
# seems to fix it (plus a few more for good measure)
class FalseClass;
  def name; 'FalseClass'; end
end
class TrueClass
  def name; 'TrueClass'; end
end
class NilClass
  def name; 'NilClass'; end
end

# global flag can swtich EAOP off and on
$reaop = true

class TracePoint
  attr_reader :event, :klass, :meth, :file, :lineno, :binding
  def initialize(event, klass, meth, file, lineno, binding)
    @event = event
    @klass = klass
    @meth = meth
    @file = file
    @lineno = lineno
    @binding = binding
    @binding.event = event
  end
  def to_s
    "#{@event} #{@klass}##{@meth} (line #{@lineno} in #{@file})"
  end
end

class TraceSet
  @@__active__ = []
  def self.active; @@__active__; end
  def start; @@__active__ << self; end
  def stop; @@__active__.delete(self); end
  attr_reader :event, :klass, :meth, :file, :lineno, :contingent
  def initialize(event, klass, meth, file, lineno, &contingent)
    @event = event
    @klass = klass
    @meth = meth
    @file = file
    @lineno = lineno
    @contingent = contingent
  end
  def to_s
    "#{@event} #{@klass}##{@meth} (line #{@lineno} in #{@file})"
  end
  def check(tp)
    return false if @klass !~ tp.klass.name if @klass
    return false if @meth !~ tp.meth.to_s if @meth
    return false if @event !~ tp.event if @event
    return false if ! @contingent.call(tp.binding)
    return false if @file !~ tp.file if @file
    return false if @lineno !~ tp.lineno if @lineno
    true
  end
  def report_check(tp)
    q = []
    q << "class=#{tp.class.name}" if @klass !~ tp.klass.name if @klass
    q << "meth=#{tp.meth}" if @meth !~ tp.meth.to_s if @meth
    q << "event=#{tp.event}" if @event !~ tp.event if @event
    q << 'contingent' if ! @contingent.call(tp.binding)
    q << "file=#{tp.file}" if @file !~ tp.file if @file
    q << "lineno=#{tp.lineno}" if @lineno !~ tp.lineno if @lineno
    return "#{q.join(' ')}"
  end
  def call
    @self = tp.binding.self
    case method(:advice).arity
    when 1; advice(@self)
    when 2; advice(@self, tp)
    else; advice()
    end
  end      
end

class PointCut < TraceSet
  def initialize(klass, meth, &contingent)
    @event = /(call|return)/
    @klass = klass
    @meth = meth
    @file = nil
    @lineno = nil
    @contingent = contingent
  end
  def to_s
    "#{@klass}##{@meth}"
  end
  def call(tp)
    if tp.event == 'call'
      @before_tp = tp
      @self = tp.binding.self
      case method(:before_advice).arity
      when 1; before_advice(@self)
      when 2; before_advice(@self, tp)
      else; before_advice()
      end
    elsif tp.event == 'return'
      case method(:after_advice).arity
      when 1; after_advice(@self)
      when 2; after_advice(@self, tp)  # not sure about the order of these last two
      when 3; after_advice(@self, tp, @before_tp)
      else; after_advice()
      end
    end
  end
end

set_trace_func proc{ |e, f, l, m, b, k|
  if $reaop
    #p e, f, l, m, b, k; puts "---" if $DEBUG
    tp = TracePoint.new(e, k, m, f, l, b)  
    TraceSet.active.each { |ts| ts.call(tp) if ts.check(tp) }
  end
}



# --- test ---

  class Test
    def initialize; @example = true; end
    def test; puts "  Okay!"; end
  end
  
  pc1 = PointCut.new(/^Test$/, /^test$/) {|binding|
    binding.self.instance_variable_get('@example') == true
  }

  def pc1.before_advice(obj, tp)
    puts "Calling #{tp.meth}..."
  end

  def pc1.after_advice(obj, tp)
    puts "Done."
  end

  # Note: I pulled out my hair trying to make wrap
  # advice work for this, rather then use before
  # and after advice. I had cleverly created
  # a super method for advice to catch the super
  # call, but even so there was nothing I could do
  # at that point to make it warp. Alas, I do not
  # think it is possible when using set_trace_func.
  #
  # def pc1.advice(tp)
  #   puts "Calling #{tp.meth}..."
  #   super
  #   puts "Done."
  # end
  
  pc1.start
  
  t = Test.new
  t.test
  t.test



=begin
  def ==(x)
    x =~ "#{@klass}##{@meth}"
  end
  
end

class Aspect
  
  CALL = 'call'
  INLINE = 'line'
  RETURN = 'return'
  CCALL = 'c-call'
  CRETURN = 'c-return'
  MODULE = 'class'
  ENDMOD = 'end'
  
  @@__pointcuts__ = []
  def self.pointcuts; @@__pointcuts__; end
  def self.weave(pcset); $aop=nil; @@__pointcuts__ |= pcset; $aop=true; end
  def self.unweave(pcset); $aop=nil; @@__pointcuts__ -= pcset; $aop=true; end

  def self.advice(advice_name, &adv)
    @__advice__ ||= {}
    @__advice__[advice_name] = adv
  end
  def self.advice_get(advice_name)
    @__advice__[advice_name]
  end
  
  def advice_set(jp, adv)
    jp.binding.self.define_singleton( jp.meth, &self.class.advice_get(adv) )
  end
  
  attr_reader :pointcut
  def initialize
    @pointcut = self.method(:pointcut).to_proc
  end
  def start; Aspect.weave([@pointcut]); end
  def stop; Aspect.unweave([@pointcut]); end

end

set_trace_func proc { |e, f, l, m, b, c|
  jp = TracePoint.new(c, m, e, b, f, l)
  Aspect.pointcuts.each { |pc| pc.call(jp) } if $aop
}

$d = true
  
  class MyAspect < Aspect
    def pointcut(jp)
      if jp == /Test#test/ && jp.event == Aspect::CALL
        advice_set(jp, :log) if $d
        #jp.binding.self.send(jp.meth)
        $d = false
      end
    end
    
    advice :log do |*args|
      puts "{"
      super if defined? super
      puts "}"
    end    
  end
=end
