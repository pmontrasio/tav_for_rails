# = VerboseLogging
#
# Adds context information to every log line.
# This makes it easier to trace a user session in the logs.
# 
# == Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "VerboseLogging"
# 
# Installs the logger_code_ext.rb file into the lib directory which
# monkey patches several Rails classes.
# 
# Each log line starts with
# 
#   yyyymmaaHHMMSS:log level:process id:logged user name:session id
# 
# Example
#
#   20090912073325:DEBUG:13465:paolomon:adf43874c21b0766a751f55c1aaf936d
# 
# The logged user name is generated by current_person.login for compatibility
# with the table layout of the RestfulAuthentication plugin.
# The session id is the value of the session cookie.
# 
# It shows NOLOGIN if there is no logged in user and NOSESSION if there is no
# session information.
# 
# Example
#
#   20090809132938:INFO:26907:NOLOGIN:NOSESSION
# 
# You can set the $SESSION_ID global variable to get log lines like
#
#   20090809132938:INFO:26907:NOLOGIN:my_session_id
#
# This is useful when you run scripts with script/runner because it lets
# you identify their output into the log files.

class VerboseLogging
  def add(options = {})
    Utils.append_to_config_environment('require "logger_core_ext" # VerboseLogging')
    Utils.copy_to_lib("verbose_logging", "logger_core_ext.rb")
  end
end