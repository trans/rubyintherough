
class Method

    # 
    # The Maskable mixin to allow a Class or Module
    # to have it's methods masked.
    #
    # NOTE: requiring maskable.rb currently automatically
    # extends Object with Method::Maskable so all Objects
    # can accepts masks.
    #
    # The default behavior for masked methods is that all
    # masked methods for a method are called in reverse order that
    # there were added to the mask, LIFO style. After
    # one masked method returns, the next one is called and so
    # on until all methods are called. Method.final
    # and Method.rest can alter this behavior by controlling
    # the mask call stack.
    # 
    module Maskable

        def self.extended(obj)
            if obj == Maskable or obj.ancestors.include? Maskable
                raise "Unable to reextend or include Maskable"
            end
            super
        end

        # Returns a hash describing the masked methods.
        # The key is the method being masked and the value
        # is an array of masking modules which are using.
        # 
        def show_masks
            ret = Hash.new
            self::MASKS.each do |meth,mask|
                ret[meth] = mask.map { |m| self::MASK_INFO[m] }
            end
            ret
        end

        # Adds a module as a mask to this Class or Module.
        # All instance methods of the module are added
        # as masks for methods of the same name on this object.
        # 
        def add_mask(mod)

            unless const_defined? "MASKS"
                const_set("MASKS",Hash.new)
            end

            unless const_defined? "MASK_INFO"
                const_set("MASK_INFO",Hash.new)
            end

            unless const_defined? "Masked"
                const_set("Masked",Module.new)
            end

            tmod = mod.name.gsub("::","_")

            cln = mod.clone

            self::Masked.const_set(tmod,cln)

            trans = []

            cln.instance_methods(false).each do |m|
                meth = m.to_sym
                masked_name = "__#{tmod}_#{(mod.object_id + cln.object_id).abs}_#{m}".to_sym

                self::MASK_INFO[masked_name] = mod

                trans << [meth, masked_name]

                cln.module_eval <<-CODE
                alias #{masked_name} #{meth}
                remove_method(:#{meth})
                CODE
            end

            module_eval { include cln }

            trans.each do |t|
                name, meth = t[0], t[1]

                cln_method = cln.instance_method(meth)
                self::MASK_INFO[cln_method] = self::MASK_INFO[meth]
                self::MASK_INFO.delete meth

                cln.module_eval "remove_method :#{meth}"

                if self::MASKS.key? name
                    self::MASKS[name].unshift cln_method
                else
                    original_method = instance_method(name)
                    self::MASKS[name] = [cln_method, original_method]
                    self::MASK_INFO[original_method] = self

                    module_eval(<<-CODE,"maskable.rb",70)
                    if instance_methods.include? "#{name}"
                        remove_method :#{name}
                    end

                    def #{name}(*a,&b)
                        mk = Method::Mask.new(:#{name}, self, 
                            self.class::MASKS[:#{name}], a, b)
                        if Thread.current['__running_mask']
                            Thread.current['__running_mask'] << mk
                        else
                            Thread.current['__running_mask'] = [mk]
                        end
                        
                        return Method.rest
                    ensure
                        if Thread.current['__running_mask'].size == 1
                            Thread.current['__running_mask'] = []
                        else
                            Thread.current['__running_mask'].pop
                        end
                    end

                    CODE
                end
            end
        end
    end

    # 
    # Run from within a masked method to indicate that the
    # mask call stack should stop after this method and return
    # its result without running anymore masked methods of
    # the called method.
    # 
    def self.final
        Thread.current['__running_mask'].last.finished
    end
    
    #
    # Contains the state of a masked method call stack.
    # 
    class Mask
        def initialize(name, obj, list, args, block)
            @name = name
            @obj = obj
            @list = list
            @args = args
            @block = block
            @cur = 0
            @mod
            @finished = false
        end

        attr_reader :name, :obj, :list, :args, :block, :mod

        #
        # Runs the call stack
        # 
        def run(args=nil,&block)
            out = nil
            unless args
                args = @args
                block = @block
            end

            @cur.upto(@list.size - 1) do |idx|
                @cur = idx + 1
                mask = @list[idx]
                @mod = obj.class::MASK_INFO[mask]
                out = mask.bind(@obj).call(*args,&block)
                break if @finished
            end
            return out
        end

        #
        # Sets the state of the mask to finished.
        # 
        def finished
            @finished = true
        end
    end

    # 
    # Called from within a masked method. Calles the rest
    # of the masked methods for the method called and returns
    # the result. This gives the method the ability to send the data
    # to the other masked methods, see the return data and decide
    # if it wants to take some other course of action based on it.
    # 
    def self.rest(a=nil,&block)
        #pp Thread.current['__running_mask']
        cur = Thread.current['__running_mask'].last
        return nil unless cur

        unless a
            cur_args =  cur.args
            cur_block = cur.block
        else
            cur_args = a
            cur_block = block
        end

        out = nil

        begin
            out = cur.run(a,&block)
        rescue Object => e
            new_bt = e.backtrace.dup
            new_bt.delete_if do |l|
                /maskable.rb/.match(l)
            end
            new_bt << e.backtrace.last if /maskable.rb/.match(e.backtrace.last)

            new_bt.unshift cur.mod.to_s + "##{cur.name}"
            e.set_backtrace new_bt
            raise
        end

        cur.finished

        return *out
    end
end

class Object
    extend Method::Maskable
end

=begin

This is the old rest, here for reference only now.

def #{name}(*a,&b)
    out = nil
    masked = nil
    Thread.current['__running_mask'] = []
    catch(:__maskable_done) {
        self.class.const_get('MASKS')[:#{name}].each do |masked|
            Thread.current['__running_mask'] << [self, :#{name}, masked, [a,b]]
            break if Thread.current['__running_mask_op'] == :finish
            if masked.kind_of? Symbol
                out = __send__(masked,*a,&b)
            else
                out = masked.bind(self).call(*a,&b)
            end

            Thread.current['__running_mask'].pop
        end
    }


    return *out
rescue Object => e
    original_mod = self.class.const_get("MASK_INFO")[masked]
    new_bt = [e.backtrace.last]
    new_bt.unshift original_mod.to_s + "##{name}"
    e.set_backtrace new_bt
    raise
ensure
    Thread.current['__running_mask'] = nil
    Thread.current['__running_mask_op'] = nil
end
=end

if $0 == __FILE__

module HeaderRequire
    def do_something(*a)
        puts "---- start header"
        puts "---- self=#{self.inspect}"
        Method.rest(12)
        puts "---- a=#{a}"
        puts "---- end header"
    end
end

module MaskTest2
    def do_something(*a)
        puts "-------- start masktest2"
        puts "-------- self=#{self.inspect}"
        Method.rest
        puts "-------- a=#{a}"
        puts "-------- end masktest2"
    end
end

module TestMixin
    def jump_off_a_cliff
        puts "EEEEEK! (#{self.class})"
    end
end

class String
    extend Method::Maskable

    def do_something(*a)
        puts "-- start string"
        puts "-- self=#{self.inspect}"
        puts "-- a=#{a}"
        puts "-- end string"
        return false
    end

    include TestMixin
    add_mask HeaderRequire
    add_mask MaskTest2
end

p String.ancestors
p String.show_masks

o = "blah"
o.jump_off_a_cliff
o.do_something("Hi")

module SpecialRequire
    def require(mod)
        puts "You want #{mod}, ok?"
        if mod == "blah!"
            puts "blah i say! blah!!"
            #Method.rest
            puts "sssssssssssssS"
            return :woop
        end
        #raise SyntaxError, "no, you dont want that"
    end
end

Object.add_mask SpecialRequire

p Object.ancestors

p require('blah!')

require 'you want whom?'

end
