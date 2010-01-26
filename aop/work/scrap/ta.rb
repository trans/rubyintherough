require "./aspectsBG.rb"

module Publi
  extend Aspects
end

class Ko
  include Publi
end

class La < Ko
  before :hello => :koko

  def hello
    puts "1"
  end

  def koko
    puts "0"
  end
end

l = La.new
l.hello
