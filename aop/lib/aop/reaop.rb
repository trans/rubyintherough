# Ruby Event-based Aspect Oriented Programming
# Copyright (c)2004 Thomas Sawyer, All Rights Reserved
# reaop.rb

require 'singleton'
#require 'facet/array/==='    # b/c it provides better === method
require 'facet/binding'      # improved binding class
require 'aop/back'           # more to binding class
require 'facet/tracepoint'   # the all important tracepoint

# To handle klass false#name in set_trace_func
class False
  def name; "FalseClass"; end
end

module AOP

  ### ##  #####  ####   ##  #  ##    #####
  ## # #  ##  #  ##  #  ##  #  ##    ###
  ##   #  ##  #  ##  #  ##  #  ##    ##
  ##   #  #####  ####   #####  ##### #####

  # = Tracing
  #
  # This is the service module at the heart of EAOP.
  # It controls all the dispatching via the set_trac_func.
  #
  module Tracing

    class << self

      @@active = []
      def active; @@active; end
      
      def trace(aspect)
        if aspect.respond_to?(:pointcut) #&& e.respond_to?(:pointcheck?)
          @@active << aspect
        else
          warn "Object lacking event interface, ignored."
        end
        aspect
      end
      def untrace(aspect)
        @@active.delete(aspect)
        aspect
      end
      
      @@bb_stack = []
      
      def on
        if block_given?
          on
          begin
            yield
          ensure
            off
          end
        else
          @@on = true
          TracePoint.trace{ |tp|
            @@active.each{ |a|
              a.pointcut(tp) if (a.respond_to?(:pointcheck?) ? a.pointcheck?(tp) : true)
            }
          }        
        end
      end
      
      def off
        set_trace_func nil
        @@on = false
      end
      
      def on?; @@on ; end
      def off?; ! @@on ; end
    
    end  # class << self
  
  
  
     ####  ##     ###   #####  #####
    ##     ##    ##  #  ###    ###
    ##     ##    #####    ###    ###
     ####  ##### ##  #  #####  #####
  
    # = Aspect
    #
    # The EAOP Cross-Concern.
    #
    # Idea: Consider how to initialize based on event ?
    class Aspect
      include Singleton
      class << self
        def trace(*args,&blk); Tracing.trace(self.instance(*args,&blk)); end
        def untrace; Tracing.untrace(self.instance); end
      end
      
      # Master control. If this returns false the crosscut
      # method will not be run. This can help efficiency.
      def pointcheck?(tp); true; end
      
      # You can override this method, if you want. As is,
      # it calls every method of the form event_*.
      def pointcut(tp)
        m = methods.select{ |m| /^event_/ =~ m.to_s }
        m.each{ |m| send(m,tp) }
      end
    
    end

  end  # Tracing

end  # AOP
