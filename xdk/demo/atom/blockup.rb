require 'blow/atom'

# demo atom feed using block with parameter

sample1 = Blow::Atom::Feed.new do |s|
  s.author(:name => 'Tom', :email=>'trans@ggmail.nut')
  s.title "YEPPY!"
  s.entry do |e|
    e.author :name => "John Doe"
  end
  s.entry do |e|
    e.author :name => "Jank X"
  end
end

puts sample1.to_xml

