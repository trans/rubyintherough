require 'sow/generator'

module Sow

  # This generator provides for a basic per-project template system.
  #
  class GenericGenerator < Generator

    register(:generic)

    #
    def __file__ ; __FILE__ ; end

  end

end

