gem 'RedCloth'
require 'RedCloth'
require 'scarlet/image/pic'
require 'scarlet/image/graphviz'
require 'scarlet/image/gnuplot'

module Scarlet::Formatters
  class Base
    attr_accessor :slide

    def initialize(slide)
      @slide = slide
    end

    def redcloth_text
      @redcloth_text ||= RedCloth.new(slide_text)
    end

    def slide_text
      # $stderr.puts "  ### Slide #{slide.identifier}:"
      output = ''
      input = slide.text
      until input.empty?
        m = before = after = result = nil
        case input
        when /([\t\n])?@@@(?:\ ([a-z]+))?(.+?)@@@( *?[\t\n])?/mi
          m = $~
          # $stderr.puts "  Found code in:\n#{m[0]}----"
          language = (m[2] || :text).to_sym
          code = m[3]
          result = process_code(code, language)
        when /([\t\n])?!IMAGE +BEGIN +([a-zA-Z]+)([ \t]+[^\n]+)?\n(.+?\n)[ \t]*!IMAGE +END( *?[\t\n])?/m
          m = $~
          # $stderr.puts "  Found !IMAGE in:\n #{m[0]}----"
          language = (m[2] || 'unknown-image-type').downcase.to_sym
          code = m[4]; after = m[5]
          opts_str = m[3] || ''; opts = { }
          opts_str.scan(/(\w+)[:=](?:"([^"]*)"|(\w+))/) do | key, word, str |
            opts[key.to_sym] = word || str
          end
          # $stderr.puts "!IMAGE code::\n#{code}\n----"
          result = process_image(code, language, opts)
        else
          output << input
          input = ''
        end
        if m && result
          # $stderr.puts "  Replaced with:\n#{result}----"
          input =
            m.pre_match <<
            (before || m[1] || '') <<
            result <<
            (after  || m[4] || '') <<
            m.post_match
        end
      end
      # $stderr.puts "  Output #{slide.identifier}:\n#{output}----"
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
