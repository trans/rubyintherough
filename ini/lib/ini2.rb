class INI

  attr :sections

  def initialize(*args)
    options  = Hash===args.last ? args.pop : {}
    filename = args.first

    parse
  end

  class Section
    attr :name
    attr :comment
    atrt :items
  end

  class Item
    attr :key
    attr :value

    attr :comment
    attr :side_comment

    alias_method :name, :key

    def initialize(key,value)
      @key = key
      @value = value
    end
  end

end

