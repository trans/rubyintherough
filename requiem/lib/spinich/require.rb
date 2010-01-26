# require files directly from resources like Github.

module Spinich

  #
  def require(uri)
    uri = URI.new
    uri.download if uri.needed?
    super uri.filename
  end

  #
  class URI

    attr :uri

    def initialize(uri)
      @uri = uri
    end

    def filename
      resource.filename(uri)
    end

    def needed?
      File.exists?(filename)  #filename.file.exists?
    end

    def download
      resource.download(uri)
    end

    # code resource
    def resource
      @resource ||= Github.new
    end

  end

  #
  class Resource
  end

  #
  class GitHub < Resource
    # download the uri
    def download(uri)
      `github --read #{uri} #{filename(uri)}`
    end

    # convert uri into local cache filename
    def filename(uri)
      uri
    end
  end 

end

Module.public(:include)
Object.include(Spinich)

