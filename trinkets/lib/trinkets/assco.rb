
class AObject

  def associate
    @associate ||= Hash.new do |h,k| h[k] = [] end
  end

  def assc( key, obj=nil )
    if obj
      associate[key.to_sym] << obj
    else
      associate[key.to_sym]
    end
  end

  def method_missing( key, obj=nil )
    if key.to_s =~ /=$/
      associate[key.to_s.chomp('=').to_sym] = [obj]
    else
      associate[key][0]
    end
  end

end



class Person < AObject

  def initialize( name )
    assc :name, name
  end

end

class Address < AObject
  def initialize
    yield self
  end
end


tom = Person.new('Tom Sawyer')

p tom.name

tom.assc :home, AObject.new

tom.home.assc :address, Address.new { |a|
  a.assc :street , '1513 Payette Ln.'
  a.assc :city   , 'West Melourne'
  a.assc :state  , 'Florida'
  a.assc :country, 'USA'
  a.assc :zipcode, '32905'
}

p tom.home
p tom.home.address
p tom.home.address.street

