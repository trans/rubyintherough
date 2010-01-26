require "rexml/document"
require "time"
require "uri"

# ATOM (GData) loader / dumper

module ATOM

  # The content type.

  setting :content_type, :default => "text/html", :doc => "The content type"

  class << self

    #include Raw::Markup

    def load(atom)
    end

    # Return an ATOM string corresponding to the Ruby object
    # +obj+.

    def dump(obj_or_enumerable, options = {})
      if obj_or_enumerable.is_a? Enumerable
        dump_enumerable(obj_or_enumerable, options)
      else
        dump_object(obj_or_enumerable, options)
      end
    end

  private

    #  def markup(str)
    #    str.gsub(/\n/, "<br />")
    #  end

    def dump_object(obj, options = {})
      xml = "<entry>"

        xml << "<id>#{Context.current.host_uri}#{obj.to_href}</id>"
        xml << %{<title type="text">#{obj.title}</title>} # use to_s ??
        xml << %{<link rel="alternate" href="#{Context.current.host_uri}#{obj.to_href}" />}

        if obj.respond_to?(:author) && obj.author
          xml << "<author>">
          if obj.author.is_a? String
            xml << "<name>#{obj.author}</name>"
          else
            xml << "<name>#{obj.author}</name>"

            if obj.author.respond_to? :uri
              xml << "<uri>#{obj.author.uri}</uri>"
            end
          end
          xml << "</author>"
        end

        if obj.respond_to? :summary
          xml << "<summary>#{CGI.escapeHTML(markup(obj.summary))}</summary>"
        end

        if ATOM.content_type == "text/html"
          xml << %{<content type="html">#{CGI.escapeHTML(markup(obj.body))}</content>}
        else
          xml << %{<content>#{obj.body}</content>}
        end

        if (obj.respond_to? :update_time) and obj.update_time
          xml << "<updated>#{obj.update_time.iso8601}</updated>"
        end

        if obj.respond_to? :create_time and obj.create_time
          xml << "<published>#{obj.create_time.iso8601}</published>"
        end

        # More stuff:
        #
        # category
        # could be used for Tags maybe?
        # contributor
        # published
        # source
        # rights

      xml << "</entry>"

      return xml
    end

    def dump_enumerable(collection, options = {})
      xml = %{<?xml version="1.0" encoding="UTF-8"?>}

      xml << %{<feed xmlns="http://www.w3.org/2005/Atom" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" >}

        id = URI.parse(options[:id]).normalize
        xml << "<id>#{id}</id>"

        title = options[:title] || "Syndication"
        xml << %{<title type="text">#{title}</title>}

        update_time = collection.map(&:update_time).max
        xml << "<updated>#{update_time.iso8601}</updated>"

        if link = options[:link]
          xml << %{<link rel="self" href="#{link}" />}
        end

        # author stuff.

        xml << %{<generator uri="http://www.nitroproject.org" version="#{Nitro::Version}">Nitro</generator>}

        # More stuff:
        #
        # category
        # contributor
        # icon
        # logo
        # rights
        # subtitle

        for obj in collection
          # next unless obj.respond_to?(:to_href) and obj.respond_to?(:title)
          xml << dump_object(obj)
        end

      xml << %{</feed>}

      return xml
    end

  end

end

class Object

  # Dump object as ATOM.

  def to_atom(*args)
    ATOM.dump(self, *args)
  end

end
