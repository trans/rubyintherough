q,w='Quack! >','~^'*11;t="\e[2J\e[0;0H         _\n%8s(')____,\n        (` =^^/\n%20s\n";
i=0;loop{s=t%[i&1>0?q:'<',w[i%2,20]];$><<s;i+=sleep 1}
