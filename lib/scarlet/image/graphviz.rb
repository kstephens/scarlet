require 'scarlet/image'

module Scarlet
  class Image
    class Graphviz < self
      attr_accessor :gv_file

      def css_class
        @css_class ||= :dot
      end

      def gv_file
        @gv_file ||=
          "#{output_dir}/image/#{name.to_s.gsub(/[^-_a-z0-9]/i, '-')}.dot".freeze
      end
      alias :src_file :gv_file

      def generate_image!
        FileUtils.mkdir_p(File.dirname(svg_file))
        system! "#{dot_cmd} -Tsvg -o #{svg_file.inspect} #{gv_file.inspect}"
      end

      def dot_cmd
        @dot_cmd ||=
          "dot #{dot_opts}".freeze
      end

      def dot_opts
        @dot_opts ||=
          @options[:graphviz_opts] || ""
      end

      def src_document
        super
      end
    end # class
  end # class
end # module

