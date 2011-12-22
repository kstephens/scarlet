module Scarlet
  class Image
    attr_accessor :code, :lines, :options
    attr_accessor :name, :title, :css_class
    attr_accessor :output_dir
    attr_reader :identifier

    def initialize options
      @options = options
      @@counter ||= 0
      @identifier = "image-#{@@counter += 1}".freeze
    end

    def lines
      @lines ||=
        @code.split("\n").freeze
    end

    def indentation
      @indentation ||=
        (
        lines.first =~ /^(\s*)#/
        $1 || ''
        ).freeze
    end

    def title
      @image ||=
        "Image #{name}".freeze
    end

    def name
      @name ||= identifier
    end

    def src_document
      @src_document ||=
        lines.map{|l| l.sub(/^#{indentation}#/, '')}.join("\n")
    end

    def image_width
      @image_width ||= (options[:width] || 800).to_i
    end

    def image_height
      @image_height ||= (options[:height] || 600).to_i
    end

    def aspect_ratio
      image_width.to_f / image_height.to_f
    end

    def image_html
      @image_html ||=
        %Q{<object class="image svg #{css_class}" data="#{image_path}" width="90%" ></object>}.
        freeze
    end

    def image_path
      @image_path ||=
        image_file.sub(Regexp.new("^#{output_dir}/"), '').freeze
    end

    def image_file
      svg_file
    end

    def ps_file
      @ps_file ||= 
        src_file.sub(/\.[^.]+$/, '.ps').freeze
    end

    def eps_file
      @eps_file ||= 
        ps_file.sub(/\.ps$/, '.eps').freeze
    end

    def svg_file
      @svg_file ||= 
        src_file.sub(/\.[^.]+$/, '.svg').freeze
    end

    def render_svg!
      FileUtils.mkdir_p(File.dirname(src_file))
      File.open(src_file, "w+") do | out |
        # $stderr.puts "pic_document:\n#{pic_document}\n"
        out.write src_document
      end

      generate_image!

      tmp = "#{svg_file}.tmp"
      File.open(svg_file) do | i |
        File.open(tmp, "w+") do | o |
          until i.eof?
            l = i.readline
            case l
            when /^<svg /
              # l.sub!(/ width="[^"]+"/, '')
              l.sub!(/( height=")([\d.]+)(\w+)(")/) { | m | "#{$1}#{$2.to_f / aspect_ratio}#{$3}#{$4}" }
              l.sub!(/ preserveAspectRatio="[^"]+"/i, ' preserveAspectRatio="xMinYMin"')
            #when /^<rect id="background" /
            #  l = EMPTY_STRING
            when /^<g id="content" /
              l.sub!(/ transform="[^"]+"/) do | m |
                m.sub(/(translate\()([^,]+),([^,]+)(\))/) do | m |
                  "#{$1}#{$2},#{$3.to_f - 0.25}#{$4}"
                end
              end
            end
            o.write l
          end
          o.write i.read
        end
      end
      File.rename(tmp, svg_file)

      system("open #{svg_file.inspect}") if ENV['SCARLET_OPEN_IMAGE']
      # exit 1

      self
    end
    alias :render! :render_svg!

  end
end
