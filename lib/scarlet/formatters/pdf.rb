require 'rtex'

module Scarlet::Formatters
  class PDF < LATEX
    def self.from_latex(latex)
      RTeX::Document.new(latex).to_pdf
    end
  end
end
