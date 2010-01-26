require 'icli/abstract_host'

module ICli

  # This is the base class for all GForge adapters.
  # With any luck this will do for just about everything.
  #
  #  * release  - Upload release packages.
  #  * publish  - Upload site files.
  #  * announce - Post news announcement.

  class Gforge < AbstractHost

    include FileUtils

    #HOME    = ENV["HOME"] || ENV["HOMEPATH"] || File.expand_path("~")

    REPORT = /<h\d><span style="color:red">(.*?)<\/span><\/h\d>/

    # What commands does this host support.

    def commands
      %w{ touch release publish post }
    end

    # New RubyForge tasks.
    def initialize(options)
      options = super

      @project  = options[:project]
      @group_id = options[:group_id] || options[:groupid]

      @package_ids = {}
      @release_ids = {}
      @file_ids = {}

      load_project
    end

    public

    # Project name.
    attr_accessor :project

    # Project's group id number.
    attr_accessor :group_id

    # Username to use for project account.
    attr_accessor :username

    # Login to website.

    def login # :yield:
      page = @uri + "/account/login.php"
      page.scheme = 'https'
      page = URI.parse(page.to_s) # set SSL port correctly

      form = {
        "return_to"      => "",
        "form_loginname" => username,
        "form_pw"        => password,
        "login"          => "Login with SSL"
      }
      html = http_post(page, form)

      unless html[/Personal Page/]
        puts "Login failed."
        re1 = Regexp.escape(%{<h2 style="color:red">})
        re2 = Regexp.escape(%{</h2>})
        html[/#{re1}(.*?)#{re2}/]
        raise $1
      end

      if block_given?
        begin
          yield
        ensure
          logout
        end
      end
    end

    # Logout of website.

    def logout
      page = "/account/logout.php"
      form = {}
      http_post(page, form)
    end

    # Touch base with server -- login and logout.

    def touch(options={})
      login
      puts "Group ID: #{group_id}"
      puts "Login/Logout successful."
      logout
    end

    # Upload release packages to hosting service.
    #
    # This task releases files to RubyForge --it should work with other
    # GForge instaces or SourceForge clones too.
    #
    # While defaults are nice, you may want a little more control. You can
    # specify additional attributes:
    #
    #     files          package files to release.
    #     exclude        Package formats to exclude from files.
    #                    (from those created by pack)
    #     project        Project name on host (defaults to name)
    #     package        Package to which this release belongs (default to project)
    #     release        Release name (default is version number)
    #     version        Version of release
    #     date           Date of release (defaults to Time.now)
    #     processor      Processor/Architecture (any, i386, PPC, etc.)
    #     is_public      Public release? (defualts to true)
    #     changelog      Change log file
    #     notelog        Release notes file
    #
    # The release option can be a template by using %s in the
    # string. The version number of your project will be sub'd
    # in for the %s. This saves you from having to update
    # the release name before every release.
    #
    #--
    # What about releasing a pacman PKGBUILD?
    #++

    def release(options)
      options = options.rekey

      version   = options[:version]
      project   = options[:project]   || @project
      package   = options[:package]   || project
      release   = options[:release]   || version
      name      = options[:name]      || package
      files     = options[:file]      || []
      date      = options[:date]      || Time::now.strftime('%Y-%m-%d %H:%M')
      processor = options[:processor] || 'Any'
      store     = options[:store]     || 'pkg'
      changelog = options[:changelog]
      notelog   = options[:notelog]

      is_public = options[:is_public].nil? ? true : options[:is_public]

      raise ArgumentError, "missing group_id" unless group_id
      raise ArgumentError, "missing project"  unless project
      raise ArgumentError, "missing package"  unless package
      raise ArgumentError, "missing release"  unless release

      if files.empty?
        files = Dir.glob(File.join(store,"#{name}-#{version}*"))
      end

      files = files.reject{ |f| File.directory?(f) }

      abort "No package files." if files.empty?

      files.each do |file|
        abort "Not a file -- #{file}" unless File.exist?(file)
      end

      # which package types
      #rtypes = [ 'tgz', 'tbz', 'tar.gz', 'tar.bz2', 'deb', 'gem', 'ebuild', 'zip' ]
      #rtypes -= exclude
      #rtypes = rtypes.collect{ |rt| Regexp.escape( rt ) }
      #re_rtypes = Regexp.new('[.](' << rtypes.join('|') << ')$')

      puts "Releasing #{package} #{release}..." #unless options['quiet']

      login do

        unless package_id = package?(package)
          #unless options['force']
            q = "Package '#{package}' does not exist. Create?"
            a = ask(q, 'yN')
            abort "Task canceled." unless ['y', 'yes', 'okay'].include?(a.downcase)
          #end
          puts "Creating package #{package}..."
          abort "Cannot continue in dry-run mode." if dryrun?
          create_package(package, is_public)
          unless package_id = package?(package)
            raise "Package creation failed."
          end
        end
        if release_id = release?(release, package_id)
          #unless options[:force]
            q = "Release #{release} already exists. Re-release?"
            a = ask(q, 'yN')
            abort "Task canceled." unless ['y', 'yes', 'okay'].include?(a.downcase)
            #puts "Use -f option to force re-release."
            #return
          #end
          files.each do |file|
            fname = File.basename(file)
            if file_id = file?(fname, package)
              puts "Removing file #{fname}..."
              remove_file(file_id, release_id, package_id) unless dryrun?
            end
            puts "Adding file #{fname}..."
            add_file(file, release_id, package_id, processor) unless dryrun?
          end
        else
          puts "Adding release #{release}..."
          unless dryrun?
            add_release(release, package_id, files,
              :processor       => processor,
              :release_date    => date,
              :release_changes => changelog,
              :release_notes   => notelog,
              :preformatted    => '1'
            )
            unless release_id = release?(release, package_id)
              raise "Release creation failed."
            end
          end
          #files.each do |file|
          #  puts "Added file #{File.basename(file)}."
          #end
        end
      end
      puts "Release complete!"
    end

    #
    # Publish document to website.
    #

    def publish(options)
      options = options.rekey

      #domain = options[:domain] || DOMAIN
      root   = File.join(siteroot, project)
      root   = File.join(root, options[:root]) if options[:root]

      options.update(
        :host => domain,
        :root => root
      )

      UploadUtils.rsync(options)
    end

    # Submit a news item.

    def post(options)
      options = options.rekey

      if file = options[:file]
        text = File.read(file).strip
        i = text.index("\n")
        subject = text[0...i].strip
        message = text[i..-1].strip
      else
        subject = options[:subject]
        message = options[:message] || options[:body]
      end

      if dryrun?
        puts "\nSUBJECT: #{subject}"
        puts "\n#{message}\n\n"
      else
        post_news(subject, message)
        puts "News item posted!"
      end
    end


    private

    # HTTP POST transaction.

    def http_post(page, form, extheader={})
      client = HTTPClient::new ENV["HTTP_PROXY"]
      client.debug_dev = STDERR if ENV["ICLI_DEBUG"] || ENV["DEBUG"] || $DEBUG
      client.set_cookie_store(@cookie_jar)
      client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # HACK to fix http-client redirect bug/feature
      client.redirect_uri_callback = lambda do |uri, res|
        page = res.header['location'].first
        page =~ %r/http/ ? page : @uri + page
      end

      uri = @uri + page
      if $DEBUG then
        puts "POST #{uri.inspect}"
        puts "#{form.inspect}"
        puts "#{extheader.inspect}" unless extheader.empty?
        puts
      end

      response = client.post_content uri, form, extheader

      if response[REPORT]
        puts "(" + $1 + ")"
      end

      client.save_cookie_store

      return response
    end

    # Loads information for project: group_id, package_ids and release_ids.

    def load_project
      puts "Project: #{project}"

      html = URI.parse("http://#{domain}/projects/#{project}/index.html").read

      group_id = html[/(frs|tracker)\/\?group_id=\d+/][/\d+/].to_i
      @group_id = group_id

      if $DEBUG
        puts "GROUP_ID = #{group_id}"
      end

      html = URI.parse("http://rubyforge.org/frs/?group_id=#{group_id}").read

      package = nil
      html.scan(/<h3>[^<]+|release_id=\d+">[^>]+|filemodule_id=\d+/).each do |s|
        case s
        when /<h3>([^<]+)/ then
          package = $1.strip
        when /filemodule_id=(\d+)/ then
          @package_ids[package] = $1.to_i
        when /release_id=(\d+)">([^<]+)/ then
          package_id = @package_ids[package]
          @release_ids[[package_id,$2]] = $1.to_i
        end
      end

      if $DEBUG
        p @package_ids, @release_ids
      end
    end

    # Returns password. If not already set, will ask for it.

    def password
      @password ||= ENV['RUBYFORGE_PASSWORD']
      @password ||= (
        print "Password for #{username}: "
        until inp = $stdin.gets ; sleep 1 ; end ; puts
        inp.strip
      )
    end

    # Package exists? Returns package-id number.

    def package?(package_name)
      id = @package_ids[package_name]
      return id if id

      package_id = nil

      page = "/frs/"

      form = {
        "group_id" => group_id
      }
      scrape = http_post(page, form)

      restr = ''
      restr << Regexp.escape( package_name )
      restr << '\s*'
      restr << Regexp.escape( %{<a href="/frs/monitor.php?filemodule_id=} )
      restr << '(\d+)'
      restr << Regexp.escape( %{&group_id=#{group_id}} )
      re = Regexp.new( restr )

      md = re.match( scrape )
      if md
        package_id = md[1]
      end

      @package_ids[package_name] = package_id
    end

    # Create a new package.

    def create_package( package_name, is_public=true )
      page = "/frs/admin/index.php"

      form = {
        "func"         => "add_package",
        "group_id"     => group_id,
        "package_name" => package_name,
        "is_public"    => (is_public ? 1 : 0),
        "submit"       => "Create This Package"
      }

      http_post(page, form)
    end

    # Delete package.

    def delete_package(package_id)
      page = "/frs/admin/index.php"

      form = {
        "func"        => "delete_package",
        "group_id"    => group_id,
        "package_id"  => package_id,
        "sure"        => "1",
        "really_sure" => "1",
        "submit"      => "Delete",
      }

      http_post(page, form)
    end

    # Release exits? Returns release-id number.

    def release?(release_name, package_id)
      id = @release_ids[[release_name,package_id]]
      return id if id

      release_id = nil

      page = "/frs/admin/showreleases.php"

      form = {
        "package_id" => package_id,
        "group_id"   => group_id
      }
      scrape = http_post( page, form )

      restr = ''
      restr << Regexp.escape( %{"editrelease.php?group_id=#{group_id}} )
      restr << Regexp.escape( %{&amp;package_id=#{package_id}} )
      restr << Regexp.escape( %{&amp;release_id=} )
      restr << '(\d+)'
      restr << Regexp.escape( %{">#{release_name}} )
      re = Regexp.new( restr )

      md = re.match( scrape )
      if md
        release_id = md[1]
      end

      @release_ids[[release_name,package_id]] = release_id
    end

    # Add a new release.

    def add_release(release_name, package_id, *files)
      page = "/frs/admin/qrs.php"

      options = (Hash===files.last ? files.pop : {}).rekey
      files = files.flatten

      processor       = options[:processor]
      release_date    = options[:release_date]
      release_changes = options[:release_changes]
      release_notes   = options[:release_notes]

      release_date ||= Time::now.strftime("%Y-%m-%d %H:%M")

      file = files.shift
      puts "Adding file #{File.basename(file)}..."
      userfile = open(file, 'rb')

      type_id = userfile.path[%r|\.[^\./]+$|]
      type_id = FILETYPES[type_id]
      processor_id = PROCESSORS[processor.downcase]

      # TODO IS THIS WORKING?
      release_notes   = IO::read(release_notes) if release_notes and test(?f, release_notes)
      release_changes = IO::read(release_changes) if release_changes and test(?f, release_changes)

      preformatted = '1'

      form = {
        "group_id"        => group_id,
        "package_id"      => package_id,
        "release_name"    => release_name,
        "release_date"    => release_date,
        "type_id"         => type_id,
        "processor_id"    => processor_id,
        "release_notes"   => release_notes,
        "release_changes" => release_changes,
        "preformatted"    => preformatted,
        "userfile"        => userfile,
        "submit"          => "Release File"
      }

      boundary = Array::new(8){ "%2.2d" % rand(42) }.join('__')
      boundary = "multipart/form-data; boundary=___#{ boundary }___"

      html = http_post(page, form, 'content-type' => boundary)

      release_id = html[/release_id=\d+/][/\d+/].to_i
      puts "RELEASE ID = #{release_id}" if $DEBUG

      files.each do |file|
        puts "Adding file #{File.basename(file)}..."
        add_file(file, release_id, package_id, processor)
      end

      release_id
    end

    # File exists?
    #
    # NOTE this is a bit fragile. If two releases have the same exact
    # file name in them there could be a problem --that's probably not
    # likely, but I can't yet rule it out.
    #
    # TODO Remove package argument, it is no longer needed.

    def file?(file, package)
      id = @file_ids[[file, package]]
      return id if id

      file_id = nil

      page = "/frs/"

      form = {
        "group_id"   => group_id
      }
      scrape = http_post(page, form)

      restr = ''
      #restr << Regexp.escape( package )
      #restr << '\s*'
      restr << Regexp.escape( %{<a href="/frs/download.php/} )
      restr << '(\d+)'
      restr << Regexp.escape( %{/#{file}} )
      re = Regexp.new(restr)

      md = re.match(scrape)
      if md
        file_id = md[1]
      end

      @file_ids[[file, package]] = file_id
    end

    # Remove file from release.

    def remove_file(file_id, release_id, package_id)
      page="/frs/admin/editrelease.php"

      form = {
        "group_id"     => group_id,
        "package_id"   => package_id,
        "release_id"   => release_id,
        "file_id"      => file_id,
        "step3"        => "Delete File",
        "im_sure"      => '1',
        "submit"       => "Delete File "
      }

      http_post(page, form)
    end

    #
    # Add file to release.
    #

    def add_file(file, release_id, package_id, processor=nil)
      page = '/frs/admin/editrelease.php'

      userfile = open file, 'rb'

      type_id      = userfile.path[%r|\.[^\./]+$|]
      type_id      = FILETYPES[type_id]
      processor_id = PROCESSORS[processor.downcase]

      form = {
        "step2"        => '1',
        "group_id"     => group_id,
        "package_id"   => package_id,
        "release_id"   => release_id,
        "userfile"     => userfile,
        "type_id"      => type_id,
        "processor_id" => processor_id,
        "submit"       => "Add This File"
      }

      boundary = Array::new(8){ "%2.2d" % rand(42) }.join('__')
      boundary = "multipart/form-data; boundary=___#{ boundary }___"

      http_post(page, form, 'content-type' => boundary)
    end

    # Posts news item to +group_id+ (can be name) with +subject+ and +body+

    def post_news(subject, body)
      page = "/news/submit.php"

      form = {
        "group_id"     => group_id,
        "post_changes" => "y",
        "summary"      => subject,
        "details"      => body,
        "submit"       => "Submit"
      }

      http_post(page, form)
    end

    # Constant for file types accepted by Rubyforge

    FILETYPES = {
      ".deb"         => 1000,
      ".rpm"         => 2000,
      ".zip"         => 3000,
      ".bz2"         => 3100,
      ".gz"          => 3110,
      ".src.zip"     => 5000,
      ".src.bz2"     => 5010,
      ".src.tar.bz2" => 5010,
      ".src.gz"      => 5020,
      ".src.tar.gz"  => 5020,
      ".src.rpm"     => 5100,
      ".src"         => 5900,
      ".jpg"         => 8000,
      ".txt"         => 8100,
      ".text"        => 8100,
      ".htm"         => 8200,
      ".html"        => 8200,
      ".pdf"         => 8300,
      ".oth"         => 9999,
      ".ebuild"      => 1300,
      ".exe"         => 1100,
      ".dmg"         => 1200,
      ".tar.gz"      => 3110,
      ".tgz"         => 3110,
      ".gem"         => 1400,
      ".pgp"         => 8150,
      ".sig"         => 8150
    }

    # Constant for processor types accepted by Rubyforge

    PROCESSORS = {
      "i386"       => 1000,
      "IA64"       => 6000,
      "Alpha"      => 7000,
      "Any"        => 8000,
      "PPC"        => 2000,
      "MIPS"       => 3000,
      "Sparc"      => 4000,
      "UltraSparc" => 5000,
      "Other"      => 9999,

      "i386"       => 1000,
      "ia64"       => 6000,
      "alpha"      => 7000,
      "any"        => 8000,
      "ppc"        => 2000,
      "mips"       => 3000,
      "sparc"      => 4000,
      "ultrasparc" => 5000,
      "other"      => 9999,

      "all"        => 8000,
      nil          => 8000
    }

  end

end

