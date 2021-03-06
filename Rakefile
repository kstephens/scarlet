begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "scarlet"
    gemspec.summary = "Slideshow Generator with Textile"
    gemspec.description = "Generates XHTML slideshows from text files using Textile for markup. Does syntax highlighting if Pygments is installed."
    gemspec.email = "mail@joao-carlos.com"
    gemspec.homepage = "http://github.com/jcxplorer/scarlet"
    gemspec.authors = ["Joao Carlos Cardoso"]
    gemspec.rubyforge_project = "scarlet"
    
    gemspec.files = Dir['bin/**/*', 'lib/**/{*,.[a-z]*}']
    
    gemspec.add_dependency('open4', '>= 0.9.6')
    gemspec.add_dependency('RedCloth', '>= 4.2.2')
    gemspec.add_dependency('rtex', '>= 2.1.1')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc "Install/check for prerequisites."
task :prereqs do
  sh "gem install rtex open4 RedCloth"
  sh "which pic2plot || echo 'pic2plot not found: !IMAGE PIC not supported, install gnuplot plotutils.'"
  sh "which dot || echo 'dot not found: !IMAGE PIC not supported, install graphviz.'"
end

desc "Run scarlet on example/*.textile."
task :example do
  [ :html, :latex, :pdf ].each do | format |
    Dir['example/*.textile'].each do | src |
      sh "bin/scarlet -f #{format} -v #{src}"
    end
  end
end

task :default => :example

