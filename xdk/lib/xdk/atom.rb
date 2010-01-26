# = TITLE:
#
#   Atom Feed
#
# = SUMMARY:
#
#   Uses XMLDesignKit to provide an ATOM builder class.
#
# = COPYING
#
#   Blow/Atom, Copyright (c) 2007 Thomas Sawyer
#
#   BSD License
#
# = AUTHORS:
#
#   - Thomas Sawyer (trans)
#
# = TODO:
#
#   - Need to open up some of the elements b/c
#     Atom feeds allow arbitrary content.

require "xdk/designkit"
require "time"


module XDK

  # ATOM markup toolspace.

  module Atom

    include DesignKit

    # Create an Atom feed document.

    def self.doc(atts=nil, &block)
      Document.new(atts, &block)
    end

    # Create an Atom feed document. This is an alias for #doc which
    # is a little more semantically helpful.

    def self.feed(atts=nil, &block)
      Document.new(atts, &block)
    end

    # Atom Time

    class Time < ::Time # :nodoc:
      def self.new date
        return if date.nil?

        date = if date.respond_to?(:iso8601)
          date
        else
          Time.parse(date.to_s)
        end

        def date.to_s
          iso8601
        end

        date
      end
    end

    # Atom Title

    class Title < Data
      attribute :type, :default => "html"
    end

    # Atom Generator

    class Generator < Data
      attribute :uri
      attribute :version
    end

    # Atom Link

    class Link < Tag
      attribute :href, :required => true
      attribute :hreflang
      attribute :rel
      attribute :type
      attribute :title
      attribute :length

      def initialize(name=nil, attrs=nil)
        super
        self["rel"] = "self"
      end
    end

    # Atom Person

    class Person < Map
      element :name
      element :email
      element :uri
    end

    # Atom Person

    class Content < Data
      attribute :type
      attribute :src

      def to_xml_body(ns)
        string = element_value.to_s.strip
        case self[:type].value.downcase
        when 'xhtml'
          "<div>#{element_value.to_s}</div>"
        when /[+\/]xml$/
          element_value.to_s  # assumes valid XML document
        else # 'text', 'html'
          xml_escape(element_value.to_s)
        end
      end
    end

    # Atom Category

    class Category < Open
      attribute  :term, :required => true

      attribute :scheme
      attribute :label
    end

    # Atom Entry

    class Entry < Map
      element :id                   , :required => true
      element :title       , Title  , :required => true
      element :updated     , Time   , :required => true

      element :summary
      element :published   , Time
      element :content     , Content
      element :source
      element :rights

      element :link        , Link
      element :category    , Category
      element :author      , Person
      element :contributor , Person

      #open_elements
    end

    # Atom Feed, XML BlockUp document.

    class Feed < Map
      namespace "http://www.w3.org/2005/Atom" #, 'atom'

      # Required elements.
      element :id                   , :required => true
      element :updated              , :required => true
      element :title       , Title  , :required => true

      # Optional elements.
      element :subtitle    , Title
      element :generator   , Generator
      element :icon
      element :logo
      element :rights

      # Multiple elements.
      element :link        , Link     , :multiple => true
      element :category    , Category , :multiple => true
      element :author      , Person   , :multiple => true
      element :contributor , Person   , :multiple => true
      element :entry       , Entry    , :multiple => true
    end

    # Atom document.

    class Document < Feed
      namespace "http://www.w3.org/2005/Atom" #, 'atom'

      def initialize(atts, &block)
        super('feed', atts, &block)
      end

      def to_xml
        %[<?xml version="1.0" encoding="UTF-8"?>\n] + super
      end
    end

  end

end



=begin demo
    puts

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

    puts

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

    puts

=end
