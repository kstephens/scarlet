module Scarlet
  class Slide
    attr_accessor :slideshow
    attr_accessor :classes, :text, :title
    attr_reader :identifier
    attr_accessor :options, :output_dir, :slide_number

    def initialize options
      @options = options
      @text = ""
      @classes = ""
    end

    def identifier
      @identifier ||= "slide-#{slide_number - 1}"
    end

    def format!(formatter)
      @text = formatter.new(self).text
    end
  end
end
