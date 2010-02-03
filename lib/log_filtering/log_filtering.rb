# = LogFiltering
# 
# Filters out parameters from the log files
#
# This is not much of a time saver but it might be useful
# to add a <tt>rails.add "LogFiltering"</tt> to your tav_for_rails
# configurations and be sure to censor the values of the password
# parameters from your logs and don't have to remember to do it
# later on.
# Log filtering is added into ApplicationController.
# 
# == Usage
#   rails = TavForRails::Project.new(project_options)
#   rails.add "LogFiltering", options
# 
# == Options and examples
#
# <tt>:filter => ["param1", "param2", ... "paramN"]</tt>
# Adds <tt>filter_parameter_logging :param1, :param2, ... :paramN</tt>
# to ApplicationController. The default value is
# <tt>["password", "password_confirmation"]</tt>
class LogFiltering
  def add(options = {})
    if options[:filter]
      filters = ":" + options[:filter].join(", :")
    else
      filters = ":password, :password_confirmation"
    end

    Utils.add_to_application_controller("  filter_parameter_logging #{filters}")
  end
end
