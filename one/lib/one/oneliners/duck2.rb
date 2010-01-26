s="\e[2J\e[0;0H         _\nQuack! >(*)____,\n        (` =~~/\n^v^v^v^v^`---'v^v^v^v^\n";
i=0;loop{s[21,6]=i&1>0?'Quack!':' '*6;s.tr!(t='*.>v^<,"',t.reverse);$><<s;i+=sleep 1}
