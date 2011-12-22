require 'RedCloth'

module Scarlet::Formatters
  class HTML
    include Scarlet::Formatters::Base
    
    def text
      RedCloth.new(slide_text).to_html
    end

    def process_code code, language
      "<notextile><div class=\"code\">" + Scarlet::Highlighter.run(code, :format => "html", :lexer => language) + "</div></notextile>"
    end

    def process_image code, language, opts
      img = super
      "<notextile>#{img.image_html}</notextile>"
    end

    def self.default_template
      File.join(File.dirname(__FILE__), "..", "templates", "html", "default.erb")
    end
  end
end
