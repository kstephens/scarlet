require 'scarlet/image'

module Scarlet
  class Image
    class Gnuplot < self
      attr_accessor :gp_file

      def css_class
        @css_class ||= :gnuplot
      end

      def gp_file
        @gp_file ||=
          "#{output_dir}/image/#{name.to_s.gsub(/[^-_a-z0-9]/i, '-')}.gp".freeze
      end
      alias :src_file :gp_file

      def generate_image!
        FileUtils.mkdir_p(File.dirname(svg_file))
        cmd = "set -x; #{gnuplot_cmd} #{gp_file.inspect}"
        # $stderr.puts "  Generate GNUPLOT #{title.inspect} -> SVG"
        system(cmd) or raise "Command #{cmd} failed"
        self
      end

      def gnuplot_cmd
        @gnuplot_cmd ||=
          "gnuplot #{gnuplot_opts}".freeze
      end

      def gnuplot_opts
        @gnuplot_opts ||=
          @options[:gnuplot_opts] || ""
      end

      def src_document
        @src_document ||=
          <<"END"
set terminal svg enhanced size #{image_width},#{image_height} 
set output '#{svg_file}'
#{super}
END
      end
    end # class
  end # class
end # module

