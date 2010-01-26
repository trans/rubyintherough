# TITLE:
#
#   XML Design Kit
#
# TODO:
#   - Add open element support [PARTLY DONE]
#   - Add Namspace support [PARTLY DONE]
#   - Apply proper escapes (DONE, but minimal escape)
#   - Add validation support [DONE ?]
#   - Generate DTD; possible?; entities?
#   - General parser (use REXML ?).
#   - Support class Mixed < (Element + Text) ?

#
module Blow

  # XmlDesignKit provides a light-weight way to define
  # the structure of XML documents, creating a Ruby BlockUp
  # builder. Think of it as a simple DTD written in Ruby.
  module XmlDesignKit

    # Namespace class.
    class NameSpace
      attr_accessor :uri, :name
      #
      def initialize(uri, name=nil)
        @uri  = uri
        @name = name
      end
      #
      def to_xml
        attr = name ? "xmlns:#{name}" : "xmlns"
        %[#{attr}="#{uri}"]
      end
    end

    # Give all the nodes a common base class. This provides
    # the common XmlDesignKit namespace, and any methods
    # shared by all types of nodes.
    class Node
      include XmlDesignKit

      #
      def self.validations ; @validations ||= [] ; end

#       #
#       def self.inherited_validations
#         validations = []
#         ancestors.each do |ancestor|
#           validations.concat(ancestor.validations)
#           break if Node == ancestor
#         end
#         validations
#       end

      # Define a validation procedure.
      def self.validate(&block) ; validations << block ; end

      #
      def xml_schema_validations
        validations = []
        eigenclass = (class << self; self; end)
        validations.concat(eigenclass.validations)
        eigenclass.ancestors.each do |ancestor|
          validations.concat(ancestor.validations)
          break if Node == ancestor
        end
        validations.uniq
      end

      # Does node pass validation tests?
      #--
      # TODO: Should self be passed to validator rather then instance eval?
      #       Or depend on arity?
      #++
      def valid?
        xml_schema_valiations.all?{ |v| instance_eval(&v) }
      end

      # XML string escape.
      def xml_escape(input)
        result = input.dup
        result.gsub!("&", "&amp;")
        result.gsub!("<", "&lt;")
        result.gsub!(">", "&gt;")
        result.gsub!("'", "&apos;")
        result.gsub!("\"", "&quot;")
        return result
      end
    end

    # Attribute. All tag attributes are either an instance of this class,
    # or an instance of a subclass of this class. The attribute's value
    # is delegated to via method_missing.
    class Attribute < Node
      #
      def initialize(value, name)
        @value = value
        @name  = name
      end

      #--
      # TODO: Not sure about namespace here. ?
      #++
      def to_xml(ns=nil)
        %[#{@name}="#{@value}"]
      end

      #
      def method_missing(s, *a, &b)
        @value.send(s, *a, &b)
      end
    end

    # Tag node, is the simplist type of XML element. It provides for
    # a tagname and attributes and nothing more.
    # Using #to_xml produces @<name attr1=value.../>@.
    class Tag < Node
      # Define a namespace.
      def self.namespace(uri=nil, name=nil)
        return @namespace unless uri
        @namespace = NameSpace.new(uri, name)
      end

      # Tags can have attributes.
      def self.attributes; @attributes ||= {}; end

#       # Collect attribute names for complete class hierarchy.
#       def self.inherited_attributes
#         attributes = {}
#         ancestors.each do |ancestor|
#           attributes = ancestor.attributes.merge(attributes)
#           break if Tag == ancestor
#         end
#         attributes
#       end

      # Define an attribute for a tag. If option :required is
      # set to true, then a validator it created to make sure
      # the attribute is set.
      def self.attribute(key, kind=nil, options=nil)
        kind ||= Attribute
        #options ||= {}
        attributes[key.to_sym] = [kind, options]
      end

      # Collect attribute names for complete class hierarchy.
      def xml_schema_attributes
        eigenclass = (class << self; self; end)
        attributes = eigenclass.attributes
        eigenclass.ancestors.each do |ancestor|
          attributes = ancestor.attributes.merge(attributes)
          break if Tag == ancestor
        end
        attributes
      end

      # New tag.
      def initialize(name, attributes=nil)
        @xml_tagname    = name
        @xml_attributes = {}

        (attributes||{}).each do |k,v|
          self[k] = v
        end
      end

      def xml_tagname
        @xml_tagname || self.class.name.split("::").last.downcase
      end

      def xml_attributes
        @xml_attributes
      end

      # Get attribute.
      def [](key)
        xml_attributes[key.to_sym]
      end

      # Set attribute.
      def []=(key, value)
        attr = xml_schema_attributes[key.to_sym]
        kind = attr ? attr[0] : Attribute
        xml_attributes[key.to_sym] = kind.new(value, key)
      end

      # Convert to XML string.
      def to_xml(ns=nil)
        atts = []

        myns = self.class.namespace || ns
        if myns != ns
          atts << myns.to_xml
        end
        ns = myns

        atts += xml_attributes.collect do |k, v|
          case v
          when nil
            nil
          when Attribute
            v.to_xml(ns)
          else
            %[#{k}="#{v}"]
          end
        end.compact
        atts = atts.join(' ')

        %[<#{xml_tagname} #{atts}/>]
      end

      # Common to all XML tags/elements.
      attribute "xml:base", nil #, :namespace => 'xml'
      attribute "xml:lang", nil #, :namespace => 'xml'
    end

    # Value tag is like Tag, but can contain a body. The body
    # can be any value and is delegated to via method_missing.
    # When generating XML it is converted to a string via #to_s.
    #
    # TODO: Support #to_xml on value as well?
    class Value < Tag
      private

      attr_reader :xml_value

      def initialize(name, value, attributes=nil)
        super(name, attributes)
        @xml_value = value
      end

      # Delegate to underlying value.
      def method_missing(s, *a, &b)
        @xml_value.send(s, *a, &b)
      end

      public

      # Translate into XML string.
      def to_xml(ns=nil)
        x = super.chomp("/>").chomp(" ")
        x << ">"
        x << xml_escape(xml_value.to_s)
        x << "</#{xml_tagname}>"
        x
      end
    end

    # Element node is a Tag that can have sub-elements.
    # The Element class represents an XML branch. It does
    # not contain a text node, only sub-tags/elements.
    class Element < Tag

      # Element tags can have sub-elements.
      def self.elements; @elements ||= []; end

#       # Complete element list thru class hierarchy.
#       def self.inherited_elements
#         elements = []
#         ancestors.each do |ancestor|
#           elements.concat(ancestor.elements)
#           break if Element == ancestor
#         end
#         elements
#       end

      # Define an element that can occur only once. If option :required
      # is set to true, then a validator it created to make sure it is set.
      # If :multiple is true then an element tag that can occur many times.
      def self.element(name, kind=nil, opts=nil)
        name = name.to_s
        kind ||= Element
        opts ||= {}

        elements << [name.to_sym, kind, opts]  # TODO: What about duplicates entries?

        if opts[:multiple]
          define_multiple_accessor(name, kind)
        else
          define_accessor(name, kind)
        end

        # If requried option setup a validator for it.
        if opts[:required]
          if opts[:multiple]
            validate{ !instance_variable_get("@#{name}").empty? }
          else
            validate{ instance_variable_get("@#{name}") }
          end
        end
      end

      # Define build accessor.
      def self.define_accessor(name, kind)
        if kind <= Tag
          named = %[:#{name},]
        else
          named = ''
        end

        module_eval <<-END, __FILE__, __LINE__
          def #{name}(*args, &block)
            if args.empty? && !block
              @#{name}
            else
              @#{name} = #{kind}.new(#{named} *args, &block)
            end
          end
          def #{name}=(value)
            @#{name} = #{kind}.new(#{named} value)
          end
        END
      end

      # Define build accessor.
      def self.define_multiple_accessor(name, kind)
        if kind <= Tag
          named = %[:#{name},]
        else
          named = ''
        end

        plural = case name
                 when /y$/: name.sub(/y$/, 'ies')
                 when /s$/: name + 'es'
                 else       name + 's'
                 end

        module_eval <<-END, __FILE__, __LINE__
          def #{name}(*args, &block)
            if args.empty? && !block
              @#{name}
            else
              (@#{name} ||= []) << #{kind}.new(#{named} *args, &block)
            end
          end
        END

        module_eval <<-END, __FILE__, __LINE__
          def #{plural} ; @#{name} ||= [] ; end
        END
      end

#         # If a document can accept arbitary elements; this creates
#         # method missing method, and defines elements dynamically
#         # on the singleton class.
#
#         def custom_elements
#           code = %{
#             def method_missing(sym, *args, &blk)
#               (class << self; self; end).class_eval do
#                 element(sym)
#               end
#               send(sym, *args, &blk)
#             end
#           }
#           module_eval code
#         end

      # New Element.
      def initialize(name=nil, attributes=nil, &block)
        super(name, attributes)
        if block
          if block.arity == 1
            block.call(self)
          else
            instance_eval(&block)
          end
        end
      end

      # Complete element list thru class hierarchy.
      def xml_schema_elements
        elements = []
        eigenclass = (class << self; self; end)
        elements.concat(eigenclass.elements)
        eigenclass.ancestors.each do |ancestor|
          elements.concat(ancestor.elements)
          break if Element == ancestor
        end
        elements
      end

      def xml_namespace
        self.class.namespace
      end

      # Convert to XML string.
      def to_xml(ns=nil)
        x = super.chomp("/>").chomp(" ")
        x << %[>]
        #self.class.inherited_elements.each do |name, kind, opts|
        xml_schema_elements.each do |name, kind, opts|
          obj = send(name)
          next unless obj
          case obj
          when Array
            obj.each do |v|
              if v.is_a? Tag
                x << v.to_xml(xml_namespace)
              else
                x << %[<#{name}>#{xml_escape(v.to_s)}</#{name}>]
              end
            end
          else
            if obj.is_a? Tag
              x << obj.to_xml(xml_namespace)
            else
              x << %[<#{name}>#{xml_escape(obj.to_s)}</#{name}>]
            end
          end
        end
        x << %[</#{xml_tagname}>]
        x
      end

      # Convert to REXML element. You must first load
      # rexml/document, for this to work.
      def to_rexml
        node = REXML::Element.new(xml_tagname)

        node.add_namespace(self.class.namespace) if self.class.namespace

        self.class.attributes.each do |atr|
          val = instance_variable_get("@_#{atr}")
          next unless val
          node.add_attribute(val.to_rexml)
        end

        xml_schema_elements.each do |name, kind, opts|
          obj = send(name)
          next unless obj
          case obj
          when Array
            obj.each do |v|
              if v.is_a? Tag
                node.add_element(v.to_rexml) #(xml_namespace)
              else
                node.add_element(REXML::Element.new(name, v.to_s))
              end
            end
          else
            if obj.is_a? Tag
              node.add_element(obj.to_rexml) #(xml_namespace)
            else
              node.add_element(REXML::Element.new(name, obj.to_s))
            end
          end
        end

        #if @__text
        #  node.add_text(@__text.to_rexml)
        #end
        node
      end

      #def to_libxml
      #end
    end

    # Just like Element, but allows arbitrary tag entries.
    class OpenElement < Element

      def method_missing(sym, *args, &blk)
        sym = sym.to_s
        case sym[-1,1]
        when '?', '!'
          super
        when '='
          (class << self; self; end).class_eval do
            element(sym.chomp('='), OpenElement)
          end
          send(sym, *args) #, &blk)
        else
          (class << self; self; end).class_eval do
            element(sym, OpenElement, :multiple=>true)
          end
          send(sym, *args, &blk)
        end
      end

    end

    # Root tag. Use this to generate complete XML document.
    #

#     class Root < Element
#       class << self
#         def root(value=Exception)
#           (Exception == value) ? @__root : @__root = value
#         end
#       end
#
#       def initialize(name=nil, attrs=nil, &block)
#         super(name || self.class.root, attrs, &block)
#       end
#     end

#     def self.Multiple(klass)
#       Class.new(Array) do
#         @kind = klass
#
#         def new
#           item = self.class.holds.new
#           self << item
#
#           item
#         end
#
#         def << item
#           raise ArgumentError, "this can only hold items of class #{self.class.holds}" unless item.is_a?(self.class.holds)
#           super(item)
#         end
#
#         def to_xml
#           collect do |item| item.to_xml end
#         end
#
#         def self.holds; @kind ; end
#         #def self.single?; true end
#         def taguri; end
#       end
#     end

  end
end




if $0 == __FILE__

  class Try < Blow::XmlDesignKit::Element
    class ValueX < Value
      attribute :x
    end

    class ValueY < ValueX
    end

    element :a, ValueX
    element :b, ValueY
    element :c, String
  end

  t = Try.new('trying') do
    a 1, :x=>"hi"
    b 2, :x=>"bi"
    c "Here"
  end

  puts t.to_xml
end
