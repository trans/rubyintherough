
# Reverse analysis of event-based AOP converting to 
# wrap-based AOP ?

def crosspoint( jp )

end

What if every TracePoint translated into a prolog entry?

  def log( meth )
    puts "Advising #{meth}!"
  end

  log(meth) -: $TP.meth & $TP.meth.to_s =~ /t^/
  
  