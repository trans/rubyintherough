

module XML

  RE_BAR2CDATE = / \< (\/)? ([\w_.:]+) (.*?) \> ([ ]* \|)? /mix

  class MatchDataX
    attr_accessor :matchdata
    attr_accessor :mark
    attr_accessor :setpos
    def initialize( md, mark, setpos )
      @matchdata = md
      @mark = mark
      @setpos = setpos
    end
    def [](x)
      @matchdata[x]
    end
    def begin
      @matchdata.begin(0) + @setpos
    end
    def end
      @matchdata.end(0) + @setpos
    end
  end

  module_function

  def bar2cdata( txt )

    q = txt
    tag_list = []
    setpos = 0
    while md = RE_BAR2CDATE.match( q )
      mark = md[1] ? :close : :open
      tag_list << MatchDataX.new( md, mark, setpos )
      q = md.post_match
      setpos += md.end(0)
    end

    markers = []
    stack = []
    tag_list.each do |mdx|
      if mdx.mark == :open
        stack << mdx
      else  # closed
        begin osl = stack.pop end until osl[2] == mdx[2]
        if osl[4]
          markers << ( osl.end ... mdx.begin )
        end
      end
    end

    inner_markers = []
    markers.each { |m|
      im = markers.select { |ms| ms.begin > m.begin && ms.end < m.end }
      inner_markers.concat( im )
    }
    markers = markers - inner_markers

    ntxt = []
    s = 0
    markers.each { |m|
      ntxt << txt[s...m.begin-1]
      ntxt << "<![CDATA["
      ntxt << txt[m.begin...m.end]
      ntxt << "]]>"
      s = m.end
    }
    ntxt << txt[s..-1]

    return ntxt.join('')
  end

end


# test

if $0 == __FILE__

  q = %Q{
    <test>|
      +---------+
      |  Fixes  |
      +---------+
    </test>
    <test>|
      This is 
      fixed too.
    </test>
    <test>|
      This is the final test:
      <test>|
        Can it work?
      </test>
    </test>
  }

  r = XML.bar2cdata( q )
  puts r

end
