
module MarkUps
  module Markers

    #
    # Marker Registry
    #
    class Registry < Hash

      # For setting and accessing the parser
      attr_accessor :parser

      # Add a marker to the registry
      def <<( markerClass )
        @raw_set = nil
        @raw_tags = nil

        marker = markerClass.new( self )

        case marker.tag
        when Array
          marker.tag.each { |t| self[t] = marker }
        else
          self[ marker.tag ] = marker
        end
        marker
      end

      def markers
        values.uniq.sort
      end

      # Inform each marker of the parser they are used by.
      #def parser_set( parser )
      #  each_value { |m| m.paarser_set( parser ) }
      #end

      def raw_set
        @raw_set ||= self.values.unique.select{ |m| m.raw? }
      end

      def raw_tags
        @raw_tags ||= self.keys.select{ |t| self[t].raw? }
      end

    end

  end
end