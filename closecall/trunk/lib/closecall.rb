# CloseCall
# by Derek Lewis <lewisd#f00f.net>

require 'closecall/fuzzy_match'

# Mixin that allows programs to make slight spelling and/or arity mistakes on 
# method calls and the program will still work. It achieves this by applying 
# some hueristics in method_missing. It searches all the methods on the object
# with the same (or compatible) arity, and uses the String#fuzzy_match method
# from the code snippets on rubyforge to find a method with a similar name. 
# When it finds one similar enough, it uses class_eval to define the method,
# so method_missing doesn't get called the next time.
#
# This is highly experimental, and is here primarily for expirementation with 
# Natural Langauge Computing.

module CloseCall

  MIN_SCORE = 0.75

  def find_similar_symbol(symbol, args)
    methods = self.public_methods.find_all do |sym|
      arity = self.method(sym).arity
      arity < 0 || arity == args
    end
    #p methods
    method,score = best_match(symbol, methods)
    #puts "Method: #{method}   Score: #{score}"
    return method if (score > MIN_SCORE)
    puts "Score = #{score}"
    return nil
  end

  def best_match(name, things)
    high_score = -1
    high_match = nil
    name = name.to_s
    things.each do |thing|
      str = thing.to_str
      if str != nil
        #puts "Checking #{str}"
        score = str.fuzzy_match(name)
        if (score > high_score)
          high_score = score
          high_match = thing
        end
      end
    end
    return high_match, high_score
  end

  def method_missing(symbol, *args)
    puts "Finding method for #{symbol} with #{args.length} args"
    sym = find_similar_symbol(symbol, args.length)
    if sym != nil
      method = method(sym)
      max_arity = self.public_methods.collect{|sym| self.method(sym).arity}.sort.last
      if !self.respond_to?(symbol)
        code = %'
          def #{symbol}(*args)
            case args.length'
        0.upto(max_arity) do |x|
          sym = find_similar_symbol(symbol, x);
          if (sym != nil)
            code += %'
            when #{x}
              if block_given?
                #{sym}(*args) { |*bargs| yield *bargs }
              else
                #{sym}(*args)
              end'
          end
        end
        code = code + %'
            else
              raise NameError, "no method similar to \'#{symbol}\' found for \#{args.length} args"
            end
          end'
        #puts code
        puts "defining method for #{symbol}"
        self.class.class_eval code
      end
      return self.send(symbol, *args) { |*bargs| yield *bargs }
    end
    raise NameError, "no method similar to `#{symbol}' with #{args.length} args for \"#{self}\":#{self.class}"
  end

  private :find_similar_symbol, :best_match

end

