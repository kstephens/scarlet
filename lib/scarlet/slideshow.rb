module Scarlet
  class Slideshow
    attr_reader :slides, :options

    def initialize(enumerable, options={})
      @options = options
      @formatter = options[:format].nil? ? Scarlet::Formatter.default : Scarlet::Formatter.for(options[:format]) 
      @slides = slice(enumerable)
      @slides.each { |slide| slide.format!(@formatter) }
    end
    def output_dir; options[:output_dir]; end

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
          if line.include? "!SLIDE"
            slide = Scarlet::Slide.new(:verbose => @options[:verbose])
            slide.output_dir = output_dir
            slides << slide
            slide.classes = line.gsub("!SLIDE", "").strip
          elsif line.include? "!TITLE"
            slide.title = line.gsub("!TITLE", "").strip
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
