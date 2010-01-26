require 'rbconfig'

module Rain

  # Rain Servlet

  class Servlet < ::WEBrick::HTTPServlet::AbstractServlet

    def self.go
      fork do
        server = WEBrick::HTTPServer.new( :Port=>9996 )
        server.mount "/rain", self #Rain::Servlet
        trap("INT"){ server.shutdown }
        server.start
      end
    end

    def initialize(server)
      super(server)
      @rain = WebController.new
    end

    def page; @rain; end
    #attr :page

    def do_GET(request, response)
      status, content_type, body = rain_respond( request )

      response.status = status
      response['Content-Type'] = content_type
      response.body = body
    end

    def rain_respond( request )
      status = 200
      body = ''

      case request.path_info
      when '', '/'
        body = page.main
      when '/drops'
        body = rain.drops
      when '/list'
        body = rain.list
      when '/lookup'
        body = rain.lookup
      when '/debug'
        body = "<pre>#{request.to_yaml}</pre>"
      else
        body = "Error"
      end

      return status, "text/html", body
    end

  end


  class WebController < Controller

    def initialize
      @webdir = File.join( Config::CONFIG['datadir'], 'site_ruby/rain/webpage' )
    end

    def wrap_body( body )
      s = ''
      s << %{<html>}
      s << %{<head>}
      s << %{<title>Rain</title>}
      s << %{</head>}
      s << %{<body>}
      s << body
      s << %{</body>}
      s << %{</html>}
      s
    end

    # main
    def main
      page = File.read( File.join( @webdir, 'main.html' ) )
      page
    end

    def drops( rfs )
      s = ''
      rfs.each do |rf|
        s << %{<div class="drop">}
        s << %{<span class="title">#{rf.title}</span> (#{rf.name}) &nbsp;}
        s << %{<a href="http://localhost:9996/uninstall?drop=${rf.name}">Update</a> &nbsp;}
        s << %{<a href="http://localhost:9996/uninstall?drop=${rf.name}">Uninstall</a> <br/>}
        s << %{<span class="desc">#{rf.description}</span><br/>}
        s << %{</div>}
      end
      page = File.read( File.join( @webdir, 'drops.html' ) )
      page.gsub('<?r drops?>', s)
    end

    # for catalog

    def list( entries )
      b = ''
      entries.each { |e| b << %{<a href="">#{e}</a><br/>} }
      wrap_body( b )
    end

    def show_brief( runfile )
      b = ''
      b << %{<span class="title">#{runfile.title} v#{runfile.version}</span><br/><br/>}
      b << %{<p>#{runfile.description}</p>}
      wrap_body( b )
    end

    def show_detail( runfile )
      b = ''
      b << %{<span class="title">#{runfile.title} v#{runfile.version}</span><br/><br/>}
      b << %{<pre>#{runfile.to_yaml}</pre>}
      wrap_body( b )
    end

    def resource_not_found( file )
      b = %{Resource not found for '#{file}'.}
      wrap_body( b )
    end

    # general reporting

    def report( msg )
      wrap_body( msg )
    end

    # for downloader

    def preparing_to_download( file, url, est_size )
      print "File: #{ file } "
      if est_size and est_size != 0
        print %{(#{est_size} KBytes)}
      end
      puts
      puts "URL: #{url}"
    end

    def lacks_checksum( checksum, type=:md5 )
      puts "Warn: Resource lacks #{type} checksum #{checksum}."
    end

    def lacks_size( size )
      puts "Warn: Resource lacks file size #{size}."
    end

    def downloaded( file )
      #puts "Downloaded #{file}."
    end

    def extracted( file )
      puts "Extracted #{file}."
    end

    # installed

    def installed( file )
      puts "Installed #{file}."
    end

    # if not an interface method

    def method_missing( sym, *args, &blk )
      warn "Interface does not respond to #{sym}."
    end

  end

end

