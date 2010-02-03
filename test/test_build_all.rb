#!/usr/bin/ruby

require "../lib/tav_for_rails"

include TavForRails

project_name = "eventstrending"

rails = TavForRails::Project.create(project_name,
                                 :rails_version => "2.3.5",
                                 :database => "postgresql")
unless rails
  puts "Failed to create the Rails project"
  exit 1
end

rails.add "GetText", :project => project_name, :version => "2.1.0",
                     :default_language => "it", :languages => ["en", "it"]
rails.add "WillPaginate" #, :version => "2.3.11"
rails.add "EmacsTags"
rails.add "VerboseLogging"
rails.add "ForeignKeys"
rails.add "StackDump"
rails.add "LogFiltering"
rails.add "Aasm"
rails.add "TzInfo"
#rails.add "Hoptoad", :api_key => "1234567890" # use your key
rails.add "RestfulAuthentication"

=begin

rails.add "Selenium"

rails.add "orbited" ???
see http://fuglyatblogging.wordpress.com/2008/10/08/http-push-aka-comet-with-orbited-and-rails/


rails.add "delayed_job"
http://github.com/tobi/delayed_job/tree/master
=end

rails.install_gems


