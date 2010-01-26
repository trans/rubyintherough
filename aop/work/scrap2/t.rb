set_trace_func proc{ |e, f, l, m, b, k|
  puts "#{e}, #{f}, #{l}, #{m}, #{k}" if ! b
} 

module T
  # setup
  class Test
    def initialize; @example = true; end
    def test; "Okay!"; end
  end
end

t = T::Test.new
t.test
t.test
