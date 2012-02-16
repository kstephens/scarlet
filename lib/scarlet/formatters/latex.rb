module Scarlet::Formatters
  class LATEX < Base
    def text
      redcloth_text.to_latex
    end

    def process_code code, language
      "<notextile>" <<
        Scarlet::Highlighter.run(code, :format => "latex", :lexer => language, :arguments => "-P verboptions='fontfamily=lcmtt'") <<
        "</notextile>"
    end

    def process_image *args
      img = super
      "<notextile>#{img.image_latex}</notextile>"
    end

    def required_image_format; :png; end

    def self.default_template
      File.join(File.dirname(__FILE__), "..", "templates", "latex", "default.erb")
    end
  end
end
