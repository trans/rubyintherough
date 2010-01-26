require 'roll/project'

class RockFile

  module Rollable

    VERSIONED_DIRS = [ 'lib', 'data', 'ext', 'conf' ]

    # Roll paths and add Roll index.rb file.

    def roll( version )
      #version = project.version
      if versioned?
        translate( version )
      else
        transform( version )
      end
      self
    end

    # Already versioned?

    def versioned?
      VERSIONED_DIRS.each do |loc|
        return true if self[loc].find{ |k,v| /^[0-9]/ =~ k }
      end
    end

    # How to roll if not already versioned.

    def transform( version )
      VERSIONED_DIRS.each do |loc|
        self[loc].each do |d|
          self[loc][version][d] = self[loc].delete(d)
        end
      end
      self
    end

    # How to roll if already versioned.

    def translate( version )
      VERSIONED_DIRS.each do |loc|
        self[loc].each do |d|
          if d =~ /^[0-9]/
            self[loc][version] = self[loc].delete(d)
          end
        end
      end
      self
    end

    # Add index.rb file.

    def add_index( project )
      self['lib'][project.version]['index.rb'] = project.to_index
    end

  end

end
