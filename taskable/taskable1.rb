# TITLE:
#
#   Taskable
#
# COPYRIGHT:
#
#   Copyright (c) 2006 Thomas Sawyer
#
# LICENSE:
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
# AUTHORS:
#
#   - Thomas Sawyer
#
# NOTES:
#
#   - TODO The included call back does a comparison to Object.
#     This is a bit of a hack b/c there is actually no way to
#     check if it is the toplevel --a flaw w/ Ruby's toplevel proxy.
#
#   - TODO Should Rake's namespace feature be added? This could interfer
#     with other definitions of #namespace.
#
#   - TODO The only reason the :exec method is defined is b/c instance_exec
#     is not in Ruby yet, so until then this is the working hack.
#
# LOG:
#
#   - CHANGE 2006-11-14 trans
#
#     Taskable has been completely rewritten. While it is essentially
#     compatible with the previous implementation, it is not 100% the
#     same; mainly in that tasks are not defined as methods any longer.
#     This new implementation is now nearly 100% compatible with Rake's
#     design. Note, for a basic "taskable" system, more like the old
#     version, see depend.rb.

require 'facets/class_extension'

$toplevel = self

# = Taskable
#
# The Taskable module provides a generic task system
# patterned after Rake, but useable in any
# code context --not just with the Rake tool. In other
# words one can create methods with dependencies.
#
# NOTE Unlike methods, tasks can't take independent parameters
# if they are to be used as prerequisites. The arguments passed
# to a task call will also be passed to it's prequisites.
#
# To use Taskable at the toplevel use:
#
#   include Taskable
#
# Or if you want all modules to be "taskable":
#
#   class Module
#     include Taskable
#   end

module Taskable

  def self.included( base )
    if base == Object #$toplevel
      require 'facets/more/main_as_module.rb'
      Module.module_eval{ include TaskableDSL }
    else
      base.extend TaskableDSL
    end
  end

  ### CLASS LEVEL ###

  module TaskableDSL

    #--
    # TODO Add task namespace functionality ???
    #++
    #def namespace
    #end

    # Define description for subsequent task.

    def desc(line=nil)
      return @_last_description unless line
      @_last_description = line.gsub("\n",'')
    end

    # Use up the description for subsequent task.

    def desc!
      l, @_last_description = @_last_description, nil
      l
    end

    # <b>Task</b>
    #
    #

    def task( target_to_source, &build )
      target, source = *Task.parse(target_to_source)
      define_method("#{target}:exec",&build) if build
      (@task||={})[target] = Task.new(target, source, desc!, &build)
    end

    # <b>File task</b>
    #
    # Task must be provide instructions for building the file.

    def file( file_to_source, &build )
      file, source = *Task.parse(file_to_source)
      define_method("#{file}:exec",&build) if build
      (@task||={})[file] = FileTask.new(file, source, desc!, &build)
    end

    # <b>Rule task</b>
    #
    # Task must be provide instructions for building the file(s).

    def rule( pattern_to_source, &build )
      pattern, source = *Task.parse(pattern_to_source)
      define_method("#{pattern}:exec",&build) if build
      (@task||={})[pattern] = RuleTask.new(pattern, source, desc!, &build)
    end

    #

    def instance_tasks( ancestry=true )
      @task ||= {}
      if ancestry
        ancestors.inject(@task.keys) do |m,a|
          t = a.instance_variable_get("@task")
          m |= t.keys if t
          m
        end
      else
        @task.keys
      end
    end

    # List of task names with descriptions.

    def described_tasks( ancestry=true )
      memo = []
      instance_tasks(ancestry).each do |name|
        memo << name if @task[name].desc
      end
      return memo
    end

    # List of task names without descriptions.

    def undescribed_tasks( ancestry=true )
      memo = []
      instance_tasks(ancestry).each do |name|
        memo << name unless @task[name].desc
      end
      return memo
    end

    # Find matching task.
    #--
    # TODO Maybe this isn't really needed here and can be moved to Task class ???
    #++

    def instance_task( match )
      hit = (@task||={}).values.find do |task|
        task.match(match)
      end
      return hit if hit
      ancestors.each do |a|
        task_table = a.instance_variable_get("@task")
        next unless task_table
        hit = task_table.values.find do |task|
          task.match(match)
        end
        break hit if hit
      end
      hit
    end

  end

  ### INSTANCE LEVEL ###

  #

  def tasks
    (class << self; self; end).instance_tasks
  end

  #

  def task(name)
    (class << self; self; end).instance_task(name)
  end

  # FIXME, THIS STILL WONT WORK AT TOPLEVEL!!!!

  def method_missing(t, *a, &b)
p t
p tasks
p task(t)
    #if self.class.respond_to?(:instance_task) && (task = self.class.instance_task(t))
    if tsk = task(t)
      tsk.run(self, t)
    else
      super(t.to_sym,*a,&b)
    end
  end

end

#

class Taskable::Task

  # Parse target => [source,...] argument.

  def self.parse(target_to_source)
    if Hash === target_to_source
      target = target_to_source.keys[0]
      source = target_to_source.values[0]
    else
      target = target_to_source
      source = []
    end
    return target.to_sym, source.collect{|s| s.to_sym}
  end

  #

  attr_reader :target, :source, :desc, :build

  alias :name :target
  alias :description :desc

  # New task.

  def initialize( target, source, desc=nil, &build )
    @target = target
    @source = source
    @desc   = desc
    @build  = build
  end

  # Run task in given context.

  def run( context, target )
    task   = self
    source = @source
    build  = @build

    presource(context).each do |d|
      d.call(context)
    end

    call(context)
  end

  # Call build exec of task. Note that the use of :exec method
  # is due to the lack of #instance_exec which will come wiht Ruby 1.9.

  def call( context )
    context.send("#{@target}:exec", self) if @build
  end

  #

  def match( target )
    @target.to_s == target.to_s
  end

  # Compile list of all unique prerequisite sources.

  def presource( context, build=[] )
    @source.each do |s|
      t = context.class.instance_task(s)
      raise NoMethodError, 'undefined source' unless t
      build.unshift(t)
      t.presource(context,build)
    end
    build.uniq!
    build
  end

end

#

class Taskable::FileTask < Taskable::Task

  # Run file task in a given context.

  def run( context, target )
    task   = self
    source = @source
    build  = @build

    context.instance_eval do
      needed = false
      if File.exist?(file)
        #source.each { |s| send(s) if respond_to?(s) }
        timestamp = File.mtime(file)
        needed = source.any? { |f| File.mtime(f.to_s) > timestamp }
      else
        timestamp = Time.now - 1
        needed = true
      end
      if needed
        build.call(task)
        unless File.exist?(file) and File.mtime(file) > timestamp
          raise "failed to build -- #{file}"
        end
      end
    end
  end

  #

  def match(target)
    @target.to_s == target.to_s
  end

end

#

class Taskable::RuleTask < Taskable::FileTask

  # Run rule task in given context.

  def run( context, target )
    @target = target
    super(context)
  end

  #

  def match(target)
    case @target
    when Regexp
      @target =~ target.to_s
    when String
      #if @target.index('*')  #TODO
      #  /#{@target.gsub('*', '.*?')}/ =~ target
      if @target.index('.') == 0
        /#{Regexp.escape(@target)}$/ =~ target
      else
        super
      end
    else
      super
    end
  end

end



#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin ##test

  require 'test/unit'

  class TestTaskable1 < Test::Unit::TestCase

    module M
      include Taskable
      task :m1 => [ :c1 ] do @x << "m1" end
      task :m2 => [ :c2 ] do @x << "m2" end
      task :m3 => [ :c3 ] do @x << "m3" end
      task :m4 => [ :c1, :c2, :c3 ] do @x << "m4" end
      task :m5 do @x << 'm5' end
    end

    class B
      include Taskable
      attr :x
      def initialize ; @x = [] ; end

      desc "test-b1"
      task :b1 do @x << "b1" end
      task :b2 => [ :b1 ]
    end

    class C
      include M
      attr :x
      def initialize ; @x = [] ; end

      task :c1 do @x << "c1" end
      task :c2 => [ :c1, :c1 ] do @x << "c2" end
      task :c3 => [ :c1, :c2 ] do @x << "c3" end
      task :c4 => [ :m1 ] do @x << "c4" end
      task :c5 => [ :c5 ] do @x << "c5" end
      task :c6 => [ :c7 ] do @x << "c6" end
      task :c7 => [ :c6 ] do @x << "c7" end
    end

    class D < C
      task :d1 => [ :c1 ] do @x << "d1" ; end
      task :d2 => [ :m1 ] do @x << "d2" ; end
    end

    module N
      include M
    end

    class E
      include N
      attr :x
      def initialize ; @x = [] ; end

      task :e1 => [ :c1 ] do @x << "e1" ; end
      task :e2 => [ :m1 ] do @x << "e2" ; end
      task :e3 => [ :m5 ] do @x << "e3" ; end
    end

    module O
      include Taskable
      attr :x
      task :o1 do (@x||=[]) << "o1" end
      task :o2 => [ :o1 ] do (@x||=[]) << "o2" end
    end

    # tests

    def test_001
       assert( B.described_tasks.include?(:b1) )
    end

    def test_B1
      b = B.new ; b.b1
      assert_equal( [ 'b1' ], b.x )
    end

    def test_B2
      b = B.new ; b.b2
      assert_equal( [ 'b1' ], b.x )
    end

    def test_C1
      c = C.new ; c.c1
      assert_equal( [ 'c1' ], c.x )
    end

    def test_C2
      c = C.new ; c.c2
      assert_equal( [ 'c1', 'c2' ], c.x )
    end

    def test_C3
      c = C.new ; c.c3
      assert_equal( [ 'c1', 'c2', 'c3' ], c.x )
    end

    def test_C4
      c = C.new ; c.c4
      assert_equal( [ 'c1', 'm1', 'c4' ], c.x )
    end

    def test_M1
      c = C.new ; c.m1
      assert_equal( [ 'c1', 'm1' ], c.x )
    end

    def test_M2
      c = C.new ; c.m2
      assert_equal( [ 'c1', 'c2', 'm2' ], c.x )
    end

    def test_M3
      c = C.new ; c.m3
      assert_equal( [ 'c1', 'c2', 'c3', 'm3' ], c.x )
    end

    def test_M4
      c = C.new ; c.m4
      assert_equal( [ 'c1', 'c2', 'c3', 'm4' ], c.x )
    end

    def test_D1
      d = D.new ; d.d1
      assert_equal( [ 'c1', 'd1' ], d.x )
    end

    def test_D2
      d = D.new ; d.d2
      assert_equal( [ 'c1', 'm1', 'd2' ], d.x )
    end

    def test_E1
      e = E.new
      assert_raises( NoMethodError ) { e.e1 }
      #assert_equal( [ 'c1', 'e1' ], e.x )
    end

    def test_E2
      e = E.new
      assert_raises( NoMethodError ) { e.e2 }
      #assert_equal( [ 'c1', 'm1', 'e2' ], e.x )
    end

    def test_E3
      e = E.new ; e.e3
      assert_equal( [ 'm5', 'e3' ], e.x )
    end

    # def test_F1
    #   F.o1
    #   assert_equal( [ 'o1' ], F.x )
    # end
    #
    # def test_F2
    #   F.o2
    #   assert_equal( [ 'o1', 'o1', 'o2' ], F.x )
    # end

  end

=end

  ##
  # Test toplevel usage.
  #

  include Taskable

p Object.ancestors

  task :foo do
    "foo"
  end

  task :bar => [ :foo ] do
    "bar"
  end

  #class TestTaskable2 #< Test::Unit::TestCase
    def test_01
      puts foo
    end

    def test_02
      puts bar
    end
  #end

  test_01
  test_02

#=end

# Author::    Thomas Sawyer
# Copyright:: Copyright (c) 2006 Thomas Sawyer
# License::   Ruby License
