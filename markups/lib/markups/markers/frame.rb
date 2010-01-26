
require 'markups/marker'

module MarkUps::Markers

  #
  # Frame Marker
  #
  class Frame < Marker

    priority 0.3

    def to_xhtml( node, info )
      %Q{<iframe#{node.attributes}/>}
    end
    alias_method :to_html, :to_xhtml

  end

end
