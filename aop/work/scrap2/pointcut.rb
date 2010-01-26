#

class Module

=begin
  def pointcut(ph)
    rph = {}; ph.each { |ka, v| [ka].flatten.each { |k| rph[k] = v } }
    pcmod = Module.new
    rph.each do |k, v|
      pcmod.module_eval %Q{
        def #{v}(*args)
          #{k}(*args)
        end
      }
      module_eval %Q{
        def #{k}(*args)
          md = /in\s`(.+)'$/.match(caller[0])
          if md && md[1] == '#{v}'
            super(*args)
          else
            #{v}(*args)
          end
        end
      }
    end
    include pcmod
  end
=end

  def pointcut(ph)
    rph = {}; ph.each { |ka, v| [ka].flatten.each { |k| rph[k] = v } }
    self.instance_variable_set('@__pointcut__',rph)
    module_eval %Q{ 
      def method_missing(sym, *args)
        puts "HERE"
        rph = self.class.instance_variable_get('@__pointcut__')
        send(rph[sym], *args) if repond_to?(rph[sym])
      end
    }
  end
  
end


if __FILE__ == $0

  class A
    def m1(x); print "#{x}"; end
  end
  
  class B < A
  
    pointcut :m1 => :n
  
    #module Pointcut
    #  def n(*args)
    #    m1(*args)
    #  end
    #end
    #include Pointcut
    
    #def m1(*args)
    #  md = /in\s`(.+)'$/.match(caller[0])
    #  if md && md[1] == 'n'
    #    super(*args)
    #  else
    #    n(*args)
    #  end
    #end
    
    def n(*args)
      print '{'
      super
      print '}'
    end
  end
  
  B.new.m1('1'); puts
  B.new.x('1'); puts
  
end
