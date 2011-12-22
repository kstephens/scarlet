module Scarlet
  class Slide
    attr_accessor :classes, :text, :title
    attr_reader :identifier
    attr_accessor :output_dir
    
    def initialize
      @@counter ||= 0
      @identifier = "slide-#{@@counter}"
      @@counter += 1
      @text = ""
      @classes = ""
    end
    
    def format!(formatter)
      @text = formatter.new(self).text
    end
  end
end
