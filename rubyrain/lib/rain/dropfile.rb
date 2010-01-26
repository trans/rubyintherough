
require 'fileutils'

require "facet/kernel/set_with"
require "facet/hash/update_keys"
require "facet/string/margin"

require "facet/downloader"

module Rain

  class DropFile

    attr_accessor :name,
                  :version,
                  :title,
                  :description,
                  :maintainer,
                  :email,
                  :authors,
                  :file,
                  :size,
                  :checksum,
                  :mirrors,
                  :license,
                  :message,
                  :notes

    def author ; @authors[0] ; end
    def author=( ath )
      (@authors ||= []) << ath
    end

    def interface; @interface; end
    def interface=(iface)
      @interface = iface
    end

    def initialize( file )
      @path = file.path
      @name = File.basename( file.path ).gsub(/[.]\w+?$/,'')
      raise if File.directory?( file )
      raise unless File.file?( file )
      yaml = file.read
      rundata = YAML::load( yaml )
      rundata.update_keys { |k| k.to_s.downcase }
      @name ||= File.basename( rundata['file'] ).gsub(/[.]\w+?$/,'')
      set_with( rundata )
    end

    def brief
      %{
      |#{title} (#{name})
      |#{description}
      |
      }.margin
    end

    def detail
      to_yaml
    end

    def to_yaml_properties
      [ '@name', '@version', '@title', '@description', '@maintainer', '@email', '@authors', '@file',
        '@size', '@checksum', '@mirrors', '@license', '@message', '@notes' ]
    end

    # Run
    def run
      tmpdir    = '/tmp/rain'
      localfile = "#{tmpdir}/#{file}"

      # create tmp dir if donesnt already exist
      ::FileUtils.mkdir_p( tmpdir ) unless File.directory?( tmpdir )

      dmgr = Downloader.new( tmpdir, mirrors )
      dmgr.interface = interface

      # load
      success = dmgr.fetch( file, checksum, size )

      # extract
      success = dmgr.extract( localfile ) if success

      # install
      if success
        locdir = localfile.gsub(/\.\w+?$/,'')
        Dir.chdir( locdir ) do
          success = `ruby setup.rb -q`
        end
        if success
          interface.register_install( @path, locdir )
        end
        interface.installed( localfile )
      end

      success
    end

  end

end
