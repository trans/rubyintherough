#!/usr/bin/env ruby

# = TITLE:
#
#   TeXML
#
# = SUMMARY:
#
#   Web page: http://purl.org/net/home/pcdavid
#   Depends on: xmlparser (available on RAA)
#
#   Based of Douglas Lovell's paper:
#     "TeXML: Typesetting with TeX", Douglas Lovell, IBM Research
#      in TUGboat, Volume 20 (1999), No. 3
#
#   Original implementation in Java by D. Lovell, available on IBM
#   alphaWorks: http://www.alphaworks.ibm.com/tech/texml
#
# = COPYRIGHT:
#
#   General Public License (GPL, see http://www.gnu.org/gpl)
#
# = AUTHOR:
#
#   Pierre-Charles David (pcdavid@emn.fr)

require "xmltreebuilder"


# = TeXML
#
module TeXML

  # Main routine
  #
  # Usage: % texml < input.xml > output.tex
  #
  def self.main
    xml = ARGF.read

    builder = XML::SimpleTreeBuilder.new

    begin
      tree = builder.parse(xml)
    rescue XMLParserError
      line = builder.line
      print "#{$0}: #{$!} (in line #{line})\n"
      exit 1
    end
    print TeXML::Node.create(tree.documentElement).value
  end

  VERSION = "0.3"

  # Escaping sequences for LaTeX special characters
  SPECIAL_CHAR_ESCAPES = {
    '%'[0] => '\%{}',
    '{'[0] => '\{',
    '}'[0] => '\}',
    '|'[0] => '$|${}',
    '#'[0] => '\#{}',
    '_'[0] => '\_{}',
    '^'[0] => '\\char`\\^{}',
    '~'[0] => '\\char`\\~{}',
    '&'[0] => '\&{}',
    '$'[0] => '\${}',		#'
    '<'[0] => '$<${}',		#'
    '>'[0] => '$>${}',		#'
    '\\'[0] => '$\\backslash${}'#'
  }

  ##
  # Given a raw string, returns a copy with all (La)TeX special
  # characters properly quoted.
  def TeXML.quoteTeXString(aString)
    # TODO: is there a way to pre-allocate the size of the String?
    str = ''
    aString.each_byte do |char|
      str << (SPECIAL_CHAR_ESCAPES[char] or char)
    end
    return str
  end

  # Keeps track of which classes can handle which type of nodes
  NODE_HANDLERS = Hash.new

  # Common node superclass (also node factory, see Node#create)
  class Node

    # Creates a node handler object appropriate for the specified XML
    # node, based on the name of the node (uses information from
    # NODE_HANDLERS).
    def Node.create(domNode)
      handlerClass = NODE_HANDLERS[domNode.nodeName]
      if !handlerClass.nil?
        handlerClass.new(domNode)
      else
        nil
      end
    end

    def initialize(node)
      @node = node
    end

    # Should return the LaTeX equivalent value of this node
    def value
      raise "subclass responsibility"
    end

    # Aggregates the values of all the children of this Node whose
    # node name is included in the parameters, in the document order
    # of the children.
    def childrenValue(*childTypes)
      value = ""
      @node.childNodes do |kid|
        if childTypes.include?(kid.nodeName)
          node = Node.create(kid)
          value << node.value unless node.nil?
        end
      end
      return value
    end
  end

  class TexmlNode < Node
    NODE_HANDLERS['TeXML'] = TexmlNode

    def value
      return childrenValue('cmd', 'env', 'ctrl', 'spec', '#text')
    end
  end

  class CmdNode < Node
    NODE_HANDLERS['cmd'] = CmdNode

    def value
      name = @node.getAttribute('name')
      return "\\#{name}" + childrenValue('opt') + childrenValue('parm') + ' '
    end
  end

  class EnvNode < Node
    NODE_HANDLERS['env'] = EnvNode

    def value
      name = @node.getAttribute('name')
      start = @node.getAttribute('begin')
      start = 'begin' if start == ''
      stop = @node.getAttribute('end')
      stop = 'end' if stop == ''
      return "\\#{start}{#{name}}\n" +
        childrenValue('cmd', 'env', 'ctrl', 'spec', '#text') +
        "\\#{stop}{#{name}}\n"
    end
  end

  class OptNode < Node
    NODE_HANDLERS['opt'] = OptNode

    def value
      return "[" + childrenValue('cmd', 'ctrl', 'spec', '#text') + "]"
    end
  end

  class ParmNode < Node
    NODE_HANDLERS['parm'] = ParmNode

    def value
      return "{" + childrenValue('cmd', 'ctrl', 'spec', '#text') + "}"
    end
  end

  class CtrlNode < Node
    NODE_HANDLERS['ctrl'] = CtrlNode

    def value
      ch = @node.getAttribute('ch')
      unless ch.nil?
        return ch & 0x9F  # Control version of ch
      else
        nil
      end
    end
  end

  class GroupNode < Node
    NODE_HANDLERS['group'] = GroupNode

    def value
      return "{" + childrenValue('cmd', 'env', 'ctrl', 'spec', '#text') + "}"
    end
  end

  class SpecNode < Node
    NODE_HANDLERS['spec'] = SpecNode

    SPECIAL_MAP = {
      'esc'	=> "\\",
      'bg'	=> '{',
      'eg'	=> '}',
      'mshift'	=> '$',		# '
      'align'	=> '&',
      'parm'	=> '#',
      'sup'	=> '^',
      'sub'	=> '_',
      'tilde'	=> '~',
      'comment'	=> '%'
    }

    def value
      cat = @node.getAttribute('cat')
      return (SPECIAL_MAP[cat] or '')
    end
  end

  class TextNode < Node
    NODE_HANDLERS['#text'] = TextNode

    def value
      parent = @node.parentNode
      if parent.nodeName == 'env' && parent.getAttribute('name') == 'verbatim'
        return @node.nodeValue  # TODO: is there /some/ quoting to do?
      else
        return TeXML.quoteTeXString(@node.nodeValue)
      end
    end
  end

end

