
class String
  def <(x)
    puts "STING!!!! #{x}"
  end
end

module Blow

  class XmlInRuby

    def _build(&block)
      instance_eval(&block)
    end

    def _()
      self
    end

    def <<(x)
      @construct ||= []
      @construct << x
      self
    end

    def <(cont)
      self << "<"
      self << "#{cont}" unless cont.to_s.empty?
      self
    end

    def >(cont)
      self << ">"
      self << "#{cont}" unless cont.to_s.empty?
      self
    end

    def /(cont)
      "/#{cont}"
      #self << "/"
      #self << "#{cont}" unless cont.to_s.empty?
      #self
    end

    def to_s
      ''
    end

    private

    def method_missing(sym, *args)
      sym
    end

  end

end


if $0 == __FILE__

  xr = Blow::XmlInRuby.new

  x = xr._build do
    _ <feed>
        "Hi There" <_ / feed>
    _
  end

  p x
end
