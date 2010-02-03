# = Hoptoad
#
# Installs the Rails plugin to report errors to the Hoptoad service.
# You need to register to Hoptoad to use it.
# http://www.hoptoadapp.com/ 
# http://github.com/thoughtbot/hoptoad_notifier/
# 
# == Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "Hoptoad", options
# 
# It adds an initializers in config/initializers with the API key
# to access the service.
# The plugin is installed from
# git://github.com/thoughtbot/hoptoad_notifier.git
# 
# == options and examples
#
# <tt>:api_key => "1234567890abcdef"</tt>   Your Hoptoad API key. Default: "<your api key here>"
class Hoptoad
  def add(options = {})
    apy_key = options[:api_key] || "<your api key here>"
    # FIXME Hoptoad deprecated the plugin. Install the gem instead.
    Utils.install_plugin("git://github.com/thoughtbot/hoptoad_notifier.git")
    Utils.copy_to_initializers("hoptoad", "hoptoad.rb") do |line|
      line.gsub("#####API_KEY#####", api_key)
    end
  end
end
