# <author>
#   <name>name</name>
#   <email>email</email>
#   <uri>uri</uri>
# </author>

class Hash
  def join(sep1, sep2)
    to_a.collect{ |e| e.join(sep1) }.join(sep2)
  end
end


class Xml
  attr :store

  def initialize
    @store = []
  end

  def <(name)
    @store << [:start, name]
    self
  end

  def >(cont)
    return self unless cont
    return self if cont.empty?
    @store << cont
    self
  end

  def <=(name)
    @store << [:end, name]
    self
  end

  def >=(h)
    @store.last << h
    self
  end

  def to_s
    s = ''
    @store.each do |n|
      case n
      when Array
        type, tag, atts = *n
        if type == :start
          if atts
            attstr = atts.collect{ |k,v| %[#{k}="#{v}"] }.join(' ')
            s << "<#{tag} #{attstr}>"
          else
            s << "<#{tag}>"
          end
        else
          s << "</#{tag}>"
        end
      else
        s << n
      end
    end
    s
  end

end

xml = Xml.new

name  = "Tom"
email = "transfire@gmai.com"
uri   = "http://facets.rubyforge.org"
id = 1

xml <"author">= {:id=>"1", :type=>"programmer"} \
      <"name">   name   <="name"> '' \
      <"email">  email  <="email"> '' \
      <"uri">    uri    <="uri"> '' \
    <="author" > ''

p xml.to_s

# x = %[
#   <author id=#{id} type="programmer">
#     <name>#{name}</name>
#     <email>#{email}</email>
#     <uri>#{uri}</uri>
#   </author>
# ]
#
# puts x
