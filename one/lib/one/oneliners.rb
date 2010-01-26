# = TITLE:
#
#   Ruby Oneliners
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
# = THANKS:
#
#   Big shout-out to all the authors of fabulous one-liners!
#
# = NOTE:
#
#   - Most of these one-liners do not use the one.rb shortcut aliases.

#require 'one/one.rb'

# This module contains a number of historic one-liners.

module OneLiners

  extend self

  DIRECTORY = File.join(File.dirname(__FILE__), 'oneliners')

  #ONELINERS.each do |name, code|
  #  define_method( name, &eval("lambda { #{code} }") )
  #end

  def list
    @list ||= (
      files = Dir.glob(File.join(DIRECTORY, '*'))
      names = files.collect do |path|
        File.basename(path).chomp('.rb')
      end
      names.sort
    )
  end

  def include?(name)
    list.include?(name)
  end

  def code(name)
    @oneliners ||= {}
    @oneliners[name.to_s] ||= File.read(file(name))
  end

  def exec(name)
    if include?(name)
      load file(name)
    else
      false
    end
  end

  def file(name)
    File.join(DIRECTORY, name + '.rb')
  end

  #def method_missing(name, args)
  #  if oneliners.include?(name)
  #    load oneliner_file(name)
  #  else
  #    super
  #  end
  #end

end


if $0 == __FILE__

  name = ARGV.last

  case ARGV.first
  when "--list"
    puts OneLiners.list.join("\n")
  when "--view"
    if OneLiners.include?(name)
      puts OneLiners.code(name)
    else
      puts "Unknown oneliner -- #{name}"
      exit 0
    end
  else
    if OneLiners.include?(name)
      OneLiners.exec(name)
    else
      puts "Unknown oneliner -- #{name}"
      exit 0
    end
  end

end
