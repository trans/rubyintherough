# = TITLE:
#
#   One
#
# = COPYING:
#
#   Copyright (c) 2005 Thomas Sawyer
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
# = AUTHOR:
#
#   - Thomas Sawyer

# = One
#
# One liners helper library provides one letter
# alias for a number of classes, modules and
# methods, allowing one to create very tight one-liners.
# This this bit of a "gag" library, but it can also
# be used for code obsfuscation and includes examples
# of some neat one liners.

# Alias Kernel
K=Kernel

# Alias Object
O=Object

# Alias Class
C=Class

module Kernel
  alias pr print
  alias ps puts
  alias s sleep
  alias l loop
end

module Enumerable
  alias m map
end

class Array
  alias e each
  alias r reverse
end

class String
  alias e each
  alias r reverse
end

class Integer
  alias t times
end
