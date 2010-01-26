# = TITLE:
#
#   HTML
#
# = SUMMARY:
#
#   HTML Markup library.
#
# = AUTHORS:
#
#   - 7rans
#
# = COPYRIGHT:
#
#   Copyright (c) 2007 7rans
#
# = LICENSE:
#
#   Ruby License
#
#   This module is free software. You may use, modify, and/or redistribute this
#   software under the same terms as Ruby.
#
#   This program is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#   FOR A PARTICULAR PURPOSE.

require 'cgi'  # TODO deprecate use of CGI
require 'blow/xml.rb'

module Blow

  # = Html
  #
  # Markup for HTML/XHTML documents.
  #
  # == Synopsis
  #
  #   # TODO
  #

  module Html
    include Xml

    extend self  #module_function

    # Start a new bare document.
    def self.new
      BuildingBlock.new(self, :element)
    end

    # Start a new document with <html> tag.
    def self.doc(*a,&b)
      BuildingBlock.new(self, :element).html(*a,&b)
    end

    # Create an hidden input field through which an object can can be marshalled.
    # This makes it very easy to pass from data betwenn requests.
    def marshal_to_cgi(name, iobj)
      data = CGI.escape(Marshal.dump(iobj))
      return %Q{<input type="hidden" name="__#{name}__" value="#{data}"/>\n}
    end

    # Create an hidden input field through which an object can can be marshalled.
    # This makes it very easy to pass from data between requests.
    def marshal_from_cgi(name)
      if self.params.has_key?("__#{name}__")
        return Marshal.load(CGI.unescape(self["__#{name}__"][0]))
      end
    end

    # Are these two good enough to replace CGI.escape?

    # Return an html "safe" version of the string,
    # where every &, < and > are replaced with appropriate entities.
    def esc(str)
      str.gsub(/&/,'&amp;').gsub(/</,'&lt;').gsub(/>/,'&gt;')
    end

    # Calls #esc, and then further replaces carriage returns and quote characters with entities.
    def escformat(str)
      esc(str).gsub(/[\r\n]+/,'&#13;&#10;').gsub(%r|"|,'&quot;').gsub(%r|'|,'&#39;')
    end

  end

end

=begin scrap

if defined? CGI
  class CGI
   include CGISupport
   class << self
     alias :escape_html :escapeHTML
     alias :unescape_html :unescapeHTML
     alias :escape_element :escapeElement
     alias :unescape_element :unescapeElement
   end
  end
end

if defined? FCGI
  class FCGI
    include CGISupport
  end
end

=end

