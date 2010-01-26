# = xmlbuilder.rb
#
# == Copyright (c) 2006 Thomas Sawyer
#
#   Ruby License
#
#   This module is free software. You may use, modify, and/or redistribute this
#   software under the same terms as Ruby.
#
#   This program is distributed in the hope that it will be useful, but WITHOUT
#   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#   FOR A PARTICULAR PURPOSE.
#
# == Author(s)
#
# * Thomas Sawyer

# Author::    Thomas Sawyer
# Copyright:: Copyright (c) 2006 Thomas Sawyer
# License::   Ruby License

require 'facets/more/buildingblock.rb'
require 'facets/more/xmlhelper.rb'

# = XMLBuilder

class XMLBuilder < BuildingBlock

  def initialize
    super(XMLHelper, :element)
  end

end
