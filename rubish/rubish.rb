# rubish.,rb

require 'shellwords'

def polish_script(script)
  lines = script.split(/[;\n]/)
  lines.collect do |line|
    polish_line(line)
  end.join("\n")
end

def polish_line(line)
  return "" if /\S/ !~ line  # blank?
  words = Shellwords.shellwords(line)
  cmd = words.shift
  args = words.collect do |word|
    polish_word(word)
  end
  return "#{cmd}(#{args.join(",")});"
end

def polish_word(word)
  if word !~ /^["'].*?["']$/
    %["#{word}"]
  else
    word
  end
end


script = File.read(ARGV[0])

puts polish_script(script)