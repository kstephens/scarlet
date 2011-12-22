module Scarlet
  class Image
    attr_accessor :code, :lines, :options
    attr_reader :identifier
    attr_accessor :image_format

    def self.option_attr *names
      names.each do | name |
        name = name.to_sym
        define_method(name) { | | options[name] ||= send(:"#{name}_default") }
        define_method(:"#{name}=") { | v | options[name] = v }
      end
    end
    option_attr :name, :title, :css_class, :input_format, :output_format, :output_dir,
    :width, :height

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
        lines.first =~ /^(\s*)/
        $1 || ''
        ).freeze
    end

    def title_default; "Image #{name}"; end
    def name_default; identifier; end
    def css_class_default; input_format; end

    def src_document
      @src_document ||=
        lines.map{|l| l.sub(/^#{indentation}/, '')}.join("\n")
    end

    def width_default; 800; end
    def image_width; width.to_i; end
    def height_default; 600; end
    def image_height; height.to_i; end
    def aspect_ratio
      image_width.to_f / image_height.to_f
    end

    def image_html
      @image_html ||=
        %Q{<object class="image image_svg image_#{css_class}" style="overflow-x: visible; overflow-y: visible;" data="#{image_path}" width="#{image_width}px" height="#{image_height}px" ></object>}.
        freeze
    end

    def image_latex
      @image_latex ||=
        "\\includegraphics{#{image_file}}".
        freeze
    end

    def image_path
      @image_path ||=
        image_file.sub(Regexp.new("^#{output_dir}/"), '').freeze
    end
    def base_file
      @base_file ||= src_file.sub(/\.[^.]+$/, '').freeze
    end
    def ps_file
      @ps_file ||= "#{base_file}.ps".freeze
    end
    def eps_file
      @eps_file ||= "#{base_file}.eps".freeze
    end
    def svg_file
      @svg_file ||= "#{base_file}.svg".freeze
    end
    def image_file
      @image_file ||= "#{base_file}.#{image_format}".freeze
    end

    def render! image_format
      self.image_format = image_format
      FileUtils.mkdir_p(File.dirname(src_file))
      File.open(src_file, "w+") do | out |
        # $stderr.puts "pic_document:\n#{pic_document}\n"
        out.write src_document
      end
      generate_image!
      system "set +x; open #{image_file.inspect}" if ENV['SCARLET_OPEN_IMAGE']
    end

    def system! cmd
      _cmd = options[:verbose] ? "set -x; #{cmd}" : cmd
      system(_cmd) or raise "Command #{cmd} failed"
      self
    end
  end
end
