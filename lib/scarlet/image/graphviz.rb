require 'scarlet/image'

module Scarlet
  class Image
    class Graphviz < self
      attr_accessor :gv_file

      def css_class_default; :dot; end

      def gv_file
        @gv_file ||=
          "#{output_dir}/image/#{name.to_s.gsub(/[^-_a-z0-9]/i, '-')}.dot".freeze
      end
      alias :src_file :gv_file

      def generate_image!
        # raise "Unsupported image_format #{image_format.inspect}" unless image_format == :svg
        FileUtils.mkdir_p(File.dirname(svg_file))
        system! "#{dot_cmd} -T#{image_format} -o #{image_file.inspect} #{gv_file.inspect}"
      end

      def dot_cmd
        "dot #{dot_opts}"
      end

      def dot_opts
        @options[:graphviz_opts] || ""
      end

      def src_document
        super
      end
    end # class
  end # class
end # module

