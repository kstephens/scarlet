require 'optparse'
require 'shellwords'

module Scarlet
  module Runner
    def self.go!(argv)
      options = { :format => :html }
      generate = nil

      OptionParser.new do |opts|
        opts.banner = <<-EOF
Usage:
  scarlet [options] file
EOF

        argv = ["-h"] if argv.empty?
        if env_opts = ENV['SCARLET_OPTS'] and ! env_opts.empty?
          argv = Shellwords.shellwords(env_opts) + argv
          $stderr.puts "  #{$0} #{argv * " "}"
        end

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
          options[:verbose] ||= 0
          options[:verbose] += 1
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

      if input_file = argv[0]
        file = File.read(input_file)
        options[:input_file] = input_file
        options[:output_dir] ||= argv[0].sub(/\.textile(\.erb)?$/, '')
        slideshow = Scarlet::Slideshow.new(file, options)
        case options[:format]
        when :html
          output_file = options[:output_file] ||= "#{options[:output_dir]}/index.html"
        when :latex, :pdf
          output_file = options[:output_file] ||= input_file.sub(/\.textile(\.erb)?$/, ".#{options[:format]}")
        end
        if output_file
          output_dir  = options[:output_dir]  || File.dirname(options[:output_file])
          generate  ||= output_dir if options[:format] == :html
          out = File.open(output_file, "w+")
        end
        $stderr.puts "+ Generating #{output_file}" if output_file && options[:verbose]
        Scarlet::Generator.files(generate) if generate
        out ||= $stdout
        out.puts slideshow.render
        out.close if out != $stdout
        $stderr.puts "+ DONE." if options[:verbose]
        system("set +x; open #{output_file.inspect}") if output_file && ENV['SCARLET_OPEN_OUTPUT']
      end
    end
  end
end
