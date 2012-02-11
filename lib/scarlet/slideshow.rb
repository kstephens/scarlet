module Scarlet
  class Slideshow
    attr_reader :input_file, :erb_input, :slides, :options

    def initialize(enumerable, options={})
      @options = options
      @formatter = options[:format].nil? ? Scarlet::Formatter.default : Scarlet::Formatter.for(options[:format])
      @input_file = options[:input_file]

      if (@erb_input = options[:erb_input]).nil?
        @erb_input = enumerable.sub!(/\A\s*<!-- *ERB *-->/mi, '') || @input_file =~ /\.erb$/
      end
      if @erb_input
        enumerable = ERB.new(enumerable).result(binding)
      end
      # "":some_link.html => "some_link.html":some_link.html
      enumerable.gsub!(/(\s)"":(\S+)/){|m| %Q{#{$1}"#{$2}":#{$2}}}

      @slides = slice(enumerable)
      slide_number = 0
      @slides.each do |slide|
        slide.slideshow = self
        slide.slide_number = (slide_number += 1)
        slide.format!(@formatter)
      end
    end
    def output_dir; options[:output_dir]; end

    def n_slides
      @slides.size
    end

    def render
      template = File.read(options[:template] || @formatter.default_template)
      result = ERB.new(template).result(binding)
      case @options[:format]
      when :html, :latex
      when :pdf
        result = Scarlet::Formatters::PDF.from_latex(result)
      else
        raise "Format #{@options[:format].inspect} not supported."
      end
      result
    end

    private

      def slice(enumerable)
        slides = []
        slide = nil
        enumerable.lines.each do |line|
          case line
          when /^\s*!SLIDE\s*/
            slide = Scarlet::Slide.new(:verbose => @options[:verbose])
            slide.classes = $'.strip
            slide.output_dir = output_dir
            slides << slide
          when /^\s*!TITLE\s*/
            slide.title = $'.strip
          else
            next unless slide
            if ! slide.title && line =~ /^\s*h\d\.\s+(.+)$/
              slide.title = $1
            end
            slide.text << line
          end
        end
        return slides
      end
  end
end
