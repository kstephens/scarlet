module Scarlet::Formatters
  class PDF < LATEX
    def self.from_latex(latex)
      require 'rtex'
      RTeX::Document.new(latex).to_pdf
    end
  end
end
