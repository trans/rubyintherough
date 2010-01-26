# DBize - Database Library
# Copyright (c)2002 Thomas Sawyer, LGPL
#
#   Modules:
#       DBize
#
#   Classes:
#       DBConnection
#

# TomsLib is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# TomsLib is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with TomsLib; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

require 'tomslib/rubylib'
require 'dbi/dbi'

module DBize

  #
  # Module Methods
  #
  
  def DBize.connect(dsn, user, pass)
    @@dbi = DBConnection.new(dsn, user, pass)
  end
  
  def DBize.setup(id_field=nil)
    if id_field
      @@id_field = id_field
    else
      if @@dbi
        possible_ids = @@dbi.meta_names & ['id', 'recordno', 'recno', 'record']
        if possible_ids.empty?
          raise 'indeterminate id field'
        else
          @@id_field = possible_ids[0]
        end
      else
        raise 'indeterminate id field'
      end
    end
  end
  
  def DBize.id_field
    @@id_field
  end
  
  def DBize.close
    @@dbi.close
  end
  
  def DBize.dbi
    @@dbi
  end
  
  def DBize.transaction
    @@dbi.connection.transaction {
      yield
    }
  end
  
  
  # Mixin to automatically make and object database connected
  # Object requires:
  #   #table - method to return table name
  #   #record - method to return record number
  module Record
    
    def dbi
      DBize.dbi
    end
    
    def transaction
      DBize.dbi.connection.transaction {
        yield
      }
    end
    
    def load_from_database
      sql = "SELECT * FROM #{table} WHERE #{DBize.id_field}=#{record.to_i}"
      r = DBize.dbi.connection.select_one(sql)
      raise 'record not found' if not r
      r.each_with_name do |value, name|
        if respond_to?("#{name}=".intern)
          send("#{name}=".intern, value)
        end
      end
      # subrecords
      instance_variables.each { |iv| 
        iobj = instance_eval "#{iv}"
        if iobj.is_a?(Subrecords)
          iobj.load_from_database
        end
      }
    end
    
    
    
    #def save_to_database(force_insert=false, *args)
    #  sql = "SELECT * FROM #{table} WHERE #{DBize.id_field}=#{record.to_i}"
    #  r = DBize.dbi.connection.select_one(sql)
    #  if r and not force_insert
    #    rc = update_database(r)
    #  else
    #    rc = insert_into_database(*args)
    #  end
    #end
    
    
    def update_database
      res = nil
      sql = "SELECT * FROM #{table} WHERE #{DBize.id_field}=#{record.to_i}"
      r = DBize.dbi.connection.select_one(sql)
      raise 'can not update because record not found' if not r
      #
      fields = []
      r.each_with_name do |value, name|
        if respond_to?(name.intern)
          new_value = send(name.intern)
          if new_value != value
            fields << [name, new_value]
          end
        end
      end
      if not fields.empty?
        sql = "UPDATE #{table} SET " << fields.collect{ |pair| "#{pair[0]}=#{DBize.dbi.sql_format(table, pair[0], pair[1])}" }.join(',') << " WHERE #{DBize.id_field}=#{record}"
        DBize.dbi.connection.transaction do
          DBize.dbi.connection.do(sql)
          res = true
        end
      end
      # subrecords
      instance_variables.each { |iv|
        iobj = instance_eval "#{iv}"
        if iobj.is_a?(Subrecords)
          iobj.update_database(force_insert, *args)
        end
      }
      #return rc
      return res
    end
    
    def insert_into_database(exclude=[])
      newid = nil
      fields = []
      DBize.dbi.meta_names[table].each do |name|
        if respond_to?(name.intern) and name != DBize.id_field and not exclude.include?(name)
          new_value = send(name.intern)
          fields << [name, new_value]
        end
      end
      if not fields.empty?
        sql = "INSERT INTO #{table} (" << fields.collect{ |pair| pair[0] }.join(',') << ') VALUES (' << fields.collect{ |pair| DBize.dbi.sql_format(table, pair[0], pair[1]) }.join(',') << ')'
        sqlg = "SELECT currval('#{table}_#{Dbize.id_field}_seq') as recid"
        DBize.dbi.connection.transaction do
          DBize.dbi.connection.do(sql)
          newid = DBize.dbi.connection.select_one(sqlg)['recid']
        end
      end
      # subrecords
      instance_variables.each { |iv|
        iobj = instance_eval "#{iv}"
        if iobj.is_a?(Subrecords)
          iobj.insert_into_database(force_insert, *args)
        end
      }
      #return rc
      return newid
    end
  
    def delete_from_database
      sql = "DELETE FROM #{table} WHERE #{DBize.id_field}=#{record.to_i}"
      DBize.dbi.connection.transaction do
        DBize.dbi.connection.do(sql)
      end
      # subrecords
      instance_variables.each { |iv|
        iobj = instance_eval "#{iv}"
        if iobj.is_a?(Subrecords)
          iobj.delete_from_database
        end
      }
    end
    
  end  # Record
    
    
  # Links a DBized object in a one-to-many
  #   relationship with other DBized objects.
  # This module must be included into a subclass of Array.
  module Subrecords
  
    def load_from_database(*args)
      self.clear
      sql = "SELECT * FROM #{table} WHERE " << references.collect { |r| "#{r}=#{DBize.dbi.sql_format(table, r.to_s, send(r))}" }.join(' AND ')
      recs = DBize.dbi.connection.select_all(sql)
      recs.each { |r|
        self << subclass.new(*args)
        r.each_with_name { |value, name|
          if self.last.respond_to?("#{name}=".intern)
            self.last.send("#{name}=".intern, value)
          end
        }
      }
    end
  
    def add_new_subrecord(*args)
      self << subclass.new(*args)
      references.each { |r|
        self.last.send("#{r}=".intern, send(r))
      }
    end
  
    def update_database
      DBize.dbi.connection.transaction {
        self.each { |r|
          if r.mark_delete
            r.delete_from_database
          else
            r.save_to_database
          end
        }
      }
    end
  
    def insert_into_database
      DBize.dbi.connection.transaction {
        self.each { |r|
          r.insert_into_database
        }
      }
    end
  
    def delete_from_database(rindex=nil)
      if rindex
        DBize.dbi.connection.transaction {
          self[rindex].delete_from_database
        }
      else
        DBize.dbi.connection.transaction {
          self.each { |r|
            r.delete_from_database
          }
        }
      end
    end
  
  end  # Subrecords
  
  
  # Common class for accessing a database
  # Provides some extra functionality
	class DBConnection

		attr_reader :connection
    attr_reader :tables
    attr_reader :meta
    attr_reader :meta_names
    attr_reader :meta_types

		# initialize opens the connection to the database, prepares variables and calls meta (currently AutoCommit is set to false)
		def initialize(dsn, user, pass)
			@connection = DBI.connect(dsn, user, pass, 'AutoCommit' => false)
			@tables = []
			@meta = {}
			@meta_names = {}
			@meta_types = {}
			load_meta  # load database meta-information
		end

		# close method closes the database connection
		def close
			@connection.disconnect
		end

		# meta method collects meta information for the database
		def load_meta
			@tables = @connection.tables  # .select { |table| table !~ /^pg_/ }  # this only works with postgresql to remove system tables
			@tables.each do |table|
				@meta[table] = @connection.columns(table)
				@meta_names[table] = []
				@meta_types[table] = {}
				@meta[table].each do |column|
					@meta_names[table] << column['name']                                  # make an array of column names
				  @meta_types[table].update({ column['name'] => column['type_name'] })  # make a hash of column names => column types
				end
			end
		end

		# Returns a field value formatted for sql statments according to the database meta information
    # Essentially it deals with quoting strings
		def sql_format(table, field_name, field_value)
			if not @meta_types.has_key?(table)
				raise "invalid table: #{table}"
			end
			if not @meta_types[table].has_key?(field_name)
				raise "invalid field name: #{field_name}"
			end
			case @meta_types[table][field_name].downcase
			when /int/, /serial/
				if type != 'interval' and type != 'point'
					typified_value = field_value
				end
			when /float/, /double/, /money/, /numeric/, /decimal/
				typified_value = field_value
			when /bool/
				typified_value = field_value
			when /timestamp/, /date/
        if field_value.to_s.strip.empty?
          typified_value = 'NULL'
        else
          typified_value = sql_escape(field_value.to_s.strip).quote(true)
        end
			when /var/, /char/, /text/
				typified_value = sql_escape(field_value.to_s.strip).quote(true)
			end
			return typified_value
		end
	
		# sql_escape escapes apostrophes in character string types
		def sql_escape(str)
			return str.gsub(/[']/,"''")  # doubles up any apostrophes
		end
	
    # typecast's a value according to database meta information
    def typecast(table, field_name, field_value, honor_func=false)
      if @meta_types.has_key?(table)
				if @meta_types[table].has_key?(field_name)
          case @meta_types[table][field_name].downcase
          when /int/, /serial/
            if type != 'interval' and type != 'point'  # these type are not supported
              if honor_func and field_value.to_s.strip =~ /^\w+\(/
                typecast_value = field_value
              else
                typecast_value = field_value.to_i
              end
            else
              typecast_value = field_value.to_s.strip
            end
          when /float/, /double/, /money/, /numeric/, /decimal/
            if honor_func and field_value.to_s.strip =~ /^\w+\(/
              typecast_value = field_value
            else
              typecast_value = field_value.to_f
            end
          when /bool/
            if honor_func and field_value.to_s.strip =~ /^\w+\(/
              typecast_value = field_value
            else
              typecast_value = field_value.to_b
            end
          when /timestamp/, /date/
            typecast_value = field_value.to_s.strip
          when /var/, /char/, /text/
            typecast_value = field_value.to_s.strip
          else
            typecast_value = field_value.to_s.strip
          end
        else
          # pass through any field not found?
          typecast_value = field_value  #raise "table column, #{field_name}, does not exist"
        end
      else
        # pass through if table not found?
        typecast_value = field_value  #raise "typecast table, #{table}, does not exist"
      end
      return typecast_value
    end
    
	end  # DBConnection
  
end  # DBize
