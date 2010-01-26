# = capsule.rb
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
# == Authors & Contributors
#
# * Thomas Sawyer

# Author::    Thomas Sawyer
# Copyright:: Copyright (c) 2005 Thomas Sawyer
# License::   Ruby License

# = Extensible
#
# A Capsule encapsulates reusable code and is an analog to the Module class,
# but rather than storing it's own methods it simply stores modules. These
# modules are divided into two groups: extensions and inclusions. A capsule
# is reused via the Kernel#inherit method.
#

class Capsule < Module

  attr_reader :extensions, :inclusions

  def initialize( &template )
    @extensions = []
    @inclusions = []
    instance_eval &template if template
  end

  # Shortcut for creating an inclusion-extension pair capsule.

  def self.[]( e, i )
    new << e < i
  end

  # Add modules to the inclusions group.

  def include( *inclusions )
    #inclusions.each { |i| self < i }
    @inclusions.concat inclusions
  end

  # Add modules to the extensions group.

  def extend( *extensions )
    @extensions.concat extensions
  end

  # Add a module to the inclusions group.

  def <( inclusion )
    @inclusions << inclusion
    self
  end

  # Add a module to the extensions group.

  def <<( extension )
    @extensions << extension
    self
  end

  # Append this capsules features to a given base module or class.

  def append_features( base )
    #return if base == self
    # use #instance_exec in Ruby 1.9+
    base.send( :extend,  *@extensions )
    #base.send( :include, *@inclusions )
    super
  end

end

class Module

  # Inherit behavior from other modules or capsules.

  def inherit( *capsules )
    capsules.each do |c|
      c.append_features( self )
    end
  end

end


#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test

  require 'test/unit'

  class TC_Capsule < Test::Unit::TestCase

    module Mc
      def c ; "c" ; end
    end

    module Mi
      def i; "i"; end
    end

    # quick notation for a pair
    #M = Capsule[ Mc, Mi ]
    module M
      extend Mc
      include Mi
    end

    # or long notaion for more complex components
    #N = Capsule.new do
    module N
      extend Mc
      include Mi
    end

    class X
      include M
    end
p X.ancestors
    class Y
      include N
    end

    def test_001
      assert_equal("c", X.c)
      assert_equal( "i", X.new.i)
    end

    def test_002
      assert_equal("c", Y.c)
      assert_equal( "i", Y.new.i)
    end

  end

=end
