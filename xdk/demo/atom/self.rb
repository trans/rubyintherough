require 'blow/atom'

# generate atom feed using block w/o parameter

sample2 = Blow::Atom::Feed.new do
  author :name => "Tom", :email=>"trans@ggmail.nut"
  title "YEPPY!"
  entry do
    author :name => "John Doe"
  end
  entry do
    author :name => "Jank X"
  end
end

puts sample2.to_xml

