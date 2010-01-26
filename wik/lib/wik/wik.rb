

# Wik is the stupid simple wiki markup language. It attempts
# to proved the best huamn readability while at the same time
# providing extensive markup-ability. It does this in by
# separating the two components in a unique a way. Rather
# than using contortionary textual structures, it simply
# allows you to state the structure, much like html, hoever
# to remain headable it places all such information on the
# right side of the line, instead of the left (or both).
# By ignoring white space these "side-notations" are hardly
# preceptable.
#
#
class Wik

  TYPE_RE  = /\<(.*?)\>/
  INST_RE  = /\[(.*?)\]/
  STYLE_RE = /\{(.*?)\}/
  CLASS_RE = /\.(\S+?)/
  IDENT_RE = /\#(\S+?)/

  attr :input

  def initialize(input)
    case input
    when File
      @input = input.read
    else
      @input = input.to_s
    end
  end

  def to_html
    data = parse
    output = []
    output << '<html>'
    output << '<head>'
    output << '</head>'
    output << '<body>'
    data.each do |node|
      output << node.to_html
    end
    output << '</body>'
    output << '</html>'
  end

  def parse
    text, *endocs = *parse_sections(input)
    data = parse_text(text)
  end

  def parse_sections(input)
    text, *endocs = *input.split('--- !')
    return text, endocs
  end

  def parse_text(text)
    data = []
    mode = nil

    text.each_line do |line|
      lstrip = line.strip
      if lstrip.empty?
        mode = nil; next
      end

      text, mark = *line.split(/[ ]{3}[|]/)
      text << "\n" if mark

      next if mark.to_s.strip == '!'     # ignore marker

      #text = (text || '').strip  # not really needed
      mark = (mark || '').strip

      tags = parse_mark(mark)

      if tags.empty?
        if mode
          data.last.update(text)
        else
          tags = [Tag.new(Tag::DEFAULT_TYPE)]
          data << Node.new(text, tags)
          mode = tags.last.type
        end
      else
        data << Node.new(text, tags)
        mode = tags.last.type
      end
    end
    return data
  end

  # Parsing the side mark of a line.
  # Returns an array of Tag objects.
  def parse_mark(side)
    return [] if side.empty?
    tags  = []
    tag   = Tag.new(Tag::DEFAULT_TYPE)
    mode  = :start

    marks = side.split(/\s+/)
    marks.each do |mark|
      if mode == :start_style
        case mark
        when /(.*?)\}$/
          tag.styles << $1
          mode = :style
        else
          tag.styles << $1
        end
      else
        if md = /^(.*?)\((.*?)\)$/.match(mark)
          tag.instructions << "#{md[1]}(#{md[2]})"
          mode = :inst
        elsif md = /^\#(.*?)/.match(mark)
          tag.identity = md[1]
          mode = :id
        elsif md = /^\.(.*?)/.match(mark)
          tag.classes << md[1]
          mode = :class
        elsif md = /^\{(.*?)/.match(mark)
          tag.styles << md[1]
          mode = :start_style
        else
          tags << tag unless mode == :start
          tag = Tag.new(mark)
          mode = :type
        end
      end
    end
    tags << tag unless mode == :start

    return tags
  end

=begin
  def parse_style(mark)
    if md = STYLE_RE.match(mark)
      mark.sub!(md[0], '')
      md[1]
    end
  end

  def parse_inst(mark)
    if md = INST_RE.match(mark)
      mark.sub!(md[0], '')
      md[1]
    end
  end

  def parse_tag(mark)
    t = []
    while md = CLASS_RE.match(mark)
      mark.sub!(md[0], '')
      t << md[1]
    end
    t
  end

  #def parse_class(mark)
  #  c = []
  #  while md = CLASS_RE.match(mark)
  #    mark.sub!(md[0], '')
  #    c << md[1]
  #  end
  #  c
  #end

  #def parse_ident(mark)
  #  if md = IDENT_RE.match(mark)
  #    mark.sub!(md[0], '')
  #    md[1]
  #  end
  #end
=end

  # = Node class
  class Node
    attr :text
    attr :tags

    def initialize(text, tags=[])
      @text = text
      @tags = tags
    end

    def update(text)
      @text << text
    end

    def to_html
      output = tags.reverse.inject(text) do |memo, tag|
        tag.to_html(memo)
      end
    end
  end

  # = Tag class
  class Tag
    DEFAULT_TYPE = 'p' # or 'div' ?

    attr :type
    attr :identity
    attr :classes
    attr :styles
    attr :instructions
    attr :text

    # If there is no <tt>type</tt> then it is an "update previous tag".
    def initialize(type)
      @type         = type
      @identity     = nil
      @classes      = []
      @styles       = []
      @instructions = []
    end

    def identity=(ident)
      @identity = ident
    end

    def to_html(text)
      output = %[]
      output << %[<#{type}]
      output << %[ id="#{identity}"] if identity
      output << %[ class="#{classes.join(' ')}"] unless classes.empty?
      output << %[ style="#{styles.join(' ')}"] unless styles.empty?
      output << %[>\n]
      output << %[#{text}]
      output << %[</#{type}>\n]
      output
    end
  end

=begin
  #
  class UpdateTag
    attr :classes
    attr :styles
    attr :instructions
    attr :text

    def initialize(type)
      @type         = type
      @classes      = []
      @styles       = []
      @instructions = []
    end

    def identity=(ident)
      raise "multiple identities"
    end
  end
=end

end

