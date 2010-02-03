# = TzInfo
#
# Adds TzInfo to your Rails application
# 
# TzInfo is a daylight-savings aware timezone support for Ruby
# http://tzinfo.rubyforge.org/
# http://tzinfo.rubyforge.org/doc/files/README.html
# 
# == Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "TzInfo", options
# 
# == Options and examples
# Anything you might want to pass to "gem install tzinfo"
# as a Ruby hash. Example: :version => "~> 0.3.13"
class TzInfo
  def add(options = {})
    Utils.add_gem("tzinfo", options)
  end
end
