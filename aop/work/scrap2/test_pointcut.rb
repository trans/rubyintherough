   require 'succ'
   
   #class SuperProc < Proc; end
   
   class A
     def m1(x); print "#{x}"; end
   end
   
   class B < A
     pointcut(:m1 => :n)
     def n(*args)
       print '{'
       super
       print '}'
     end
   end 

   b = B.new
   b.m1('B'); puts
   
   p b.pointcut