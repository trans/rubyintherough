
require 'ostruct'
require 'rexml/document'
#require_all 'matchdata/*'
#require 'mega/re4x'


class REXML::Attributes
  def to_s
    s = []
    each { |k, v| s << %|#{k}="#{v}"| }
    " #{s.join(' ')}"
  end
end

# To help abstract away from the underlyijng XML tool.
XmlText = ::REXML::Text
XmlElement =::REXML::Element

def xml( x )
  case x
  when XmlElement, XmlText
    x
  else
    REXML::Document.new(x).root
  end
end


module MarkUps

  class Parser

    def initialize( marker_registry=nil )
      @markers = marker_registry || MarkUps::ArtMLMarkers
      @markers.parser = self
      @state = OpenStruct.new
      @state.count ||= Hash.new{0}
      @state.data ||= Hash.new
    end

    ## parsing

    # Master parse rountine
    def parse( x )
      cycle( xml( x ) )
    end

    # This is for dewiki to subparse "cdata"
    def subparse( str  )
      parse( str )
    end

    def cycle( x )
      node = x.dup #dup neccessary?
      case node
      when XmlText
        node
      when XmlElement
        marker = @markers[node.name]
        if marker
          @state.count[marker] += 1 if marker.count?
          # dewiki
          if marker.respond_to?(:dewiki) and node.prefix == 'wiki' #and node.attributes['xml:cdata']
            #node = xml( marker.dewiki( node.children.join(''), node.attributes, info(marker) ) )
            node = xml( marker.dewiki( node.text, node.attributes, info(marker) ) )
          end
          # subcycle
          unless marker.nosubcycle?
            node = subcycle( node )
          end
          # remodel
          if marker.respond_to?(:remodel)
            #node = subcycle( marker.to_xml( nnode, info(marker) ) )
            node = marker.remodel( node, info(marker) )
          end
          @state.count[marker] -= 1 if marker.count?
        else
          node = subcycle( node )
        end
      else
        raise node.inspect
      end
      return node
    end

    def subcycle( node )
      n = XmlElement.new(node.name)
      n.add_attributes(node.attributes)
      node.children.each { |c| n << cycle(c) } #parse( c ) }
      n
    end

    # conversion

    def convert( node, fmt )
      marker = @markers[node.name]
      if marker
        marker.send( "to_#{fmt}", node, info(marker) )
      else
        node.to_s
      end
    end

    def subconvert( node, fmt )
      case node
      when XmlText
        node.to_s
      else
        node.children.collect { |n|
          case n
          when XmlText
            n.to_s
          else
            convert( n, fmt )
          end
        }.join('')
      end
    end

    # support

    def info(marker)
      {
        :count=>@state.count[marker],
        :data=>@state.data
      }
    end

  end

end # MarkUps


# SCRAP

#     def subparse( subtext )
#       subdoc = self.class.new( "<__DUMMY_ROOT__>" + subtext + "</__DUMMY_ROOT__>", @markers )
#       doc = subdoc.parse
#       content = []; doc.each_child { |c| content << c }
#       return content
#     end
#
#     def cycle( node )
#       #if node.node_type == :element
#         marker = @markers[node.__name]
#         if marker
#           @count[marker] += 1 if marker.count?
#           new_node = marker.model( node, :count => @count[marker] )
#           @count[marker] -= 1 if marker.count?
#         else
#           new_node = node.dup
#         end
#       #else
#       #  new_node = node.dup
#       #end
#       return new_node
#     end


#      case node.node_type
#      when :element
#        marker = @markers[node.name]
#        if marker
#          @count[marker] += 1 if marker.count?
          #if marker.raw?
          #  raise "raw node does not contain cdata node" if node.cdatas.length == 0
          #  content = node.cdatas[0].value
          #  args = {};  node.attributes.each_key{ |k| args[k] = node.attributes[k] }
          #else
          #  content = []; node.each_child { |c| content << cycle( c ) }
          #  args = {};  node.attributes.each_key{ |k| args[k] = node.attributes[k] }
          #end
          #r = marker.to_model( self, content, args, :count => @count[marker] )
#          new_node = marker.model( self, node, :count => @count[marker] )
#          @count[marker] -= 1 if marker.count?
#        else
#          # subtext
#          new_node = node.text
#        end
#      when :text
#        new_node = node.value
#      else
#        raise "unaccouted node type"
#      end
#      return new_node
#    end
