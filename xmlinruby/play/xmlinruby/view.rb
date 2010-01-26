class Array
  def squeeze
    return self if self.size < 2
    arr = []
    arr << self.first
    for i in 1 ... self.size
      if block_given?
        arr << self[i] unless yield(arr.last, self[i])
      else
        arr << self[i] unless arr.last == self[i]
      end
    end
    arr
  end
end

def __view_eval(str) 
  if $DEBUG
    puts "---------------------------------------------"
    puts str
    puts "---------------------------------------------"
  end
  eval(str)
end

class View

  XML_ESCAPE_TABLE = {
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    "'" => '&#039;'
  }

  def self.render(meth, *args, &block)
    obj = new
    obj.send(meth, *args, &block)
    obj.__content
  end

  def self.require(file)
    @loaded_files ||= []
    file = File.expand_path(file)
    unless @loaded_files.include?(file)
      __view_eval(convert(File.read(file)))
      @loaded_files << file
    end
  end

  def self.convert(str)
    str.split("\n").map {|line|
      case line
      when /^(\s*)(<!?\/?[a-zA-Z].*)$/, /^(\s*)<[:](.*)$/
        space, text = $1, $2
        text.gsub!(/\$\{(.*?)\}/) { '#{escape(' + $1 + ')}' }
        [:text, [[text, space.size]] ]
      else
        [:ruby, line]
      end
    }.squeeze {|last, current|
      if last[0] == :text and current[0] == :text
        last[1].push(*current[1])
        true
      else
        false
      end
    }.map {|type, text|
      case type
      when :ruby
        text
      when :text
        '@__buf << %Q`' + text.map {|t, s| t + "\n"}.join + '`'
      else
        raise
      end
    }.join("\n")
  end

  def initialize
    @__buf = []
  end

  def __content
    @__buf.join
  end

  protected

  def escape_xml(expr)
    expr.to_s.gsub(/[&<>"]/) {|s| XML_ESCAPE_TABLE[s]}
  end

  alias escape escape_xml
  
  def capture
    old_buf, @__buf = @__buf, []
    begin
      yield
      return @__buf.join
    ensure
      @__buf = old_buf
    end
  end

  def output_escape(str)
    output(escape(str))
  end

  def output(str)
    @__buf << str
  end

  def __buf
    @__buf
  end
end
