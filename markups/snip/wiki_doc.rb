
require 'mega/stateparser'

class WikiMachine < StateMachine

  attr_reader :build

  def initialize
    @build = []
    @sections = []
    @lists = []
  end

  def flush(t,s)
    build << t
  end

  def finish( s )
    build << "\n"
    end_section(0)
  end

  def to_s
    build.join('')
  end

  # tokens

  token :section do
    def match( s )
      %r{^([ ]*)([=]+)(.*?)$}
    end
    def callback( m, s )
      indent, level, name = m[1], m[2].size, m[3].strip
      end_section(level)
      build << %{#{indent}<section name="#{name}" level="#{level}">}
      @sections << { :level=>level, :indent=>indent, :name=>name }
    end
    # not a callback
    def end_section( level )
      while !@sections.empty? && @sections.last[:level] >= level
        sec = @sections.pop
        build << %{#{sec[:indent]}</section>\n}
      end
    end
  end

  token :list do
    def match( s )
      if i = @lists.last
        /^([ ]{#{i+1}})([*#])/
      else
        /^([ ]*)([*#])/
      end
    end
    def end_match( m, s )
      i = m[1].size
      %r{(?=(^[ ]{0,#{i}}[^\s*#]|^[ ]*$|\Z))}
    end
    def callback(m,s)
      indent, type = m[1], m[2] #, m[3].strip
      build << %{#{indent}<wiki:list type="#{type}">\n} #<< %{#{indent}#{m[2]}}
      s.offset -= indent.size + 1
      @lists << indent.size
    end
    def end_callback(m,s)
      indent = "  " #, type = m[1], m[2] #, m[3].strip
      build << %{\n#{' '*@lists.last}</wiki:list>\n}
      @lists.pop
    end
  end

  token :layout do
    def match( s )
      if @inlayout
        %r{\Z} # can't be matched
      else
        %r{^([ ]*)([+][-=]+[-=+]*[+])$}
      end
    end
    def end_match( m, s )
      i = m[1].size
      %r{^[ ]*$|^[ ]{#{i}}[^+|]|^[ ]{0,#{i-1}\S}[^+|]|\Z}
    end
    def callback(m,s)
      indent = m[1]
      build << %{#{indent}<wiki:layout>\n}
      build << m[0]
      @inlayout = indent
    end
    def end_callback(m,s)
      build << %{\n#{@inlayout}</wiki:layout>\n}
      @inlayout = nil
    end
  end

  token :yaml do
    def match( s )
      %r{^([ ]*)---}
    end
    def end_match( m, s )
      %r{^(#{m[1]})\.\.\.}
    end
    def callback(m,s)
      indent = m[1]
      build << %{#{indent}<wiki:yaml>\n}
      build << m[0]
    end
    def end_callback(m,s)
      indent = m[1]
      build << "\n" << m[0] << "\n"
      build << %{#{indent}</wiki:yaml>\n}
    end
  end

  token :emphesis do
    def match( s )
      /[ ]_(\S+)_([ .!?])/
    end
    def callback( m, s )
      build << " <em>#{m[1]}</em>#{m[2]}"
    end
  end

  token :strong do
    def match( s )
      /[ ][*](\S+)[*]([ .!?])/
    end
    def callback( m, s )
      build << " <strong>#{m[1]}</strong>#{m[2]}"
    end
  end

end

s=%{
= Title

I need to give this some _deep_ testing with a lot
more words and all that to see how fast its gogin to be.
And if I will just have to byte the big cow
and write a pure "one giant" regexp tanslator parser.
I bet there are way to spped this up a good bit --there's
boung to be way to help short-curcuit the parser routine.
But that gets *tricky*.

== Section 1

This is a good bye.

  * A
  * B
  * C

  +---------+
  |   BOX   |
  +---------+

== Section 2

I need to give this some deep thesting with a lot
more words and all that to see how fast its gogin to be.
And if I will just have to byte the big cow
and write a pure "one giant" regexp tanslator parser.
I bet there are way to spped this up a good bit --there's
bout to be way to help short curcuit the parser routine.
But that gets' tricky.

== Section 3

This is good-bye.

  * 1
  * 2
  * 3

  ---
  a: 1
  b: 2
  c: - a
     - b
  ...
}

sp = StateParser.new(wm = WikiMachine.new)
pt = sp.parse(s)

puts wm
