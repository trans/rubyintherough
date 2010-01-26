# = TITLE:
#
#   RSS Feed
#
# = SUMMARY:
#
#   Uses XMLDesignKit to provide an RSS builder class.
#
# = COPYING
#
#   Blow/RSS, Copyright (c) 2007 Thomas Sawyer
#
#   BSD License
#
# = AUTHORS:
#
#   - Thomas Sawyer (trans)

require "xdk/designkit"
#require "time"

module XDK

  # RSS2 markup toolspace.

  module RSS2

    include DesignKit

    # Create an RSS feed document.

    def self.document(atts=nil, &block)
      Document.new(atts, &block)
    end

    # Create an Atom feed document. This is an alias for #doc which
    # is a little more semantically helpful.

    def self.channel(atts=nil, &block)
      Document.new(atts, &block)
    end

    # = Source
    #
    # <source> is an optional sub-element of <item>.
    #
    # Its value is the name of the RSS channel that the item came from, derived
    # from its <title>. It has one required attribute, url, which links to the
    # XMLization of the source.
    #
    #   <source url="http://www.tomalak.org/links2.xml">Tomalak's Realm</source>
    #
    # The purpose of this element is to propagate credit for links, to publicize
    # the sources of news items. It can be used in the Post command of an aggregator.
    # It should be generated automatically when forwarding an item from an aggregator
    # to a weblog authoring tool.

    class Source < Data
      attribute :url
    end

    # = Enclosure> sub-element of <item>.
    #
    # <enclosure> is an optional sub-element of <item>.
    #
    # It has three required attributes. url says where the enclosure is located,
    # length says how big it is in bytes, and type says what its type is, a standard MIME
    # type.
    #
    # The url must be an http url.
    #
    #   <enclosure url="http://www.scripting.com/mp3s/weatherReportSuite.mp3"
    #       length="12216320" type="audio/mpeg" />

    class Enclosure < Tag
      attribute :url    , :required => true
      attribute :length , :required => true
      attribute :type   , :required => true
    end

    # = Category
    #
    # <category> is an optional sub-element of <item>.
    #
    # It has one optional attribute, domain, a string that identifies a categorization taxonomy.
    #
    # The value of the element is a forward-slash-separated string that identifies a
    # hierarchic location in the indicated taxonomy. Processors may establish conventions
    # for the interpretation of categories. Two examples are provided below:
    #
    #   <category>Grateful Dead</category>
    #
    #   <category domain="http://www.fool.com/cusips">MSFT</category>
    #
    # You may include as many category elements as you need to, for different domains, and
    # to have an item cross-referenced in different parts of the same domain.

    class Category < Data
      attribute :domain
    end

    # = PubDate
    #
    # <pubDate> is an optional sub-element of <item>.
    #
    # Its value is a date, indicating when the item was published. If it's a date in
    # the future, aggregators may choose to not display the item until that date.
    #
    #   <pubDate>Sun, 19 May 2002 15:21:36 GMT</pubDate>

    #class PubDate < Data
    #end

    # <= GUID
    #
    # <guid> is an optional sub-element of <item>.
    #
    # guid stands for globally unique identifier. It's a string that uniquely identifies
    # the item. When present, an aggregator may choose to use this string to determine
    # if an item is new.
    #
    #   <guid>http://some.server.com/weblogItem3207</guid>
    #
    # There are no rules for the syntax of a guid. Aggregators must view them as a string.
    # It's up to the source of the feed to establish the uniqueness of the string.
    #
    # If the guid element has an attribute named "isPermaLink" with a value of true, the
    # reader may assume that it is a permalink to the item, that is, a url that can be
    # opened in a Web browser, that points to the full item described by the <item> element.
    # An example:
    #
    #   <guid isPermaLink="true">http://inessential.com/2002/09/01.php#a2</guid>
    #
    # isPermaLink is optional, its default value is true. If its value is false, the guid
    # may not be assumed to be a url, or a url to anything in particular.

    class Guid < Data
      attribute :isPermaLink
    end

    # = Comments
    #
    # <comments> is an optional sub-element of <item>.
    #
    # If present, it is the url of the comments page for the item.
    #
    #   <comments>http://ekzemplo.com/entry/4403/comments</comments>

    #class Comments < Data
    #end

    # = Author
    #
    # <author> is an optional sub-element of <item>.
    #
    # It's the email address of the author of the item. For newspapers and magazines
    # syndicating via RSS, the author is the person who wrote the article that the
    # <item> describes. For collaborative weblogs, the author of the item might be
    # different from the managing editor or webmaster. For a weblog authored by a
    # single individual it would make sense to omit the <author> element.
    #
    #   <author>lawyer@boyer.net (Lawyer Boyer)</author>

    #class Author < Data
    #end

    # = Item
    #
    # A channel may contain any number of <item>s. An item may represent a "story"
    # --much like a story in a newspaper or magazine; if so its description is a synopsis
    # of the story, and the link points to the full story. An item may also be complete
    # in itself, if so, the description contains the text (entity-encoded HTML is allowed;
    # see examples), and the link and title may be omitted. All elements of an item are
    # optional, however at least one of title or description must be present.

    class Item < Map
      element :title
      element :link
      element :description
      element :author      #, Author
      element :comments    #, Comments
      element :enclosure   , Enclosure
      element :guid        , Guid
      element :pubDate     #, PubDate
      element :source      , Source

      # Multiple elements.
      element :category    , Category , :multiple => true
    end

    # = TextInput
    #
    # A channel may optionally contain a <textInput> sub-element,
    # which contains four required sub-elements.
    #
    #   <title> -- The label of the Submit button in the text input area.
    #
    #   <description> -- Explains the text input area.
    #
    #   <name> -- The name of the text object in the text input area.
    #
    #   <link> -- The URL of the CGI script that processes text input requests.
    #
    # The purpose of the <textInput> element is something of a mystery. You can
    # use it to specify a search engine box. Or to allow a reader to provide
    # feedback. Most aggregators ignore it.

    class TextInput < Map
      element :title       , :required => true
      element :description , :required => true
      element :name        , :required => true
      element :link        , :required => true
    end

    # = TTL
    #
    #
    # <ttl> is an optional sub-element of <channel>.
    #
    # ttl stands for time to live. It's a number of minutes that indicates how
    # long a channel can be cached before refreshing from the source. This makes
    # it possible for RSS sources to be managed by a file-sharing network such
    # as Gnutella.
    #
    # Example: <ttl>60</ttl>

    #class TimeToLive < Data
    #end

    # = Cloud
    #
    # <cloud> is an optional sub-element of <channel>.
    #
    # It specifies a web service that supports the rssCloud interface which can
    # be implemented in HTTP-POST, XML-RPC or SOAP 1.1.
    #
    # Its purpose is to allow processes to register with a cloud to be notified
    # of updates to the channel, implementing a lightweight publish-subscribe
    # protocol for RSS feeds.
    #
    #   <cloud domain="rpc.sys.com" port="80" path="/RPC2"
    #       registerProcedure="myCloud.rssPleaseNotify" protocol="xml-rpc" />
    #
    # In this example, to request notification on the channel it appears in, you
    # would send an XML-RPC message to rpc.sys.com on port 80, with a path of /RPC2.
    # The procedure to call is myCloud.rssPleaseNotify.
    #
    # A full explanation of this element and the rssCloud interface is here.

    class Cloud < Tag
      attribute :domain
      attribute :port
      attribute :path
      attribute :registerProcedure
      attribute :protocol
    end

    # = Image
    #
    # <image> is an optional sub-element of <channel>, which contains three required
    # and three optional sub-elements. Required:
    #
    #   <url> is the URL of a GIF, JPEG or PNG image that represents the channel.
    #
    #   <title> describes the image, it's used in the ALT attribute of the HTML
    #       <img> tag when the channel is rendered in HTML.
    #
    #   <link> is the URL of the site, when the channel is rendered, the image is
    #       a link to the site. (Note, in practice the image <title> and <link>
    #       should have the same value as the channel's <title> and <link>.
    #
    # Optional elements:
    #
    #   <width> is a number indicating the width of the image in pixels.
    #       Maximum value for width is 144, default value is 88.
    #
    #   <height> is a number indicating the height of the image in pixels.
    #       Maximum value for height is 400, default value is 31.
    #
    #   <description> contains text that is included in the TITLE attribute of the
    #       link formed around the image in the HTML rendering.

    class Image < Map
      element :url   ,          :required => true
      element :title ,          :required => true
      element :link  ,          :required => true
      element :width
      element :height
      element :description
    end

    # RSS 2.0 Channel, XML BlockUp document.
    #
    # Here's a list of the required channel elements, each with a brief description,
    # an example, and where available, a pointer to a more complete description.
    #
    #   title
    #     The name of the channel. It's how people refer to your service.
    #     If you have an HTML website that contains the same information
    #     as your RSS file, the title of your channel should be the same
    #     as the title of your website. [GoUpstate.com News Headlines]
    #
    #   link
    #     The URL to the HTML website corresponding to the channel.
    #     [http://www.goupstate.com/]
    #
    #   description
    #     Phrase or sentence describing the channel.
    #     [The latest news from GoUpstate.com, a Spartanburg Herald-Journal Web site.]
    #
    # Optional channel elements.
    #
    #   language
    #     The language the channel is written in. This allows aggregators
    #     to group all Italian language sites, for example, on a single page.
    #     A list of allowable values for this element, as provided by Netscape,
    #     is here. You may also use values defined by the W3C. [en-us]
    #
    #   copyright
    #     Copyright notice for content in the channel. [Copyright 2002, Spartanburg Herald-Journal]
    #
    #   managingEditor
    #     Email address for person responsible for editorial content.
    #     [geo@herald.com (George Matesky)]
    #
    #   webMaster
    #     Email address for person responsible for technical issues relating to channel.
    #     [betty@herald.com (Betty Guernsey)]
    #
    #   pubDate
    #     The publication date for the content in the channel. For example,
    #     the New York Times publishes on a daily basis, the publication date
    #     flips once every 24 hours. That's when the pubDate of the channel changes.
    #     All date-times in RSS conform to the Date and Time Specification of RFC 822,
    #     with the exception that the year may be expressed with two characters or
    #     four characters (four preferred). [Sat, 07 Sep 2002 00:00:01 GMT]
    #
    #   lastBuildDate
    #     The last time the content of the channel changed. [Sat, 07 Sep 2002 09:42:31 GMT]
    #
    #   category
    #     Specify one or more categories that the channel belongs to. Follows
    #     the same rules as the <item>-level category element. More info.
    #     <category>Newspapers</category>
    #
    #   generator
    #     A string indicating the program used to generate the channel.
    #     [MightyInHouse Content System v2.3]
    #
    #   docs
    #     A URL that points to the documentation for the format used in the RSS file.
    #     It's probably a pointer to this page. It's for people who might stumble across
    #     an RSS file on a Web server 25 years from now and wonder what it is.
    #     [http://blogs.law.harvard.edu/tech/rss]
    #
    #   cloud
    #     Allows processes to register with a cloud to be notified of updates to
    #     the channel, implementing a lightweight publish-subscribe protocol for
    #     RSS feeds. More info here.
    #
    #       <cloud domain="rpc.sys.com" port="80" path="/RPC2" registerProcedure="pingMe" protocol="soap"/>
    #
    #   ttl
    #     ttl stands for time to live. It's a number of minutes that indicates how
    #     long a channel can be cached before refreshing from the source. [<ttl>60</ttl>]
    #
    #   image
    #     Specifies a GIF, JPEG or PNG image that can be displayed with the channel. More info here.
    #     rating The PICS rating for the channel.
    #
    #   textInput
    #     Specifies a text input box that can be displayed with the channel. More info here.
    #
    #   skipHours
    #     A hint for aggregators telling them which hours they can skip. More info here.
    #
    #   skipDays
    #     A hint for aggregators telling them which days they can skip. More info here.

    class Channel < Map
      #namespace "http://" #, 'rss2'  # FIXME

      # Required elements.
      element :title            , :required => true
      element :description      , :required => true
      element :link             , :required => true

      # Optional elements.
      element :language
      element :copyright
      element :managingEditor
      element :webMaster
      element :pubDate
      element :lastBuildDate
      element :generator
      element :docs
      element :cloud       , Cloud
      element :ttl         #, TimeToLive
      element :image       , Image
      element :rating
      element :textInput   , TextInput
      element :skipHours
      element :skipDays

      # Multiple elements.
      element :category    , Category , :multiple => true
      element :item        , Item     , :multiple => true
    end

    # RSS document.
    #
    # NOTE: RSS doesn't seem to have an official namespace.

    class Document < Channel
      #namespace "http://" #, 'rss2'

      def initialize(atts, &block)
        super('channel', atts, &block)
      end

      def to_xml
        %[<?xml version="1.0" encoding="UTF-8"?>\n] + super
      end
    end

  end

  # Let RSS stand for version 2.
  # TODO: Good idea for RSS = RSS2 ?

  RSS = RSS2

end



rss = Blow::RSS.document do
  title "Test RSS Feed"
  description "This is to show that RSS feeds can be generated with designkit."
  link "http://nitroproject.org/"
end

puts rss.to_xml

