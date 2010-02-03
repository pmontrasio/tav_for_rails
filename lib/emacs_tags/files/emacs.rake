# Adapted from http://blog.feelingroot.com/?p=105
module Tags
  RUBY_FILES = FileList['**/*.rb', '**/*.erb'].exclude("pkg")
end

namespace "tags" do
  task :emacs => Tags::RUBY_FILES do
    puts "Making Emacs TAGS file"
    sh "/usr/bin/ctags -e #{Tags::RUBY_FILES}", :verbose => false
    # or sh "ctags-exuberant -e #{Tags::RUBY_FILES}", :verbose => false
  end
end

task :tags => ["tags:emacs"]
