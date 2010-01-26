# TITLE:
#
#   XML Design Kit
#
# = SUMMARY:
#
#   XMLDesignKit provides a simple way to "schema" an
#   XML format, and then be able to use Ruby block-up
#   notation to build documents.
#
# = TODO:
#
#   - Add Namspace support [PARTLY DONE]
#   - Apply proper escapes (DONE, but minimalistic)
#   - Add validation support [DONE ?]
#   - Add open element support
#   - Generate DTD; possible?; entities?
#   - General parser (use REXML ?).
#   - Support class Mixed < (Element + Text) ?

module XDK

  # DesignKit provides a light-weight way to define
  # the structure of XML documents, creating a Ruby BlockUp
  # builder. Think of it as a simple DTD written in Ruby.

  module DesignKit
  end

end

require 'xdk/designkit/elements/tag'
require 'xdk/designkit/elements/data'
require 'xdk/designkit/elements/map'
require 'xdk/designkit/elements/full'
require 'xdk/designkit/elements/open'



=begin demo

  class Try < Blow::DesignKit::Map

    class ValueX < Data
      attribute :x
    end

    class ValueY < ValueX
    end

    element :a, ValueX
    element :b, ValueY
    element :c
    element :d, :multiple => true
  end

  t = Try.new('trying') do
    a 1, :x=>"hi"
    b 2, :x=>"bi"
    c "Here"
    d "And a one...", :k => "0"
    d "And a two..."
    c "Again"  # should overwrite "Here"
  end

  puts t.to_xml

=end

