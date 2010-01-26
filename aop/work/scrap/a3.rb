
class Object

  def send_before(name, *a, &b)
    advice = self.class.ancestors.collect{|anc| anc.before_advice(name)}.flatten
    advice.each do |m| send(m, *a, &b)  end
  end

  def send_after(name, *a, &b)
    advice = self.class.ancestors.collect{|anc| anc.after_advice(name)}.reverse.flatten
    advice.each do |m| send(m, *a, &b)  end
  end

  def send_pre(name, *a, &b)
    advice = self.class.pre_advice(name)
    advice.each do |m| send(m, *a, &b)  end
  end

  def send_post(name, *a, &b)
    advice = self.class.post_advice(name).reverse
    advice.each do |m| send(m, *a, &b)  end
  end

end


class Module
  def method_added(name)
    return if @_adding_method or name == :method_added
    @_adding_method = true
    alias_method "#{name}:main", name
    module_eval %{
      def #{name}(*a, &b)
        send_before("#{name}", *a, &b)
        send_pre("#{name}", *a, &b)
        r = send("#{name}:main",*a, &b)
        send_post("#{name}", *a, &b)
        send_after("#{name}", *a, &b)
        r
      end
    }
    @_adding_method = false
  end

  @_adding_method = true

  def before( name, advice )
    @before_advice ||= {}
    @before_advice[name.to_sym] ||= []
    @before_advice[name.to_sym].unshift advice
  end

  def before_advice(name)
    @before_advice ||= {}
    @before_advice[name.to_sym] || []
  end

  def after( name, advice=nil )
    @after_advice ||= {}
    @after_advice[name.to_sym] ||= []
    @after_advice[name.to_sym] << advice
  end

  def after_advice(name)
    @after_advice ||= {}
    @after_advice[name.to_sym] || []
  end

  def pre( name, advice )
    @pre_advice ||= {}
    @pre_advice[name.to_sym] ||= []
    @pre_advice[name.to_sym].unshift advice
  end

  def pre_advice(name)
    @pre_advice ||= {}
    @pre_advice[name.to_sym] || []
  end

  def post( name, advice )
    @post_advice ||= {}
    @post_advice[name.to_sym] ||= []
    @post_advice[name.to_sym].unshift advice
  end

  def post_advice(name)
    @post_advice ||= {}
    @post_advice[name.to_sym] || []
  end

end



# example

class X
  def y; puts "y"; end

  before :y, :z1
  after :y, :z1

  before :y, :z2
  after :y, :z2

  pre :z1, :x0

  def z1
    puts "HELLO"
  end

  def z2
    puts "DOH"
  end

  def x0
    puts "C"
  end

end


class Z < X

  before :y, :q
  after :y, :q

  def y; puts super + "!"; end

  def q; puts "Q"; end
end

Z.new.y
