a=[];10.times{|n|a<<1;puts" "*(9-n)*3+"%6d"*-~n%a;n.times{|i|a[n]+=a[n-=1]}}
