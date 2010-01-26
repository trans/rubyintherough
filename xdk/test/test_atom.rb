# Test for blow/atom.rb

require 'test/unit'
require 'blow/atom'

class TestAtom < Test::Unit::TestCase

  def setup
    @sample = Blow::Atom::Feed.new('feed') do |s|
      s.author(:name => 'Tom', :email=>'trans@ggmail.nut')
      s.title "YEPPY!"
    end
  end

  def test_output
    r = %{<feed xmlns="http://www.w3.org/2005/Atom"><author email="trans@ggmail.nut" name="Tom"/><title>YEPPY!</title></feed>}
    assert_equal( r, @sample.to_xml )
  end

end

