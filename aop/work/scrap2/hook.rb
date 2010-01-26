# hook.rb

=begin 
--- !ruby/doc

Title: Global Event Hooks
Author: Thomas Sawyer
Date: 2004-08-20
File: hook.rb

Description: >

  Hook provides a global Event Hooks System.
  Simply register events, call on them when needed,
  and unregisted them when threw.

Example: >
  
  def dothis
    puts 'pre'
    hook :here
    puts 'post'
  end
  def tryit
    define_event :here do
      puts "HERE"
    end
    puts "BEFORE"
    dothis
    puts "AFTER"
    remove_event :here
  end
  tryit

Authenticate: >

  Ruby License Copyright (c) 2004 Thomas Sawyer

=end

module Kernel
  $__eventhooks__ ||= {}
  def define_event( name, &block )
    $__eventhooks__[name] = block
  end
  def hook( name, *args ) 
    $__eventhooks__[name].call(*args)
  end
  def remove_event( name )
    $__eventhooks__.delete(name)
  end
end

