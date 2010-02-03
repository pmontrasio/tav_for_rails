# = Add Rubyist AASM to your Rails application
#
# AASM adds finite state machines to Ruby classes
# This plugin adds the Rubyist version.
#
# == Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "AASM", options
#
# == Options and examples
#
# Put into <tt>options</tt> anything you might want to pass to 
# the "gem install rubyist-aasm" command line. It must be 
# a Ruby hash. Example <tt>:version => "~> 2.0.5"</tt>.
# There are default values for two options
#
# <tt>:lib => "aasm"</tt> sets the namespace. Change this one only if you know what you're doing.
#
# <tt>:source => "http://gems.github.com"</tt> downloads the gem from the right repository at the time of writing (sep 2009)

class Aasm
  def add(options = {})
    defaults = { :lib => "aasm", :source => "http://gems.github.com" }
    Utils.add_gem("rubyist-aasm", defaults.merge(options))
  end
end
