# This one can take two parameter but block aren't nice about defaults :(
n||=32;l||="A";
#n.times{|y|print" "*(n-1-y);(y+1).times{|x|print~y&x>0?" .":" #{l[0.1]}"};puts}
n.times{|y|print" "*(n-1-y),(0..y).map{|x|~y&x>0?" .":" #{l}"},$/}
