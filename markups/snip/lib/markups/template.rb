require 'yaml'

require 'markups/table'


module MarkUps

  YAML.add_private_type('template') { |tag, data|
    Template.new( data )
  }

  def self.parse( doc )
    YAML::load( doc )
  end

  #

  class Template

    def initialize( parts )
      @parts = parts
      parse
    end

    def parse
      @parts.each do |key, part|
        part.parse( key, nil, @parts ) if part.respond_to?(:parse)
      end
    end

    def to_html
      @parts['main.foo'].to_html
    end

  end

#       #
#
#       def self.yaml_to_css( yml )
#         css = ''
#         yml.each { |k,v|
#           css << "#{k} {"
#           v.each { |k2, v2|
#             if k2 == 'body'
#               # k
#             else
#               css << "#{k2}: #{v2};"
#             end
#           }
#           css << "}\n"
#         }
#         css
#       end

  #

  YAML.add_private_type('stylesheet') { |tag, data|
    Stylesheet.new( data )
  }


  class Stylesheet

    def initialize( parts )
      @parts = parts
      parse
    end

    def parse
      p @parts
    end

  end

end


