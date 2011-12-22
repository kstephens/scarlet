require 'scarlet/image'

module Scarlet
  class Image
    class Gnuplot < self
      attr_accessor :gp_file

      def css_class_default; :gnuplot; end

      def gp_file
        @gp_file ||=
          "#{output_dir}/image/#{name.to_s.gsub(/[^-_a-z0-9]/i, '-')}.gp".freeze
      end
      alias :src_file :gp_file

      def generate_image!
        # raise "Unsupported image_format #{image_format.inspect}" unless image_format == :svg
        FileUtils.mkdir_p(File.dirname(svg_file))
        system! "#{gnuplot_cmd} #{gp_file.inspect}"
      end

      def gnuplot_cmd
        "gnuplot #{gnuplot_opts}"
      end

      def gnuplot_opts
        @options[:gnuplot_opts] || ""
      end

      def src_document
        @src_document ||=
          <<"END"
set terminal #{image_format} #{gnuplot_image_format_options} enhanced size #{image_width},#{image_height} 
set output '#{image_file}'
#{super}
END
      end

      def gnuplot_image_format_options
        case image_format
        when :png
          "transparent nocrop"
        else
          ''
        end
      end
    end # class
  end # class
end # module

