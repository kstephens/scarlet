require 'open3'

module Scarlet
  module Highlighter
    def self.run(text, options={})
      options[:format] ||= "html"
      options[:lexer] ||= "text"
      options[:arguments] ||= ""
      verbose = options.delete(:verbose)
      cmd = "pygmentize -f #{options[:format]} -l #{options[:lexer]} #{options[:arguments]}"
      $stderr.puts "+ #{cmd}" if verbose
      result = nil
      Open3.popen3(cmd) do | stdin, stdout, *something |
        stdin.puts(text)
        stdin.close
        result = stdout.read.strip
      end
      result
    end
  end
end
