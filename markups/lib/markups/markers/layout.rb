
require 'markups/marker'

module MarkUps::Markers

  #
  # Form Marker
  #
  class Layout < Marker

    priority 0.4

    def wiki( doc_lines, line_claim )
      current = false
      doc_lines.each_with_index do |line, lineno|
        if line =~ %r{^[ ]*\+[-=]+\+$}
          line_claim[lineno].tag self
          doc_lines[lineno] = %{<wiki:layout>\n#{line}}
          current = true
        elsif current and line !~ %r{^[ ]*[+\|]}
          line_claim[lineno].endtag self
          doc_lines[lineno] = %{#{line}\n</wiki:layout>}
          current = false
        end
      end
      if current
        line_claim[-1].endtag self
        doc_lines[-1] << %{\n</wiki:layout>}
      end
      return doc_lines, line_claim
    end

    def dewiki( content, attribute, info={} )
      lines = content.split("\n")
      lines = lines.collect{|l| l.strip }
      lines = lines.select{|l| ! l.empty? }
      tabsets = calc_tabsets( lines )
      tbl = breakdown( lines, tabsets )
      celled = cells( tbl, parser )
    end

    # conversions

    def to_xhtml( node, info={} )
      q = []
      q << %{<table#{node.attributes}>}
      node.each_element do |r|
        q << %{<tr>}
        r.each_element do |c|
          q << %{<td colspan="#{c.attributes['colspan']}" rowspan="#{c.attributes['rowspan']}">}
          q << parser.subconvert( c, :to_xhtml )
          q << %{</td>}
        end
        q << %{</tr>}
      end
      q << %{</table>}
      return q.join('')
    end
    alias_method :to_html, :to_xhtml

    private

      # determine tabsets and cascade '+' throughout
      def calc_tabsets( lines )
        divlines = []
        tab_sets = []
        lines.each_with_index do |line, i|
          if line.index(/^[+][+-=]*[+]$/) #or line.index(/^\+=/)
            divlines << i
            j = -1
            while j
              j = line.index('+',j+1)
              tab_sets << j if ! tab_sets.include?(j) if j
            end
          end
        end
        tab_sets.sort!
        divlines.each {|i| tab_sets.each {|t| lines[i][t..t] = '+'} }
        tab_sets
      end

      def tabsets_of(x, tl)
        o=0; tabs = []
        while o
          o = tl.index(x,o)
          tabs << o if o
          o+=1 if o
        end
        tabs
      end

      def breakdown( lines, tabsets )
        ltbl = []
        lines.each{|line|
          t = tabsets_of(/[+|]/, line)
          a = line.split(/[+|]/)
          a.shift  # remove leading empty space
          i = 0; na = []
          tabsets[1..-1].each{|ts|
            if t.include?(ts)
              na << a[i]
              i += 1
            else
              na << nil  # insert filler
            end
          }
          ltbl << na
        }
        ltbl
      end

      def cells( ltbl, parser )
        t=[]; s=[]; r=[], x=''
        if ltbl.empty?
          return '<form></form>'
        else
          #ltbl.first.length.times{ s << Cell.new }
          next_row = false
          ltbl.each_with_index do |row,j|
            row.each_with_index do |col,i|
              if col =~ /^[-=]+$/
                r[i] = s.uniq[i] if s.uniq[i]
                s[i] = Layout::Cell.new
                next_row = true
              elsif col
                g = s[i].content ? "#{s[i].content}\n" : ''
                s[i].content = g + col
                s[i].rowspan += 1 if next_row
              else #nil
                s[i] = s[i-1]
                s[i].colspan += 1
              end
            end
            if next_row
              t << r.uniq; r=[]
              next_row=false
            end
          end
          t.shift # proof that the above needs work

          # build the XML
          x = %{<layout>\n}
          t.each do |r|
            x << %{  <row>\n}
            r.each do |c|
              k = ''
              k << %{<col colspan="#{c.colspan}" rowspan="#{c.rowspan}">\n}
              k << %{#{c.content}\n}
              k << %{</col>}
              x << parser.subparse(k).to_s.tabto(4)  # SUBPARSE!
            end
            x << %{\n  </row>\n}
          end
          x << %{</layout>}
        end

        return x
      end

  end #class

  #
  # Layout Cell
  #
  class Layout::Cell

    attr_accessor :content, :colspan, :rowspan

    # not yet used
    # attr_accessor :alignment, :width

    def initialize
      @colspan = 1
      @rowspan = 1
    end

  end #class Cell

end #module MarkUps::Markers

