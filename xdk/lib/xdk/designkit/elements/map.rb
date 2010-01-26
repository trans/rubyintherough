require 'xdk/designkit/elements/tag'

module XDK

  module DesignKit

    class Map < Tag

      class << self

        # Element tags can have sub-elements.

        def elements; @elements ||= {}; end

        # Define an element that can occur only once. If option :required
        # is set to true, then a validator it created to make sure it is set.
        # If :multiple is true then an element tag that can occur many times.

        def element(name, *args)
          name = name.to_sym
          opts = (Hash===args.last) ? args.pop : {}
          kind = args.pop || Data   # Data is the default element if none is given.

          opts[:class]   = kind
          elements[name] = opts     # TODO: What about duplicates entries?

          unless name.to_s.index(':')  # has a namespace
            if opts[:multiple]
              define_multiple_accessor(name, kind)
            else
              define_accessor(name, kind)
            end
          end

          # If requried option setup a validator for it. (TODO: multiple vs not)
          if opts[:required]
            validate{ ! element_tracker[name].empty? }
          end
        end

        private

        # Define build accessor.

        def define_accessor(name, kind)
          module_eval <<-END, __FILE__, __LINE__
            def #{name}(*args, &block)
              element!(:'#{name}',*args, &block)
              #if args.empty? && !block
              #  element_tracker[:#{name}]
              #else
              #  element_update(:#{name}, *args, &block)
              #end
            end
            def #{name}=(value)
              element!(:'#{name}', value)
              #element_update(:#{name}, value)
            end
          END
        end

        # Define build accessor.

        def define_multiple_accessor(name, kind)
          name   = name.to_s

          plural = case name
            when /y$/
              name.sub(/y$/, 'ies')
            when /s$/
              name + 'es'
            else       name + 's'
          end

          module_eval <<-END, __FILE__, __LINE__
            def #{name}(*args, &block)
              element!(:'#{name}',*args, &block)
              #if args.empty? && !block
              #  element_tracker[:#{name}]
              #else
              #  element_append(:#{name}, *args, &block)
              #end
            end
            def #{plural} ; element_tracker[:#{name}] ||= [] ; end
          END
        end

      end

      # Complete element list thru class hierarchy.

      def xml_schema_elements
        eigenclass = (class << self; self; end)
        elements = eigenclass.elements
        eigenclass.ancestors.each do |ancestor|
          elements = ancestor.elements.merge(elements)
          break if ancestor == Map
        end
        elements
      end

      #       #
      #
      #       def element_schema_textclass
      #         self.class.text
      #       end


      # -- Instance -----------------------------------------------------------

      attr_reader :element_content
      attr_reader :element_tracker
      #attr_reader :element_value

      private

      # New element.

      def initialize(name=nil, attributes=nil, &block)
        super(name, attributes)

        @element_content    = []
        @element_tracker    = {}

        if block
          if block.arity == 1
            block.call(self)
          else
            instance_eval(&block)
          end
        end
      end

      # Delegate to underlying first content value?
      # TODO: Yes? No? How to do right?
      #def method_missing(s, *a, &b)
      #  element_content[0].send(s, *a, &b)
      #end

      public

      # Add proccessing instruction.

      def instruct!(tag, *args)
        element_content << Instruction.new(tag, *args)
      end
      alias_method :instruction!, :instruct!

      # XML declaration.
      # TODO: This should only happen at top of document. How to control?

      def xml!(atts=nil)
        atts ||= {}
        atts[:version]  ||= '1.1'
        atts[:encoding] ||= "ISO-8859-1"
        instruct!(:xml, atts)
      end

      # Add element.

      def element!(name, *args, &block)
        name = name.to_sym
        if args.empty? && !block
          element_tracker[name]
        else
          #element_append(name.to_sym, *args, &block)
          elem = xml_schema_elements[name]
          if elem
            kind  = elem[:class]
            multi = elem[:multiple]
          else
            kind  = Data
            multi = true
          end
          if kind <= Element
            e = kind.new(name, *args, &block)
          else
            e = Data.new(name, kind.new(*args, &block))
          end
          if multi
            element_tracker[name] ||= []
            element_tracker[name] << e
            element_content << e
          else
            element_tracker[name] = e
            element_content << e
          end
        end
      end

      private

#       # Update child element, will add if not present.
#       # TODO: Need to check schema for non-multiple?
#
#       def element_update(name, *args, &block)
#         name = name.to_sym
#         if element_tracker[name]
#           element_tracker[name].send(:initialize, name, *args, &block)  # reset
#         else
#           kind = xml_schema_elements[name][0]
#           if kind <= Element
#             e = kind.new(name, *args, &block)
#           else
#             e = Data.new(name, kind.new(*args, &block))
#           end
#           element_tracker[name] = e
#           element_content << e
#         end
#       end
#
#       # Append child element.
#       # TODO: Need to check schema for multiple?
#
#       def element_append(name, *args, &block)
#         name = name.to_sym
#         kind = xml_schema_elements[name][0]
#         if kind <= Element
#           e = kind.new(name, *args, &block)
#         else
#           e = Data.new(name, kind.new(*args, &block))
#         end
#         element_tracker[name] ||= []
#         element_tracker[name] << e
#         element_content << e
#       end

      public

      # Convert to XML formatted string.

      def to_xml(ns=nil)
        body = to_xml_body(ns)
        atts = to_xml_attrs(ns)
        atts = ' ' + atts unless atts.empty?
        if body.empty?
          "<#{element_tagname}#{atts}/>"
        else
          "<#{element_tagname}#{atts}>#{body}</#{element_tagname}>"
        end
      end

      private

      # Build up content.
      def to_xml_body(ns)
        body = []
        element_content.collect do |e|
          body << e.to_xml(ns)
        end
        body.join('').strip
      end

      public

      # Convert to REXML element. You must first load
      # rexml/document, for this to work.

      def to_rexml
        node = REXML::Element.new(element_tagname)

        node.add_namespace(xml_schema_namespace) if xml_schema_namespace

        element_attributes.each do |k, v|
          next unless v
          #if v.is_a?(Attribute)
            node.add_attribute(v.to_rexml) if v
          #else
          #  node.add_attribute(k,v)
          #end
        end

        element_content.each do |element|
          node.add_element(element.to_rexml) #(xml_namespace)
          #if obj.is_a? Node
            node.add_element(element.to_rexml) #(xml_namespace)
          #else
          #  node.add_element(REXML::Element.new(name, element.to_s))
          #end
        end

        return node
      end

      # Convert to LibXML element.

      #def to_libxml
      #end
    end

  end

end
