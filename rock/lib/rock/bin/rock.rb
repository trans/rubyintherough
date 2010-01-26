require 'rock/rock'

$ROLL = ARGV.delete('--roll')

HELP = <<-END
USAGE: rock [option] command path

  Commands

    -v --verify

    -i --install

    -c --pack

    -x --unpack

  Options

    --roll

END


case ARGV[0]
when '--verify', '-v'
  file = ARGV[1]
  if RockFile.valid?(file)
    puts "#{file} [Okay]"
  else
    puts "#{file} [INVALID! DO NOT RUN THIS FILE!]"
  end
when '--pack', '-c'
  #puts "Stuffing: #{ARGV[1]}"
  rbi = RockFile.new
  rbi.create(ARGV[1])
when '--unpack', '-x'
  #puts "Unstuffing: #{ARGV[1]}"
  rbi = RockFile.new
  rbi.uncreate(ARGV[1])
when '--install', '-i'
  if RockFile.valid?(file)
    load(file)
  else
    puts "#{file} [INVALID!]"
  end
when '--help'
  puts HELP
#when '-s'
#  rbi = RBi.new
#  puts rbi.stream(ARGV[1])
#when '-x'
#  puts "Uncompressing: #{ARGV[1]}"
#  rbi = RBi.new
#  puts rbi.uncompress(ARGV[1])
else
  puts "Unrecognized command #{ARGV[0]}"
end
