
module Rain

  # abstract class
  class Interface

    def self.inherited( klass )
      @interfaces ||= {}
      @interfaces[klass.name.downcase] = klass
    end

    def self.interfaces
      @interfaces ||= {}
    end

    def list( entries )
    end

  end

end