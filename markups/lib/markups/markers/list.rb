
require 'markups/marker'

module MarkUps::Markers

  #
  # List Marker
  #
  class List < Marker

    priority 0.5
    count

    def wiki( doc_lines, line_claim )
      current = nil
      indent, tabbed, lineno = 0, 0, 0
      doc_lines.each_with_index do |line, lineno|
        if current and line.strip !~ %r{ ^ ( [ ]{#{tabbed}} | [ ]{#{indent}}[#*] | [ ]*$ ) }x
          line_claim[lineno-1].endtag self
          doc_lines[lineno] = %{</wiki:list>\n#{line}}
          current = false
        end
        if !current and line =~ /^([ ]*)([*#])/
          indent = $~[1].size
          tabbed = $~[1].size + $~[2].size
          type = $~[2]
          line_claim[lineno].tag self
          doc_lines[lineno] = %{<wiki:list indent="#{indent}" tab="#{tabbed}" type="#{type}">\n#{line}}
          current = true
        end
      end
      if current
        line_claim[-1].endtag self
        doc_lines[-1] << %{\n</wiki:list>}
        current = false
      end
      return doc_lines, line_claim
    end

    # convert wiki markup to canonical xml
    def dewiki( text, attributes={}, info={} )
      attributes.delete('xml:cdata')
      attributes.delete('xml:space')
      # start tag
      list = %{<list#{attributes}>}
      tab = '' # we'll need this to properly indent the end tag
      # parse the wiki markup
      match = text.scan( /^([ ]*) ([*#]) [ ] (.*?) (?=\Z|^\1\2)/mx )
      match.each{ |tab, token, text|
        # item xml
        item = ''
        item << %{<item token="#{token}" tab="#{tab.length}">\n}
        item << text.rstrip.indent(2) << "\n"
        item << %{</item>}
        # sub-parse
        item = "#{parser.subparse(item)}"
        # indent properly
        item = item.tabto( tab.length+1 )
        # add item to list xml
        list << "\n" << item
      }
      list << "\n" << (' ' * ((tab.length-1).clip(0)))
      list << %{</list>}
      return list
    end

    # conversion

    def to_xhtml( node, info )
      q = []
      q << %{<ul>}
      node.each_element{ |item|
        q << %{<li>}
        q << %{#{parser.subconvert(item, :xhtml)}}
        q << %{</li>}
      }
      q << %{</ul>}
      return q.join('')
    end
    alias_method :to_html, :to_xhtml

  end #class List

end #module MarkUps::Markers




=begin
    # locate wiki markup

    def wiki_match( doc_lines )
      on = nil
      sections = []
      doc_lines.each_with_index do |line, lineno|
        if on and line =~ /^([ ]*)\S+/
          indent = $~[1].size
          if indent < on[:indent]
            on[:to] = lineno
            sections << on
            on = nil
          end
        end
        if line =~ /^([ ]*)([*#])/
          indent = $~[1].size + $~[2].size
          type = $~[2]
          on = { :indent => indent, :type => type, :from => lineno }
        end
      end
      sections
    end
=end
