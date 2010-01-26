require 'xdk/designkit/elements/full'

module XDK

  module DesignKit

    # Open element if like Full bu cancaontain arbitary
    # elements which can in turn have arbitrary elements.

    class Open < Full

      # Just like Element, but allows arbitrary tag entries.

      def method_missing(sym, *args, &blk)
        sym = sym.to_s
        case sym[-1,1]
        when '?', '!'
          super
        when '='
          (class << self; self; end).class_eval do
            element(sym.chomp('='), Open)
          end
          element!(sym, *args) #, &blk)
        else
          (class << self; self; end).class_eval do
            element(sym, Open, :multiple=>true)
          end
          element!(sym, *args, &blk)
        end
      end

    end

  end

end
