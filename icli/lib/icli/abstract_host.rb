require 'enumerator'
require 'fileutils'
require 'open-uri'
require 'openssl'
require 'ostruct'
require 'httpclient'
require 'tmpdir'
require 'facets/hash/rekey'
require 'facets/kernel/ask'

require 'icli/uploadutils'

module ICli

  COOKIEJAR  = File::join(Dir.tmpdir, 'icli', 'cookie.dat')

  def self.factory(name)
    ["icli/#{name.downcase}.rb"].each{ |x| require x }  # only did it this way to shut rdoc up!
    ICli::const_get(name.capitalize)
  end

  # Base class for all hosts.

  class AbstractHost

    # URI = http:// + domain name
    # TODO Deal with https, and possible other protocols too.
    attr :uri

    # Many sites will require logging in so these are available by
    # for use even if they arn't used.
    attr :username
    attr :password

    # Domain name of host. Must be overriden by adapter.
    def domain
      raise "Missing Domain"
    end

    # New RubyForge tasks.
    def initialize(options)
      options = options.dup.rekey

      @dryrun  = options[:dryrun]
      @trace   = options[:trace]

      #@domain   = options[:domain] || default_domain
      @uri   = URI.parse("http://" + domain)

      @username = options[:username]
      @password = options[:password]

      mkdir_p(File.dirname(COOKIEJAR))
      @cookie_jar = COOKIEJAR

      options
    end

    private

      def dryrun?
        @dryrun
      end

      def trace?
        @trace
      end

  end

end
