
require 'rexml/document'
require 'nano/string/shatter'

module MarkUps

  module Preparser

    INDICATOR = '|'
    TAG_REGEX = %r{ \< (\/)? ([\w.:]+) (.*?) ([#{INDICATOR}]\d*)? ([/])? \> }mix

    module_function

  #   # If only it were this simple.
  #   def verb2tag( txt )
  #     txt.gsub( %r{\|(\d*)\>}i ) { p $1; %{ xml:space="preserve" xml:cdata="} + ( $1!='' ? $1 : '0' ) + '">' }
  #   end

    def verbtag( obj )
      return obj unless String === obj
      q = obj.shatter(TAG_REGEX)
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
              #b << ']]>'
            end
            b << (adverb ? REXML::Text.normalize(e) : e)
          elsif md[5]
            #unit-tag
            b << (adverb ? REXML::Text.normalize(e) : e)
          else
            #open-tag
            stack << [ md[2], (md[4] and !adverb) ]
            if md[4] and !adverb
              adverb = true
              indent = md[4][1..-1].to_i
              b << e[0...e.rindex('|')]
              b << %{ xml:space="preserve"}
              b << %{ xml:cdata="#{indent}"}
              b << %{>}
              #b << %{><![CDATA[}
            else
              b << (adverb ? REXML::Text.normalize(e) : e)
            end
          end
        else
          b << (adverb ? REXML::Text.normalize(e) : e)
        end
      end

      return b.join('')
    end

  end #module Preparser

end


# test

if $0 == __FILE__

  q = %Q{
    <test a="1"|>
      +---------+
      |  Fixes  |
      +---------+
    </test>
    <test>
     | This is
     | fixed too.
    </test>
    <test|3>
      This is the final test:
      <test|>
        Can it work?
      </test>
    </test>
  }

  r = MarkUps::Preparser.verbtag( q )
  puts r

end

