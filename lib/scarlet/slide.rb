module Scarlet
  class Slide
    attr_accessor :classes, :text, :title
    attr_reader :identifier
    attr_accessor :options, :output_dir

    def initialize options
      @options = options
      @@counter ||= -1 # 0-origin slide numbers
      @identifier = "slide-#{@@counter += 1}"
      @text = ""
      @classes = ""
    end

    def format!(formatter)
      @text = formatter.new(self).text
    end
  end
end
