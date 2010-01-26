"bp6siZmijp5CiZlCiW5CgAAChpbiiZYiiZZCi5aCZ2bs".unpack("m")[0].unpack("C*").map{|x|
x.chr}.join.unpack("B*")[0].scan(/.{24}/){i=7;$&.scan(/..../){
print"\e[3#{i-=1};1;40m  ";$&.each_byte{|z|print" #"[z-?0,1]*2}};puts"\e[0m"}
