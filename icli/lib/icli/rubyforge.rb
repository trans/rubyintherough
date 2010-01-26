require 'icli/gforge'

module ICli

  # Interface with the RubyForge hosting service.
  # Currently supports functions:
  #
  #  * release  - Upload release packages.
  #  * publish  - Upload website files.
  #  * announce - Post news announcement.
  #  * touch    - Test connection.

  class Rubyforge < Gforge

    DOMAIN = "rubyforge.org"

    def domain
      DOMAIN
    end

    # Website location on server.
    def siteroot
      "/var/www/gforge-projects"
    end

  end

end
