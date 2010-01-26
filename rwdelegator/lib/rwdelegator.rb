# Read from one object and write to another.
#
# WARNING: Highly expiremental code!
#
class RWDelegator

  def initialize( write, &read )
    @read = read
    @write = write

    # ensure other classes can deduce equality.
    read_class = @read.call.object_class
    unless read_class.method_defined?(:eq_with_rwdelegator?)
      read_class.class_eval %{
        def eq_with_rwdelegator?( other )
          if RWDelegator === other
            other == self
          else
            eq_without_rwdelegator?(other)
          end
        end
        alias_method :eq_without_rwdelegator?, :==
        alias_method :==, :eq_with_rwdelegator?
      }
    end
  end

  def inspect
    "#<#{object_class} #{@read.call.inspect}>"
  end

  def ==( other )
    @read.call == other
  end

  def method_missing( meth, *args, &blk )
    read = @read.call
    ditto = read.dup
    result = ditto.send( meth, *args, &blk )
    if ditto != read
      result = @write.send( meth, *args, &blk )
    end
    result
  end

end



