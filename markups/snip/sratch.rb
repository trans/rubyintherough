
class Match
  def self.[](r)
    self.new(r)
  end
  def initialize(r)
    @re = r
  end
  def re( a=nil )
    r = (a ? (@re % a) : @re)
    Regexp.new(r)
  end
  def match()

  end
end

class NoMatch
  def self.[](r)
    self.new(r)
  end
  def initialize(r)
    @re = r
  end
  def re( a=nil )
    r = (a ? (@re % a) : @re)
    Regexp.new(r)
  end
  def match()

  end
end


class WikiParser

  attr_reader :stack

  def initialize
    @stack = []
    @sections = []
  end

  def parse_table
    {
      match("^([ ]*)([=]+)(.*?)$") => lambda{ |s| section(s) },
      match("^([ ]*)([#*])(.*?)$") => {
        match{ |m| ln=m[1].size ; "^[ ]{0,#{ln}}\S" }  => lambda{ |s| outline(s) }
      }
    }
  end


  # section

  def section( m )
    indent, level, name = m[1], m[2].size, m[3].strip
    end_section(level)
    @stack << %{#{indent}<section name="#{name}" level="#{level}">}
    @sections << { :level=>level, :indent=>indent, :name=>name }
  end

  def end_section( level )
    while !@sections.empty? && @sections.last[:level] >= level
      sec = @sections.pop
      @stack << %{#{sec[:indent]}</section>\n}
    end
  end

  # parse

  def parse( str, offset=0, match=[], pmap=parse_table )
    o = offset
    i = nil
    h = str.length
    k = nil
    m = nil
    pmap.each { |r,q|
      if r
        rg = r.re(match) # strange! this must be used
        i = str.index( rg, o )
        if i and i < h
          h = i
          k = q
          m = $~
        end
      end
    }

    if i
      mb = m.begin(0)
      @stack << str[o...mb]
      if Proc === k
        k.call( m )
        parse( str, m.end(0), m[1..-1], pmap )
      else
        parse( str, m.end(0), m[1..-1], k )
      end
    else
      @stack << str[o..-1]
      finish_up
    end
  end

  def finish_up
    end_section(0)
  end

end


s = %{
  = HELLO
  This is a text.
  = GOODBYE
  And some more text.
}

wprs = WikiParser.new
wprs.parse( s )

puts wprs.stack.join("")
