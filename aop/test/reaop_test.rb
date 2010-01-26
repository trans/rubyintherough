#
# Tests for reaop.rb
#

require 'test/unit'
require 'aop/reaop'


# pre-setup

  class Logging < AOP::Tracing::Aspect
      
    def pointcheck?(jp)
      jp.self.is_a?(Test) && jp.called == :test
    end
    
    def event_log(jp)
      case jp.event
      when 'call', 'c-call'
        log(jp.called)
        print "   "
      when 'return', 'c-return'
        log_done
      end
    end
    
    def log(meth)
      puts "Calling #{meth} at #{Time.now}..."
    end
    
    def log_done
      puts "Done."
    end
    
  end


  class T
    def initialize; @example = true; end
    def test; "Okay!"; end
  end


# test case

class TC_REAOP < Test::Unit::TestCase

  def test_run1
  
    assert_nothing_raised {
    
      te = Object.new
      
      def te.pointcheck?(tp)
        tp.klass.name == 'Test' &&
        tp.called == :test &&
        tp.self.instance_variable_get('@example') == true
      end
    
      def te.pointcut(tp)
        if tp.before?
          puts "Calling #{binding.called}..."
          print "   "
        elsif tp.after?
          puts "Done."
        end
      end
    
      AOP::Tracing.trace te
      
      AOP::Tracing.on
        
      t = T.new
      t.test
    
      AOP::Tracing.untrace te
      
      t.test
      
      AOP::Tracing.off
    
    }

  end
  
  
  def test_run2
  
    assert_nothing_raised {
          
      l = Logging.trace
      
      t = T.new
      t.test
    
    }

  end
  
end 

