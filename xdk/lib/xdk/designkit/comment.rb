require 'xdk/designkit/node'

module XDK

  module DesignKit

    # XML Comment.

    class Comment < Node
      attr :text

      def initialize(text)
        @text = text.to_s
      end

      def to_xml
        "<!-- #{text} -->"
      end
    end

  end

end
