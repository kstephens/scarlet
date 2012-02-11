require 'rubygems'
gem 'open4'
require 'open4'

module Scarlet
  module Highlighter
    def self.run(text, options={})
      options[:format] ||= "html"
      options[:lexer] ||= "text"
      options[:arguments] ||= ""
      pid, stdin, stdout, stderr = Open4.popen4("pygmentize -f #{options[:format]} -l #{options[:lexer]} #{options[:arguments]}")
      stdin.puts(text)
      stdin.close
      stdout.read.strip
    end
  end
end
