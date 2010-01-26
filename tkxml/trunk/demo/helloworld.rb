# TkXML
# Copyright (c) 2002 Thomas Sawyer, LGPL
#
# Example: TkXML #1

# XMLToolKit is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# XMLToolKit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with XMLToolKit; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


require 'tkxml'

source = %Q{
  <root>
    <label text='Hello World!'>
      <_pack side='right'/>
    </label>
  </root>
}

tkxml = TkXML.new(source)
tkxml.build
