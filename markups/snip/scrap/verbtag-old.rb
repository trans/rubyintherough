
require 'nano/string/shatter'

module XML

  INDICATOR = '|'
  TAG_REGEX = %r{ \< (\/)? ([\w.:]+) (.*?) ([#{INDICATOR}/])? \> }mix

  module_function

  def verbtag_to_cdata( txt )
    q = txt.shatter(TAG_REGEX)
    # setup
    adverb = false
    b = []
    stack = []
    # stack loop
    until q.empty?
      e = q.shift
      if md = TAG_REGEX.match( e )
        if md[1]
          #close-tag
          ctag, lit = *(stack.pop)
          if lit
            adverb = false
            b << ']]>'
          end
          b << e
        elsif md[4] == '/'
          #unit-tag
          b << e
        else
          #open-tag
          stack << [ md[2], (md[4] == INDICATOR and not adverb) ]
          if md[4] == INDICATOR and not adverb
            adverb = true
            b << e.chomp('|>') << '><![CDATA['
          else
            b << e
          end
        end
      else
        b << e
      end
    end

    return b.join('')
  end

end #module XML


# test

if $0 == __FILE__

  q = %Q{
    <test a="1"|>
      +---------+
      |  Fixes  |
      +---------+
    </test>
    <test>
      This is
      fixed too.
    </test>
    <test|>
      This is the final test:
      <test|>
        Can it work?
      </test>
    </test>
  }

  r = XML.verbtag_to_cdata( q )
  puts r

end
