require 'optparse'

module Scarlet
  module Runner
    def self.go!(argv)
      options = { :format => :html }
      generate = nil

      OptionParser.new do |opts|
        opts.banner = <<-EOF
Usage:
  scarlet [options] file
  scarlet --generate destination
EOF

        argv = ["-h"] if argv.empty?

        opts.on "-f", "--format FORMAT", "Format to generate" do |format|
          options[:format] = format.to_sym
        end

        opts.on "-t", "--template FILE", "ERB template file to use" do |file|
          options[:template] = file
        end

        opts.on "-g", "--generate DEST", "Generate javascript and stylesheet files" do |path|
          generate = path
        end

        opts.on "-d", "--directory DEST", "Output directory" do |path|
          options[:output_dir] = path
        end

        opts.on "-v", "--verbose", "Verbose output" do |path|
          options[:verbose] = 1
        end

        opts.on "-o", "--output DEST", "Output file" do |path|
          options[:output_dir] = File.dirname(path)
          options[:output_file] = path
        end

        opts.on "-h", "--help", "Show this message" do
          puts opts
          exit
        end

        begin
          opts.parse!(argv)
        rescue OptionParser::InvalidOption => e
          STDERR.puts e.message, "\n", opts
          exit(-1)
        end
      end

      if argv[0]
        file = File.read(argv[0])
        options[:output_dir] ||= argv[0].sub(/\.textile$/, '')
        slideshow = Scarlet::Slideshow.new(file, options)
        case options[:format]
        when :html
          output_file = options[:output_file] ||= "#{options[:output_dir]}/index.html"
          output_dir  = options[:output_dir]  || File.dirname(options[:output_file])
          generate  ||= output_dir
          out = File.open(output_file, "w+")
          $stderr.puts "+ Generating #{output_file}"
        end
        Scarlet::Generator.files(generate) if generate
        out ||= $stdout
        out.puts slideshow.render
        out.close if out != $stdout
        $stderr.puts "+ DONE."
      end
    end
  end
end
