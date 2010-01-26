# = XmlHash
#
# WARNING: This is a work in progress!!!

#
module XMLHash

  extend self

  def convert(root, content)
    convert_tag(root, '*' => content)
  end

  private

  #
  def convert_tag(tag, node)
    subn = node.delete('*')
    atts = node.collect{ |k,v| %[#{k}="#{v}"] }
    body = convert_body(subn)

    start_tag = "#{tag} #{atts}".strip

    if body.to_s.empty?
      "<#{start_tag}/>"
    else
      "<#{start_tag}>#{body}</#{tag}>"
    end
  end

  #
  def convert_body(node)
    case node
    when Array
      node.collect do |subn|
        convert_body(subn)
      end
    when Hash
      node.collect do |tag, subn|
        case subn
        when Hash
          convert_tag(tag, subn)
        when Array
          subn.collect do |e|
            case e
            when Hash
              convert_tag(tag, e)
            else
              convert_tag(tag, '*' => e)
            end
          end
        else
          convert_tag(tag, '*' => subn)
        end
      end
    else
      node.to_s
    end
  end

end


class Hash

  def to_xml(root='root')
    XMLHash.convert(root, self)
  end

end








