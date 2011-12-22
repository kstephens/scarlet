require 'scarlet/image'

module Scarlet
  class Image
    class Pic < self
      attr_accessor :pic_file

      def css_class
        @css_class ||= :pic
      end

      def pic_file
        @pic_file ||=
          "#{output_dir}/image/#{name.to_s.gsub(/[^-_a-z0-9]/i, '-')}.pic".freeze
      end
      alias :src_file :pic_file

      def generate_image!
        FileUtils.mkdir_p(File.dirname(svg_file))
        cmd = "set -x; #{pic2plot_cmd} #{pic_file.inspect} > #{svg_file.inspect}"
        # $stderr.puts "  Generate PIC #{title.inspect} -> SVG"
        system(cmd) or raise "Command #{cmd} failed"
        self
      end

      def pic2plot_cmd
        @pic2plot_cmd ||=
          "pic2plot -Tsvg --portable-output --page-size #{image_width}x#{image_height} --font-name HersheySans-Bold #{pic2plot_opts}".freeze
      end

      def pic2plot_opts
        @pic2plot_opts ||=
          # "--font-size 0.01".freeze
          "".freeze
      end

      def src_document
        width = 4
        height = width / aspect_ratio
        @src_document ||=
          <<"END"
.PS #{width}i #{height}i
#{super}
.PE
END
      end
    end # class
  end # class
end # module

