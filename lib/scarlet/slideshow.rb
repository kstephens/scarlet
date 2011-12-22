module Scarlet
  class Slideshow
    attr_reader :slides, :options
    attr_accessor :output_dir

    def initialize(enumerable, options={})
      @options = options
      @output_dir = options[:output_dir]
      formatter = options[:format].nil? ? Scarlet::Formatter.default : Scarlet::Formatter.for(options[:format]) 
      @slides = slice(enumerable)
      @slides.each { |slide| slide.format!(formatter) }
    end

    def render
      case @options[:format]
      when :html
        template = File.read(options[:template] || Scarlet::Formatters::HTML.default_template)
        ERB.new(template).result(binding)
      when :latex
        template = File.read(options[:template] || Scarlet::Formatters::LATEX.default_template)
        ERB.new(template).result(binding)
      when :pdf
        template = File.read(options[:template] || Scarlet::Formatters::PDF.default_template)
        Scarlet::Formatters::PDF.from_latex(ERB.new(template).result(binding))
      else
        raise "Format not supported."
      end
    end
    
    private
    
      def slice(enumerable)
        slides = []
        slide = nil
        enumerable.lines.each do |line|
          if line.include? "!SLIDE"
            slide = Scarlet::Slide.new
            slide.output_dir = output_dir
            slides << slide
            slide.classes = line.gsub("!SLIDE", "").strip
          elsif line.include? "!TITLE"
            slide.title = line.gsub("!TITLE", "").strip
          else
            next unless slide
            if ! slide.title && line =~ /^\s*h\d\.\s+(.*)$/
              slide.title = $1
            end
            slide.text << line
          end
        end
        return slides
      end
  end
end
