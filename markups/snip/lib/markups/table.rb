require 'yaml'

module MarkUps

  YAML.add_private_type('table') { |tag, data|
    Table.new(data)
  }

  class Table

    def initialize( options={} )
      @picture   = options['picture']
      raise ArgumentError unless @picture
      @attribute = options['attribute']
      @style     = options['style']
      #@content   = options['content']
      #parse
    end

    # Convert the text-based template into an object model.

    def parse( name, klass, content ) #( content ) #, attribute, info={} )
      @name    = name  #options['name']
      @class   = klass #options['class']
      @content = content
      @model = parse_table( @picture )
    end

    # Convert to XML.

    def to_xml( &subparse )
      t = @model
      x = ''
      x << make_tag( 'table', :id=>@name, :class=>@class )
      x << "\n"
      t.each do |r|
        x << %{  <row>\n}
        r.each do |c|
          x << make_tag( 'col', :id=>c.id, :class=>c.class, :colspan=>c.colspan, :rowspan=>c.rowspan ) {
            make_cell_body( c, &subparse )
          }
          x << "\n"
        end
        x << %{\n  </row>\n}
      end
      x << %{</table>}
      return x
    end

    # Convert to HTML.

    def to_html( &subparse )
      t = @model
      x = ''
      x << make_tag( 'table', :id=>@name, :class=>@class )
      x << "\n"
      t.each do |r|
        x << %{  <tr>\n}
        r.each do |c|
          x << make_tag( 'td', :id=>c.id, :class=>c.class, :colspan=>c.colspan, :rowspan=>c.rowspan ) {
            make_cell_body( c, &subparse )
          }
          x << "\n"
        end
        x << %{  </tr>\n}
      end
      x << %{</table>}
      return x
    end
    alias_method :to_xhtml, :to_html

  private

    def make_tag( name, attrs={}, &body )
      id = attrs.delete(:id) || attrs.delete('id')
      klass = attrs.delete(:class) || attrs.delete('class')
      tag = [name]
      tag << %{id="#{id}"} if id
      tag << %{class="#{klass}"} if klass
      attrs.each{ |k,v| tag << %{#{k}="#{v}"} }
      tag = '<' + tag.join(' ') + '>'
      if body
        body = body.call
        tag << "\n#{body}\n" if body and body != ''
      end
      tag << "</#{name}>"
      tag
    end

    def make_cell_body( cell, &subparse )
      body = ''
      body << cell.content if cell.content
      if cssref = @content[cell.id]
        body << cssref.to_s
      end
      body = nil if body.strip == ''
      body = subparse[body] if subparse
      body
    end

#     # from rexml
#
#     def to_xhtml #( node ) #, info={} )
#       node = @model
#       q = []
#       q << %{<table#{node.attributes}>}
#       node.each_element do |r|
#         q << %{<tr>}
#         r.each_element do |c|
#           q << %{<td colspan="#{c.attributes['colspan']}" rowspan="#{c.attributes['rowspan']}">}
#           q << parser.subconvert( c, :to_xhtml )
#           q << %{</td>}
#         end
#         q << %{</tr>}
#       end
#       q << %{</table>}
#       return q.join('')
#     end

    private

      def parse_table(ascii)
        lines = ascii.split("\n")
        lines = lines.collect{|l| l.strip }
        lines = lines.select{|l| ! l.empty? }
        tabss = calc_tabsets( lines )
        table = breakdown( lines, tabss )
        cells( table ) #, parser )
      end

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

      def cells( ltbl ) #, parser )
        t=[]; s=[]; r=[], x=''
        if ltbl.empty?
          return '<template></template>'
        else
          #ltbl.first.length.times{ s << Cell.new }
          next_row = false
          ltbl.each_with_index do |row,j|
            row.each_with_index do |col,i|
              if col =~ /^[-=]+$/
                r[i] = s.uniq[i] if s.uniq[i]
                s[i] = Cell.new(col,row)
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
        end
        return t
      end

  end #class

  #
  # Table Cell
  #

  class Table::Cell
    alias :object_class :class

    attr_reader :col, :row
    attr_reader :id, :class, :content

    attr_accessor :colspan, :rowspan

    # not yet used
    # attr_accessor :alignment, :width

    def initialize(col, row)
      @col = col
      @row = row
      @colspan = 1
      @rowspan = 1
    end

    def content=(c)
      i = c.index(':')
      if i
        @content = c[i+1..-1]
        @id, @class = c[0...i].split('.')
      else
        @id, @class = c.split('.')
      end
      @id.strip! if @id
      @class.strip! if @class
      @id = "#{@col}-#{@row}" if @id == ''
      @class = nil if @class == ''
    end

  end #class Cell

end





