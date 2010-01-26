require 'blow/atom'

# create an atom fragment with variant namespaces

frag = Blow::Atom::Entry.new('entry', 'xmlns:apps'=>"http://schemas.google.com/apps/2006") do
  category "scheme"=>"http://schemas.google.com/g/2005#kind" do
    send("apps:login",  :userName=>"SusanJones-1321", :password=>"123$$abc", :suspended=>"false")
    send("apps:quota",  :limit=>"2048")
    send("apps:name", :familyName=>"Jones", :givenName=>"Susan")
  end
end

puts frag.to_xml

