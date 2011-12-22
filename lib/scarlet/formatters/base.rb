module Scarlet::Formatters
  module Base
    attr_accessor :slide

    def initialize(slide)
      @slide = slide
    end

    def slide_text
      output = ''
      input = slide.text
      until input.empty?
        m = before = after = result = nil
        case input
        when /([\t\n])?@@@(?:\ ([a-z]+))?(.+?)@@@([\t\n])?/m
          m = $~
          language = (m[2] || :text).to_sym
          code = m[3]
          result = process_code(code, language)
        when /([\t\n])?!IMAGE\s+BEGIN\s+([a-zA-Z]+)(\s+[^\n]+)?(.+?)!IMAGE\s+END(\s*[\t\n])?/m
          m = $~
          language = ($~[2] || 'unknown-image-type').downcase.to_sym
          code = m[4]
          after = m[5]
          opts_str = m[3]
          opts = { }
          opts_str.scan(/(\w+):(\w+)/) do | key, val |
            opts[key.to_sym] = val
          end
          result = process_image(code, language, opts)
        else
          output << input
          input = ''
        end
        if m && result
          # $stderr.puts "m = #{m.inspect}"
          output <<
            m.pre_match <<
            (before || m[1] || '') <<
            result <<
            (after || m[4] || '')
          input = m.post_match
          # $stderr.puts "output = #{output}"
          # $stderr.puts "input  = #{input}"
        end
      end
      output
    end

    def process_image code, language, opts
      case language
      when :pic
        img = Scarlet::Image::Pic
      else
        raise "Image language #{language} is unsupported"
      end
      img = img.new(opts)
      img.code = code
      img.output_dir = slide.output_dir
      img.render!
      img
    end
  end
end
