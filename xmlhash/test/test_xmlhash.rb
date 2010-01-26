require 'xmlhash'
require 'test/unit'

class TC_XmlHash < Test::Unit::TestCase

  def test_01
    h = { 'a' => 1, 'b' => 2 }
    x = XMLHash.convert('root', h)
    assert_equal( "<root><a>1</a><b>2</b></root>", x )
  end

  def test_02
    h = { 'a' => [ 1, 2 ], 'b' => 2 }
    x = XMLHash.convert('root', h)
    assert_equal( "<root><a>1</a><a>2</a><b>2</b></root>", x )
  end

  def test_03
    h = {
      'a' => [ 'x', 'y' ],
      'b' => [ '1', '2' ],
      'c' => [
        { 'k' => 'hi', '*' => 'fudge' }
      ]
    }
    x = XMLHash.convert('root', h)
    assert_equal( %{<root><a>x</a><a>y</a><b>1</b><b>2</b><c k="hi">fudge</c></root>}, x )
  end

end




