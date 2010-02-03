# = WillPaginate
#
# Adds a will_paginate gem to your Rails application
# http://wiki.github.com/mislav/will_paginate
# 
# == Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "WillPaginate", options
# 
# == Options and examples
# <tt>:version => "2.3.11"</tt>
#       the version of gettext gems to install. Default: 2.3.11
class WillPaginate
  def add(options = {})
    version = options[:version] || "2.3.11"
    Utils.add_gem("will_paginate", {
                    :version => "~> #{version}",
                    :lib => "will_paginate",
                    :source => "http://gemcutter.org"
                  })
  end
end

