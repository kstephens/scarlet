require 'scarlet/image/pic'
require 'scarlet/image/graphviz'
require 'scarlet/image/gnuplot'

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
          opts_str.scan(/(\w+)[:=](?:"([^"]*)"|(\w+))/) do | key, word, str |
            opts[key.to_sym] = word || str
          end
          result = process_image(code, language, opts)
        else
          output << input
          input = ''
        end
        if m && result
          output <<
            m.pre_match <<
            (before || m[1] || '') <<
            result <<
            (after || m[4] || '')
          input = m.post_match
        end
      end
      output
    end

    def process_image code, language, opts
      case language
      when :pic
        opts[:input_format] ||= :pic
        img = Scarlet::Image::Pic
      when :dot, :graphviz, :gv
        opts[:input_format] ||= :dot
        img = Scarlet::Image::Graphviz
      when :gnuplot, :gp
        opts[:input_format] ||= :gnuplot
        img = Scarlet::Image::Gnuplot
      else
        raise "Image language #{language} is unsupported"
      end
      opts[:output_dir] = slide.output_dir
      opts[:verbose] = slide.options[:verbose]
      img = img.new(opts)
      img.code = code
      img.render! required_image_format
      img
    end

    def required_image_format; :svg; end
  end
end
