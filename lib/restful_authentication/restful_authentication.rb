# = RestfulAuthentiction
#
# Adds RestfulAuthentication to your Rails application,
# a plugin that provides a foundation for securely managing user
# authentication.
# http://github.com/technoweenie/restful-authentication
#
# WARNING: The installation of RestfulAuthentication requires git.
#
# == Usage
#  rails = TavForRails::Project.new(options)
#  rails.add "RestfulAuthentication", options
#
# It runs this generator
#
#   script/generate authenticated user sessions --include-activation --stateful --aasm
#
# and installs authenticated_system.rb in lib and includes it into ApplicationController
#
# == Options and examples
#
# Anything you might want to pass to the generator
# as a String. Example:
#
#   "--rspec --skip-migration --skip-routes --old-passwords"
class RestfulAuthentication
  def add(options = {})
    args = options.class == String ? options : ""

    Utils.git_clone("git://github.com/technoweenie/restful-authentication.git restful_authentication",
                    :directory => "vendor/plugins")
    Utils.generate("authenticated user sessions --include-activation --stateful --aasm #{args}")
    # for --include-activation and for --stateful add to config/environment.rb 
    # config.active_record.observers = :user_observer
    Utils.add_routes("  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete }")
    Utils.db_migrate # execs the migration to create the users table
    Utils.add_to_rails_initializer("  config.active_record.observers = :user_observer")
    Utils.copy_to_lib("restful_authentication", "authenticated_system.rb")
    Utils.add_to_application_controller("  include AuthenticatedSystem")
  end
end
