
 class Module
   def child this = self
     @child ||= self.class.new
     @child.module_eval{ include this}
     @child
   end

   def has_child
     defined? @child and @child
   end

   def override m, &b
     this = self

     m = Module.new{
       @m = this.instance_method m
       this.module_eval{ remove_method m rescue nil }

       module_eval <<-code
         def #{ m }(*a, &b)
           um = ObjectSpace._id2ref #{ @m.object_id }
           um.bind(self).call *a, &b
         end
       code

       child.module_eval &b if b
     }

     include(m.has_child ? m.child : m)
   end
end 

