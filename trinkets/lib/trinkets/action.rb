
class ActionPath < Array
  attr :s
  attr :a

  def initialize(s, a)
    @s = s
    @a = a
  end

  def inspect
    tail = self.join('.')
    tail = '.' + tail unless tail.empty?

    if @a.empty?
      "#{@s}#{tail}"
    else
      "#{@s}#{@a.inspect}#{tail}"
    end
  end

  def ==(other)
    object_id == other.object_id
  end

  def method_missing(s, *a)
    self << [s, *a]
    self
  end
end


class ActionPlan

  attr :actions

  def initialize
    @actions = [] #ActionPath.new
  end

  def try
    clobber.package
    icli rubyforge release version 2.03
    jump ab xy
  end

  def plan
    removal = []
    @actions.reverse.each do |action|
      action.a.each do |inner|
        remove(inner, removal)
      end
    end
    clean = []
    @actions.each do |action|
      clean << action unless removal.include?(action)
    end
    clean
  end

  def remove(inner, removal)
    if ActionPath === inner
      if inner.empty?
        removal << inner
      else
        inner.a.each do |i|
          remove(i, removal)
        end
      end
    end
  end

  def method_missing(s, *a, &b)
    #@actions.unshift [s, *a]
    ap = ActionPath.new(s, a)
    @actions << ap
    ap
  end

end


act = ActionPlan.new

act.try

p act.plan

#p act.actions
