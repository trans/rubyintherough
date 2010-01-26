require "blow/designkit"

module Blow

  # ATOM markup toolspace.

  class Atom

    class Title
      attribute :type
    end

    class Generator < Value
      attribute :uri
      attribute :version
    end

    class Link < Tag
      attribute :rel
      attribute :type
      attribute :href
      attribute :hreflang

      # The xhtml type expects a div element, but
      # we won't bother to validate that.
      #validate :type do
      #  %w{'text', 'html', 'xhtml'}.include?(@_type.to_s.downcase)
      #end
    end

    # Atom Person element.

    class Person < Element
      namespace 'atom'

      element :name  , Value
      element :email , Value
      element :uri   , Value
    end

    #

    class Category < Element #OpenElement
      attribute  :term, nil, :required => true

      attribute :scheme
      attribute :label
    end

    # Atom Entry

    class Entry < Element
      namespace 'atom'

      element :id          , Value  , :required => true
      element :title       , Title  , :required => true
      element :updated     , Value  , :required => true

      element :summary     , Value
      element :published   , Value
      element :content     , Value
      element :source      , Value
      element :rights      , Value

      elements :link        , Link
      elements :category    , Value
      elements :author      , Person
      elements :contributor , Person

      #open_elements
    end

    # Atom Feed, XML BlockUp document.

    class Feed
      #, :namespace => 'xml'
      attr_accessor :base
      attr_accessor :lang

      # Required elements.
      attr_accessor :id
      attr_accessor :title
      attr_accessor :title_type
      attr_accessor :updated

      # Optional elements.
      attr_accessor :subtitle

      def generator(&b)
        if block_given?
          @generator = Generator.new(&b)
        else
          @generator
        end
      end

      attr_accessor :icon
      attr_accessor :logo
      attr_accessor :rights

      # Multiple elements.
      attr_reader :links
      def link(&b) ; @links << Link.new(&b) ; end

      attr_reader :categories
      def category(&b) ; @categories << Category.new(&b) ; end

      attr_reader :authors
      def author(&b) ; @authors << Person.new(&b) ; end

      attr_reader :contributors
      def contributor(&b) ; @contributor << Person.new(&b) ; end

      attr_reader :entry
      def author(&b) ; @authors << Entry.new(&b) ; end

      # Convert to XML.
      def to_xml
        x = ''
        x << %[<feed xmlns="http://www.w3.org/2005/Atom">]
        x << %[<id>#{id}</title>]
        x << %[<title type="#{title_type}">#{title}</title>]
        x << %[<updated>#{updated}</updated>]
        x << %[<icon>#{icon}</icon>] if icon
        x << %[<logo>#{logo}</logo>] if logo
        x << %[<rights>#{rights}</rights>] if rights
        links.each do |link|
          x << link.to_xml
        end
        authors.each do |author|
          x << author.to_xml
        end
        contributors.each do |contributor|
          x << contributor.to_xml
        end
        categories.each do |category|
          x << category.to_xml
        end
        entries.each do |entry|
          x << entires.to_xml
        end
        x << %[</feed>]
      end
    end

    # Create an Atom feed.
    def self.feed(&block)
      Feed.new('feed', &block)
    end
  end

end


# Demo.

if $0 == __FILE__

    sample = Blow::Atom.feed do |s|
      s.author do |e|
       e.name 'Tom'
       e.email 'trans@ggmail.nut'
      end
      s.title "YEPPY!"
      s.entry do |e|
        e.author do |a|
          a.name = "John Doe"
        end
      end
      s.entry do |e|
        e.author do |a|
          a.name = "Jank X"
        end
      end
    end

    puts sample.to_xml

    sample2 = Blow::Atom.feed do
      author do
       name "Tom"
       email "trans@ggmail.nut"
      end
      title "YEPPY!"
      entry do
        author do
          name "John Doe"
        end
      end
      entry do
        author do
          name "Jank X"
        end
      end
    end

    puts sample2.to_xml

end
