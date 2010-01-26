# Aspect Oriented Programming for Ruby
# Copyright (c) 2004 Thomas Sawyer & Peter, All Right Reserved
#
# = Notes
#
# Currently this has no effect on singleton methods. Should it?
# Nor does it backtrack wraps either, so concerns must be defined first.
# Although, the code is mostly in place for doing so, I think.
#

require 'singleton'

#require 'abc/core/binding/all'
require 'raspberry/atom/binding'

#require 'abc/core/kernel'
require 'raspberry/atom/kernel'

require 'aop/cut'
require 'aop/back'


 ####  ##     ###   #####  #####
##     ##    ##  #  ###    ###
##     ##    #####    ###    ###
 ####  ##### ##  #  #####  #####

# = WeavePoint
# The join-point of dyanamic AOP
# This is left out of the AOP name space as it may
# be usefuil in a larger context --like TracePoint. 
class WeavePoint
  
  attr_reader :klass, :meth

  def initialize(klass, meth)
    @klass = klass
    @meth = meth
  end
  
  def ===(pattern)
    name = @klass.to_s + '.' + @meth.to_s
    pattern["."] = "\\."
    pattern["*"] = ".*"
    Regexp.old_new(pattern).match(name) != nil
  end
  
  def this(klass)
    @klass == klass
  end
  
end


### ##  #####  ####   ##  #  ##    #####
## # #  ##  #  ##  #  ##  #  ##    ###
##   #  ##  #  ##  #  ##  #  ##    ##
##   #  #####  ####   #####  ##### #####
  
# = AOP
# AOP Namespace
module AOP

  ### ##  #####  ####   ##  #  ##    #####
  ## # #  ##  #  ##  #  ##  #  ##    ###
  ##   #  ##  #  ##  #  ##  #  ##    ##
  ##   #  #####  ####   #####  ##### #####
  
  # = Weaving
  # This is the service module that stores reference to weaving concerns.
  # Note: not all of these funcions have been tested.
  module Weaving
  
    class << self
      
      # This stores a list of all applied advice
      # in the form of [aspect, class, method ] => cut.
      # Ironically the advice name itself is not needed.
      ADVICE_TABLE = {}
      
      # Should weaving have a master on and off switch?
      # @@on = true
      # def on; @@on = true; end
      # def off; @@on = false; end
      # def on?; @@on ; end
      # def off?; ! @@on ; end
    
      #
      @@active = []
      def active; @@active; end
      def weave(aspect)
        if valid_aspect?(aspect)
          @@active << aspect
        else
          warn "Aspect lacking proper interface, ignored."
        end
        aspect
      end
      def unweave(aspect)
        @@active.delete(aspect)
        self.back_unapply(aspect)
        aspect
      end
  
      # makes sure aspect has required methods
      def valid_aspect?(aspect)
        aspect.class.instance_methods.include?("crosscut") && 
        aspect.class.instance_methods.include?("crosscheck?")
      end
          
      # returns applicable advice method name
      def advice_applicable(aspect, klass, meth)
        wp = WeavePoint.new(klass,meth)
        aspect.crosscut(wp) if aspect.crosscheck?(wp)
      end
      
      # apply an aspect to a given class#method
      def apply(aspect, klass, meth)
        return if ADVICE_TABLE.has_key?( [aspect,klass,meth] )
        advice = advice_applicable(aspect, klass, meth)
        if advice
          c = klass.clearcut(meth)
          c = Cut.new(klass) if ! c
          c.class_eval{
            define_method(meth) do |*args| #, instance_method(advice))
              # return super if Weaving.off?
              r=nil
              target=binding()  # this is overkill, will change (hmm.. if we could get super's binding...)
              target.call = proc{ |*args| r=super(*args) }  #proc{ |*args,&blk| r=super(*args,&blk) }
              aspect.send(advice, target, *args) #&blk)
              r if aspect.class.passive?(advice)
            end
          }
          ADVICE_TABLE[ [aspect, klass, meth] ] = c
        end
      end
      
      # unapply an advice
      def unapply(aspect, klass, meth)
        if c = ADVICE_TABLE[ [aspect, klass, meth] ]
          c.class_eval{ undef_method(meth) }
        end
      end
      
      # apply all aspects for a given class#method
      def apply_all(klass, meth)
        Weaving.active.each{|aspect|
          self.apply(aspect, klass, meth)
        }
      end
      
      # unapply all aspects for a given class#method
      def unapply_all(klass, meth)
        Weaving.active.each{|aspect|
          self.unapply(aspect, klass, meth)
        }
      end
      
      # goes back and aspects pre-existing classes/methods
      def back_apply(aspect)
        ObjectSpace.each_object(Class){|klass|
          klass.instance_methods.each{|meth|
            self.apply(aspect, klass, meth)
          }
        }
      end
  
      # goes back and unaspects pre-existing classes/methods
      def back_unapply(aspect)
        ObjectSpace.each_object(Class){|klass|
          c.instance_methods.each{|meth|
            self.unapply_all(aspect,klass,meth)
          }
        }
      end
  
    end #class << self
  
  
     ####  ##     ###   #####  #####
    ##     ##    ##  #  ###    ###
    ##     ##    #####    ###    ###
     ####  ##### ##  #  #####  #####
    
    # = Aspect
    # Singleton class to be used as the base class
    # for building new Weaving::Aspects.
    class Aspect
      include Singleton     
      class << self
        @@__passive__ = []
        def passive(*meths); @@__passive__ |= meths; end
        def passive_methods; @@__passive__; end
        def passive?(meth); @@__passive__.include?(meth); end
        def weave(*args, &blk); Weaving.weave(self.instance(*args, &blk)) ; end
        def unweave; Weaving.unweave(self.instance) ; end
        # This didn't fly for some reason
        #def inherited(subclass)
        #   Weaving.weave(subclass)
        #end
      end
    
      # Master control. If this returns false the crosscut
      # method will not be run. This can help efficiency.
      def crosscheck?(wp); true; end
      
      # Override this method. Should return method name 
      # of advice to call based on weavepoint conditions.
      def crosscut(wp)
        # override this
      end
      
    end #Aspect
    
  end #Weaving

end #AOP


 ####  ##     ###   #####  #####
##     ##    ##  #  ###    ###
##     ##    #####    ###    ###
 ####  ##### ##  #  #####  #####

# = Module
# Add cuts to classes to achieve weaving.
class Module
  def method_added(meth)
    #$stderr << self, meth if $DEBUG
    AOP::Weaving.apply_all(self,meth)
  end
end
