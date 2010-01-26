
=begin

$Title: 1st Class Methods $
$Author: Thomas Sawyer $
$Date: 2004-08-21 $
$File: 1st.rb $

== 1st Class Methods

Easy access to method as objects. And they retain state!

= Examples

Each of the following examples returns the exact same object.

== Cached Method Call

  def hello
    puts "Hello World!"
  end
  p method(:hello)                      #=> <Method: #hello>
  p self.class.instance_method(:hello)  #=> <UnboundMethod: #hello>
  
  *shortcomings: very verbose
  
== Constants and Capitalized Methods

  def hello
    puts "Hello World!"
  end
  p Hello()  #=> <Method: #hello>
  p ::Hello  #=> <UnboundMethod: #hello>

  shortcomings:
  * uses constant namespace
  * can't seem to get instance_method for pre-underscored methods
    ex- _ameth; ::_Ameth  #=> undefined method error (not const)
      
== Which do you prefer?

= Comments

  Niether of these are too terribly bad, but I think the best
  solution would be using the notation <tt>::ameth</tt>. This would require
  some minor changes to Ruby, but with few backward incompatabilites
  if parantheticals revert back to the actual method invocation.
  Although this later stipulation means capitalized methods
  would not be accessible in this way b/c they would intefere with
  constant lookup. It's a minor trade off.

                # Current           Proposed           Alternative
    Foo.Bar()   # method call       method call        method call
    Foo.Bar     # method call       method call        method call
    Foo.bar()   # method call       method call        method call
    Foo.bar     # method call       method call        method call
    Foo::Bar()  # method call       method call        1st class method
    Foo::Bar    # constant lookup   constant lookup    constant lookup
    Foo::bar()  # method call       method call        1st class method
    Foo::bar    # method call       1st class method   1st class method
  
  Then again this dosen't address bound versus unbound.
    
== Which do you prefer?
    
= Authenticate

  MIT License Copyright (c) 2004 Thomas Sawyer

=end

# Implementation 1
class Object
  alias_method :method_pre1st, :method
  def method(s)
    ( @__methods__ ||= {} )[s] ||= method_pre1st(s)
  end
end
class Module
  alias_method :instance_method_pre1st, :instance_method
  def instance_method(s)
    ( @__instance_methods__ ||= {} )[s] ||= instance_method_pre1st(s)
  end
end


# Implementation 2
class Object
  alias method_missing_pre1st method_missing
  def method_missing( sym, *args )
    s = sym.to_s
    i = ( s.index('_') || -1 ) + 1
    s[ i ] -= ?A - ?a if s[ i ] >= ?A && s[ i ] <= ?Z
    s = s.intern
    return method( s ) if respond_to?( s )
    method_missing_pre1st( sym, *args )
  end
end
class Module
  alias const_missing_pre1st const_missing
  def const_missing( sym, *args )
    s = sym.to_s
    i = ( s.index('_') || -1 ) + 1
    s[ i ] -= ?A - ?a if s[ i ] >= ?A && s[ i ] <= ?Z
    s = s.intern
    return instance_method( s ) if method_defined?( s )
    const_missing_pre1st( sym, *args )
  end
end
