

  class C
    def m1
      "x"
    end  
  end
  
  # aspect A
  module A
  
    # essetially the pointcut
    def joining_method(sym, *args)
      bk(sym, *args)
    end
    
    def bk(targ, *args)
      '{' + send(targ, *args) + '}'
    end
  
  end
  
  
  cut AofC < C
    include A
  end
  
  
  multicut C,D,E with A
  