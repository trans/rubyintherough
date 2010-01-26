# 
class Binding
  attr_accessor :back_binding
  def back ; @back_binding ; end
  def back=(b) ; @back_binding=b ; end
  # 
  def call(*args,&blk) ; @call.call(*args,&blk) ; end
  def call=(p) ; raise ArgumentError unless p.kind_of?(Proc); @call=p ; end
end 
