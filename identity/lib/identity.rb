class SimpleCodeGenerator

  def self.identities
    @identities ||= []
  end

  def self.identity(&block)
    identities << block
  end

  attr_reader   :original
  attr_accessor :alternates

  def initialize(original)
    @original = original
    @alternates = [original]
  end

  def generate(limit=100)
    work  = original.dup
    while(alternates.size < limit) do
      alts = alternates.dup
      size = alternates.size
      alts.each do |alt|
        self.class.identities.each do |identity|
          self.alternates |= [identity[alt]]
          break if alternates.size >= limit
        end
      end
    end
  end

  def show_code
    alternates.each do |code|
      puts code
    end
  end

  def show_output
    alternates.each do |code|
      puts run(code)
    end
  end

  def generate_tests
    original_run = run(original)
    runner = method(:run)
    testcase = Class.new(Test::Unit::TestCase)
    alternates.each_with_index do |code, index|
      testcase.class_eval do  
        define_method("test_#{index}") do
          assert_equal(original_run, runner[code])
        end
      end
    end
  end

  def run(code)
    so = $stdout
    sio = StringIO.new
    $stdout, $stderr = sio, sio
    eval code, $TOPLEVEL_BINDING
    result = $stdout.string
    $stdout = so
    result
  end

  # code identities

  identity do |code|
    code.sub(/puts ["](.*)["]/, 'print "\1\n"')
  end

  identity do |code|
    code.sub(/puts ["](.*)["]/, 'printf "%s\n" % ["\1"]')
  end

  identity do |code|
    code.gsub(/["](.*)["]/, '"\1".reverse.reverse')
  end

  identity do |code|
    code.gsub(/['](.*)[']/){ $1.inspect }
  end

  identity do |code|
    code.gsub(/['](.*)[']/){ "#{$1.split(//).inspect}.join('')" }
  end

end

if __FILE__ == $0
  cnt = (ARGV.find{ |a| /\d+/ =~ a } || 20).to_i

  scg = SimpleCodeGenerator.new("puts 'Hello World!'")
  scg.generate(cnt)

  case ARGV[0]
  when 'test'
    require 'test/unit'
    scg.generate_tests
  when 'output'
    scg.show_output
  else
    scg.show_code
  end
end

