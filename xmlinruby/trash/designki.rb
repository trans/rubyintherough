

module Blow

  module XmlDesignKit

    class Element

      class << self

        #

        def attribute(elem, name, type=nil)
          if type
            code=%{
              def #{elem}_#{name}(value)
                @#{elem}_#{name} = #{type}.new(value)
              end
            }
          else
            code=%{
              def #{elem}_#{name}(value)
                @#{elem}_#{name} = value
              end
            }
          end

          module_eval code
        end

        #

        def value(name, type=nil)
          if type
            code=%{
              def #{name}(obj, atts=nil)
                @#{name} = #{type}.new(obj)
                (atts||{}).each do |a, v|
                  send("#{name}_\#{a}", v)
                end
              end
            }
          else
            code=%{
              def #{name}(obj, atts=nil)
                @#{name} = obj
                (atts||{}).each do |a, v|
                  send("#{name}_\#{a}", v)
                end
              end
            }
          end

          module_eval code
        end

        #

        def element(name, type=nil, &block)
          type ||= Element

          code=%{
            def #{name}(atts=nil, &block)
              @#{name} = #{type}.new(&block)
              (atts||{}).each do |a, v|
                send("#{name}_\#{a}", v)
              end
            end
          }

          module_eval code
        end

      end


      def initialize(name, &block)
        instance_eval(&block)
      end

      def to_xml
        str = ''
        tags = instance_variables.select{ |iv| iv !~ /_/ }
        tags = tags.collect{ |t| t.sub(/^@/, '') }
        tags.each do |tag|
          att = tag_attributes(tag)

          att = att.collect{ |k,v| %[#{k}="#{v}"] }
          str << "<#{tag} #{att}></#{tag}>"
        end
        str
      end

      private

      def tag_attributes(tag)
        hsh = {}
        atts = instance_variables.select{ |v| v =~ /^@#{tag}_/ }
        atts.each do |a|
          t, name = a.split('_')
          hsh[name] = instance_variable_get(a)
        end
        hsh
      end

    end

  end

end



if $0 == __FILE__

  class Try < Blow::XmlDesignKit::Element
    value :a
    attribute :a, :x
  end

  t=Try.new('try') do
    a 1, :x => 1
  end

  puts t.to_xml

end
