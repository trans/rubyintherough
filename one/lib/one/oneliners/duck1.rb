s="\033[2J\033[0;0H          _\n Quack! >(')____,\n         (` =~~/\n~^~^~^~^~^`---'~^~^~^~^";
(1..(1/0.0)).each{|i|s[23,6]=(i%2)==0?"Quack!":" "*6;s.tr!('>~^^~<','<^~~^>');puts s;sleep 1}
