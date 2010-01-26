#
# Alias
#
class HashUsingAlias < Hash
    alias :old_hset :[]=

    def []=(key, value)
      self.old_hset(key, value)
    end
end

#
# Bind
#
class HashUsingBind < Hash
    hset = self.instance_method(:[]=)

    define_method(:[]=) do |key, value|
      hset.bind(self).call(key, value)
    end
end

#
# Subclass (what a proper cut would be)
#
class HashUsingSubClass < Hash
  def []=(k,v)
    super
  end
end

#
# Override
#
require 'override'
class HashUsingOverride < Hash
   override('[]='){ def []=(k,v) super end }
end

#
# Cut (pure ruby meta-hacking version)
#
require 'facets/more/cut'
class HashUsingCut < Hash
end

cut :HashUsingCutAspect < HashUsingCut do
  def []=(k,v)
    super
  end
end

require "benchmark"
def bm_report bm, title, hash_class
   hash = hash_class.new
   bm.report title do
     100_000.times do
       hash[ 1 ] = 1
     end
   end
end

Benchmark.bmbm do |bm|
   bm_report bm, "original", Hash
   bm_report bm, "alias", HashUsingAlias
   bm_report bm, "bind", HashUsingBind
   bm_report bm, "override", HashUsingOverride
   bm_report bm, "subclass", HashUsingSubClass
   bm_report bm, "cut", HashUsingCut
end

