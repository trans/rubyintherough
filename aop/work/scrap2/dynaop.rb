# Aspect Oriented Programming for Ruby
# Copyright (c)2004 Thomas Sawyer, All Right Reserved
# dynaop.rb
#
# Notes:
#   Currently this has no effect on singleton methods. Should it?
#   Nor does it backtrack wraps either, so concerns must be defined first.
#   Also

require 'succ/binding'


### ##  #####  ####   ##  #  ##    #####
## # #  ##  #  ##  #  ##  #  ##    ###
##   #  ##  #  ##  #  ##  #  ##    ##
##   #  #####  ####   #####  ##### #####
=begin
 
= Wraps
 
This is the service module that store reference to
wrapping concerns. Wrap dispatching occurs via the
modified Module class below.

=end
module Wraps
module_function

  @@active = []
  def active; @@active; end
  
  def join(e)
    if e.respond_to?(:wraps_call) && e.respond_to?(:wraps_check?)
      @@active << e
    else
      warn "Object lacking wrap interface, ignored."
    end
  end
  def unjoin(e); @@active.delete(e); end
  def <<(e); join(e); end
  def >>(e); unjoin(e); end
  
  def on
    if block_given?
      on
      begin; yield; ensure; off; end
    else
      @@on = true
    end
  end
  
  def off
    @@on = false
  end
  
  def on?; @@on ; end
  def off?; ! @@on ; end
  
end


### ##  #####  ####   ##  #  ##    #####
## # #  ##  #  ##  #  ##  #  ##    ###
##   #  ##  #  ##  #  ##  #  ##    ##
##   #  #####  ####   #####  ##### #####
=begin
 
= CutInclude and CutExtend
 
Methods that cuts need to work better.

=end
module CutInclude
  alias_method :real_class, :class
  def class; real_class.base_class; end
end

module CutExtend
  def base_class; @base_class; end
  def base_class=(c); @base_class=c; end
end


 ####  ##     ###   #####  #####
##     ##    ##  #  ###    ###
##     ##    #####    ###    ###
 ####  ##### ##  #  #####  #####
=begin
 
= Module
 
Add cut subclasses to classes to achieve wrapping.
This would be a lot better if transparent subclasses
were supported natively by Ruby.

=end
class Module
  def cuts ; @__cuts__ ||= [] ; end
  
  def method_added(meth)
    return if ! Wraps.on
    Wraps.active.each{|w|
      if w.wraps_check?(self,meth)
        c = next_cut(meth)
        # create the wrap method
        wrap_advice = w.method(w.wraps_call(self,meth))
        if wrap_advice
          c.class_eval do
            define_method(meth) do |*args|
              r=nil
              target=binding()
              target.call = proc{ |*args| r=super(*args) }  #proc{ |*args,&blk| r=super(*args,&blk) }
              wrap_advice.call(target,*args) #&blk)
              r #r if passive?(meth)
            end
          end
        end
      end
    }
  end
  
  private
  
  # next usable cut, or create if need be
  def next_cut(meth)
    @__cuts__ ||= []
    c = @__cuts__.detect{ |c| ! c.instance_methods.include?(meth) }
    if ! c
      x = (@__cuts__.empty? ? self : self.cuts.last)
      c = Class.new(x) { extend CutExtend; include CutInclude }
      c.base_class = self
      @__cuts__ << c
    end
    c
  end
  
end


 ####  ##     ###   #####  #####
##     ##    ##  #  ###    ###
##     ##    #####    ###    ###
 ####  ##### ##  #  #####  #####
=begin

= Class
 
This goes hand in hand with the above. It acts
as a factory for the cuts.

=end
class Class
  alias cutless_new new
  def new(*args, &blk)
    if self.cuts.empty?
      self.cutless_new(*args, &blk)
    else
      self.cuts.last.cutless_new(*args, &blk)
    end
  end
end




# --- test ---

  ce = Object.new
  
  def ce.wraps_check?(klass,meth)
    klass.name == 'Test' &&
    meth == :test
  end

  def ce.wraps_call(klass,meth)
    :wrapup
  end
  
  def wrapup(target, *args, &blk)
    puts "Calling #{target.called}..."
    target.call(*args, &blk)
    puts "Done."
  end
  
  Wraps.on
  
  Wraps << ce
  
  
  class Test
    def initialize; @example = true; end
    def test; puts "  Okay!"; 4; end
  end
    
  t = Test.new
  p t.test
  p t.class
