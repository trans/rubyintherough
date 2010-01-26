#!/usr/bin/env ruby

require 'cgi'
require 'yaml'
require 'erb'

class APIWiki

  PASS = CGI.unescape("%64%6f%67")

  ROOT = File.dirname(__FILE__)

  HOME = 'HomePage'
  LINK = 'wiki.cgi?name=%s'

  attr_reader :query, :report

  attr_reader :parts, :template

  def initialize()
    @query = CGI.new('html4')
    @template = File.read(File.join(File.dirname(__FILE__), 'page.rhtml'))
  end

  def page_file
    @page_file ||= File.join(ROOT, 'pages', page_name)
  end

  def page_list
    files = []
    Dir.chdir(File.join(ROOT, 'pages')) do
      files = Dir.glob('**/*').select{ |f| File.file?(f) }
    end
    files = files - ['HomePage']
    files.sort
  end

  #

  def page_name
    name = query['name']
    name = HOME unless /\S/ =~ name
    name
  end

  #

  def page_changes
    query['changes']
  end

  #

  def edit?
    edit = query['edit']
    edit = nil unless /\S/ =~ edit
    edit
  end

  def debug?
    dbug = query['debug']
    dbug = nil unless /\S/ =~ dbug
    dbug
  end

  def passcode
    query['passcode']
  end

  # fetch file content for this page, unless it's a new page.

  def content
    @content ||= File.read(page_file) rescue content = ''
  end

  # save page changes, if needed
  def save
    unless page_changes == ''
      if file?(page_file) and passcode == PASS
        content = page_changes #CGI.escapeHTML(page_changes)
        File.open(page_file, 'w') { |f| f.write content }
      else
        @report = "Save of #{page_name} failed!"
      end
    end
  end

  def out
    output = ERB.new(template).result(binding)
    query.out{ output }
  end

  def parsed_content
    content.gsub(/([A-Z]\w+){2}/) do |match|
      query.a(LINK % match) { match }
    end
  end

  def debug_output
    s = ''
    s << page_name << "\n"
    s << PASS << "\n"
    s << query.to_yaml << "\n"
  end

  def go!
    save
    out
  end

  # Make sure a valid file path.

  def file?(path)
    return false if /\~/ =~ path
    return false if /\.\./ =~ path
    File.file?(path)
  end

  # def page
  #   html = ''
  #   html << "<html>"
  #   html << metadata
  #   html << %[<body>\n]
  #   html << %[<div class="content">\n]
  #   html << header
  #   html << body
  #   html << footer
  #   html << %[</div>\n]
  #   html << %[</body>\n]
  #   html << "</html>"
  # end
  #
  # def metadata
  #   s = ''
  #   s << %[\n]
  #   s << %[<head>]
  #   s << %[<title>Facets Wiki</title>\n]
  #   s << %[<link rel="stylesheet" type="text/css" href="style.css"/>\n]
  #   s << %[</head>]
  #   s << %[\n]
  # end
  #
  # def header
  #   s = ""
  #   s << %[<div class="header">]
  #   s << %[<h1>Facets API Wiki</h1>]
  #   s << %[<h2>#{page_name}</h2>]
  #   s << %[<a href="#{LINK % HOME}">#{HOME}</a>]
  #   s << %[<div/>]
  #   s << %[\n]
  # end
  #
  # def body
  #   s = ''
  #   s << aside
  #
  #   s << %[<pre>]
  #   s << content.gsub(/([A-Z]\w+){2}/) do |match|
  #          a(LINK % match) { match }
  #        end
  #   s << %[</pre>\n]
  #
  #   s << %[<form method="POST">]  #form('get')
  #   s << %[<textarea name="changes">#{content}</textarea>]
  #   s << %[<hidden name="page_name" value="#{page_name}"/>\n]
  #   s << %[<input type="submit">]
  #   s << %[</form>\n]
  # end
  #
  # def aside
  #   s = ''
  #   s << %[<div class="pages_menu" style="float: left;">]
  #   s << page_list.collect do |file|
  #          %[<a href="pages/#{file}">#{file}</a> <br/>]
  #        end.join("\n")
  #   s << %[</div>]
  # end
  #
  # def footer
  #   s = ''
  #   s << "<hr/>"
  #   s << "<pre>#{debug_output}</pre>\n"
  # end


end

APIWiki.new.go!

# # output requested page
# query.instance_eval do
#   out do
#     h1 { page_name } +
#     a(LINK % HOME) { HOME } +
#     pre do            # content area
#       content.gsub(/([A-Z]\w+){2}/) do |match|
#         a(LINK % match) { match }
#       end
#     end +
#     form('get') do    # update from
#       textarea('changes') { content } +
#       hidden('name', page_name) +
#       submit
#     end
#     pre do
#
#     end
#   end
# end
