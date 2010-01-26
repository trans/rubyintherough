
require 'benchmark'

load('crossit.rb')  # my program

# do each this many times
$n = 1000 

$layout1 = <<EOS
X _ _ _ _ X X
_ _ X _ _ _ _
_ _ _ _ X _ _
_ X _ _ X X X
_ _ _ X _ _ _
X _ _ _ _ _ X
EOS

$layout2 = <<EOS
_ _ _ _ X _ X _ X _ _ _ _ _ _ _ X _
_ X X _ X _ X _ X _ X X X _ X _ X _
_ X X _ X _ X _ X _ X X X _ X _ X _
_ _ _ X X _ X _ X _ _ _ _ X X _ _ _
_ X _ _ X _ X _ X _ X X X _ X X _ X
_ X X _ X _ X _ X _ X X X _ X X _ X
_ X X _ _ _ _ _ _ _ _ _ _ _ X X _ X
_ X X X X X X X X X X X X X X X X X
_ _ _ _ X _ X _ X _ _ _ _ _ _ _ _ _
_ X X _ X _ X _ X X X _ X X X X X _
_ X X _ X _ X _ X X X _ X X X X _ _
_ X X _ X _ X _ X X X _ X X X X _ X
_ X X _ X _ X _ X X X _ X X X _ _ X
_ X _ _ X _ X _ X X X _ X X X _ X X
_ _ _ _ _ _ _ _ _ _ _ _ _ X _ _ _ _
EOS

# note: no output to stdout.

def cross1
  $n.times { CrossWord.build( $layout1 ) }
end

def cross2
  $n.times { CrossWord.build( $layout2 ) }
end

# results

puts "Tom's Solution #{$n} runs:"
Benchmark.bm(15) do |b|
  b.report("Default Layout:") { cross1 }
  b.report("  Jim's Layout:") { cross2 }
end 
