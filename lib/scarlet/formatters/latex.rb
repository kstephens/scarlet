require 'RedCloth'

module Scarlet::Formatters
  class LATEX
    include Scarlet::Formatters::Base

    def text
      RedCloth.new(slide.text).to_latex
    end

    def process_code code, language
      "<notextile>" << Scarlet::Highlighter.run(code, :format => "latex", :lexer => language, :arguments => "-P verboptions='fontfamily=lcmtt'") << "</notextile>"
    end

    def self.default_template
      File.join(File.dirname(__FILE__), "..", "templates", "latex", "default.erb")
    end
  end
end
