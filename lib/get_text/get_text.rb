# = GetText
#
# Adds GetText to your Rails application (the original Mutoh's version)
#
# http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html
#
# http://github.com/mutoh
# 
# = Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "GetText", options
# 
# It configures ApplicationController to use the default language and
# adds the updatepo and makemo rake tasks to regenerate the .po and
# the .mo files
# 
# = Options and examples
#
# <tt>:project => "my_project"</tt>  the name of project in the .po files
# Default: the name of the Rails project
#
# <tt>:version => "2.0.4"</tt>       the version of gettext gems to install
# Default: the latest one
#
# <tt>:default_language => "en"</tt>  the default language of the project
# Default: "en"
#
# <tt>:languages => ["en","it"]</tt>  the languages supported by the project
# Default: ["en"]
#
# <tt>:method => "set_language"</tt>  the method used by ApplicationController
# to set the default language before executing actions.
# Default: "set_language"
class GetText
  def add(options = {})
    project = options[:project]
    unless project
      puts "Missing project name (use the option :project), exiting..."
      exit(1)
    end
    method = options[:method] || "set_language"
    language = options[:default_language] || "en"
    languages = options[:languages] || ["en"]
    
    # Don't propagate these options to the config.gem
    options.delete(:project)
    options.delete(:method)
    options.delete(:language)

    Utils.add_gems([["gettext", options],
                    ["gettext_activerecord", options],
                    ["gettext_rails", options]
                   ])


    dirs = []
    languages.each do |lang|
      dirs << "po/#{lang}"
    end
    Utils.make_directories(dirs)

    Utils.copy_to_tasks("get_text", "get_text.rake") do |line|
      line.gsub("#####PROJECT_NAME#####", project)
    end

    lines = <<EOL
  before_init_gettext :#{method}
  init_gettext "#{project}" 
                                          
  def #{method}
    set_locale "#{language}"
  end
EOL
    Utils.add_to_application_controller(lines)
  end
end
