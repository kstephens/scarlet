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
        %Q{<object class="image svg #{css_class}" style="overflow-x: visible; overflow-y: visible;" data="#{image_path}" width="#{image_width}px" height="#{image_height}px" ></object>}.
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

      system("open #{svg_file.inspect}") if ENV['SCARLET_OPEN_IMAGE']
      # exit 1

      self
    end
    alias :render! :render_svg!

  end
end
