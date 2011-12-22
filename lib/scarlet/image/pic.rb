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
        raise "Unsupported image_format #{image_format.inspect}" unless image_format == :svg
        FileUtils.mkdir_p(File.dirname(svg_file))
        system! "#{pic2plot_cmd} #{pic_file.inspect} > #{svg_file.inspect}"

        tmp = "#{svg_file}.tmp"
        File.open(svg_file) do | i |
          File.open(tmp, "w+") do | o |
            until i.eof?
              l = i.readline
              case l
              when /^<svg /
                l.sub!(/( width=")([\d.]+)(\w+)(")/) { | m | "#{$1}#{image_width}px#{$4}" }
                l.sub!(/( height=")([\d.]+)(\w+)(")/) { | m | "#{$1}#{image_height}px#{$4}" }
                l.sub!(/ preserveAspectRatio="[^"]+"/i, ' preserveAspectRatio="xMinYMin"')
                l.sub!(/( viewBox=")([\d.]+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)/i) do | m |
                  "#{$1}#{$2} #{0.5 + -0.5 / aspect_ratio} 1 #{1.0 / aspect_ratio}"
                end
              end
              o.write l
            end
            o.write i.read
          end
        end
        File.rename(tmp, svg_file)
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

