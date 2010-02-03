=begin
    tav_for_rails - a time saver for the creation of Rails applications
    Copyright (C) 2009  Paolo Montrasio

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end


require "fileutils"

# This is the module to require and include in your configuration files
#
#   require "rubygems"
#   require "tav_for_rails"
#   include TavForRails
#
# Use the methods of TavForRails::Project to setup your project
module TavForRails

  VERSION = "0.1.0"

  # This module is a collection of class methods that can be used by the plugins
  # to work on the Rails configuration files and add gems, plugins and
  # libraries to the system and the application directories.
  module Utils
    # The name of the project
    def self.project
      @project
    end

    @available_plugins = []
    # The available plugins as an Array of Class objects
    def self.available_plugins
      @available_plugins
    end

    # Require the plugins in the lib directory
    # Loop on dirs and require lib/dir_name/dir_name.rb
    @plugins_dir = File.dirname(__FILE__)
    # The full path to the plugins directory
    def self.plugins_dir
      @plugins_dir
    end

    Dir.foreach(plugins_dir) do |file_name|
      next if file_name == "." || file_name == ".."
      if File.stat("#{plugins_dir}/#{file_name}").directory?
        class_name = file_name.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
        @available_plugins << class_name
        require "#{file_name}/#{file_name}.rb"
      end
    end

    # Class methods that implement common functionalities for plugins

    # Adds lines to config/environment.rb
    def self.append_to_config_environment(lines)
      self.append_to_file("#{self.project}/config/environment.rb", lines)
    end

    # Adds lines to config/routes.rb
    def self.add_routes(lines)
      self.add_to_file("#{self.project}/config/routes.rb",
                       "ActionController::Routing::Routes.draw do \|map\|") do |old_fd, new_fd|
        new_fd.puts lines
        # don't copy the lines of old_df that match the new routes
        while old_line = old_fd.gets
          # this is not a good way to make the check but it's ok for what I need to
          # to in the restful_authentication plugin
          new_fd.puts old_line if old_line.chomp == ""
          re = "^#{Regexp.escape(old_line.chomp)}"          
          new_fd.puts old_line unless Regexp.new(re, Regexp::MULTILINE).match(lines)
        end

      end
    end

    # Turn a hash like { :opt1 => "val1", :opt2 => "val2" } into the
    # --opt1="val1" --opt2="val2" command line options string
    #
    # options:: the command line options/values hash
    def self.command_line_options(options = {})
      opt = []
      options.each do |option, value|
        opt << "--#{option}='#{value}'"
      end
      opt.join(" ")
    end

    # Copies a file from a plugin's own file repository to the config/initializers directory
    # The files repository is the lib/plugin_name/files directory
    #
    # plugin:: String, the name of the plugin
    # file_name:: String, the name of the file
    def self.copy_to_initializers(plugin, file_name)
      initializers = "#{self.project}/config/initializers"
      FileUtils.copy "#{plugins_dir}/#{plugin}/files/#{file_name}", initializers if plugin && file_name
    end

    # Copies a file from a plugin's own file repository to the lib/tasks directory.
    # The files repository is lib/plugin_name/files.
    #
    # If called with a block, the block is called for every line read from the file
    # and the line is passed as argument to the block. The return value of the block
    # will be added into the destination file instead of the read line.
    #
    # plugin:: String, the name of the plugin
    # file_name:: String, the name of the file
    def self.copy_to_tasks(plugin, file_name)
      tasks = "#{self.project}/lib/tasks"
      src = File.new("#{File.dirname(__FILE__)}/#{plugin}/files/#{file_name}", "r")
      dst = File.new("#{self.project}/lib/tasks/#{file_name}", "w")
      while line = src.gets
        line = yield line if block_given?
        dst.puts line
      end
      src.close
      dst.close
    end

    # Copies a file from a plugin's own file repository to the lib directory
    # The files repository is the lib/plugin_name/files directory
    # If called with a block, the block is called for every line read from the file
    # and the line is passed as argument to the block. The return value of the block
    # will be added into the destination file instead of the read line.
    #
    # plugin:: String, the name of the plugin
    # file_name:: String, the name of the file
    def self.copy_to_lib(plugin, file_name)
      tasks = "#{self.project}/lib"
      src = File.new("#{File.dirname(__FILE__)}/#{plugin}/files/#{file_name}", "r")
      dst = File.new("#{self.project}/lib/#{file_name}", "w")
      while line = src.gets
        line = yield line if block_given?
        dst.puts line
      end
      src.close
      dst.close
    end

    # Adds gems definitions inside the Rails::Initializer.run loop in config/environment
    # Gems are added at the beginning of the loop so if add_gems is called twice the gems
    # added by the second call will be activated <em>before</em> the gems added by the
    # first call.
    #
    # gems:: an Array of either gem names (String) or gems names and options arrays.
    #
    # Example
    # <tt>add_gems(["locale", "locale_rails", [ "gettext", { :version => "~> 2.0.4" } ]])</tt>
    def self.add_gems(gems)
      self.add_to_file("#{self.project}/config/environment.rb",
                       'Rails::Initializer.run do \|config\|') do |old_fd, new_fd|
        # Add the gems
        gems.each do |gem, options|
          new_fd.puts add_gem_string_for(gem, options)
        end
      end

    end

    # Like #add_gems but for a single gem
    #
    # gem:: String, a gem name
    # options:: Hash, the options for the gem configuration
    #
    # Example
    # <tt>add_gem("gettext", :version => "~> 2.0.4")</tt>
    def self.add_gem(gem, options = {})
      self.add_to_file("#{self.project}/config/environment.rb",
                       'Rails::Initializer.run do \|config\|') do |old_fd, new_fd|
        # Add the gem
        new_fd.puts add_gem_string_for(gem, options)
      end

    end

    # Adds lines to the Rails::Initializer loop
    #
    # lines:: String, what to add
    #
    def self.add_to_rails_initializer(lines)
      self.add_to_file("#{self.project}/config/environment.rb",
                       'Rails::Initializer.run do \|config\|') do |old_fd, new_fd|
        # Add the gem
        while line = old_fd.gets
          if line.chomp == "end"
            new_fd.puts lines
            new_fd.puts line
            break
          end
          new_fd.puts line
        end
      end

    end

    # Adds lines to application_controller.rb
    # Lines are inserted after <tt>class ApplicationController < ActionController::Base</tt>
    # If add_to_application_controller is called twice the lines added by the second call
    # will be executed <em>before</em> the lines added by the first call.
    #
    # lines:: a String containing all the lines to be added
    def self.add_to_application_controller(lines)
      self.add_to_file("#{self.project}/app/controllers/application_controller.rb",
                       "class ApplicationController < ActionController::Base") do |old_fd, new_fd|
        new_fd.puts lines
      end
    end

    # Installs a plugin executing the "script/plugin install #{cmd_line}" script
    def self.install_plugin(cmd_line)
      self.system("script/plugin install #{cmd_line}")
    end

    # Installs software executing "git clone #{cmd_line}" in the Rails application directory
    def self.git_clone(cmd_line, options = {})
      self.system("git clone #{cmd_line}", options)
    end

    # Installs a plugin executing the "script/plugin install #{cmd_line}" script
    def self.generate(cmd_line)
      self.system("script/generate #{cmd_line}")
    end

    # Creates the directories listed in the dirs array
    def self.make_directories(dirs)
      dirs = [dirs] if dirs.class == String
      dirs.each do |dir|
        FileUtils.mkdir_p("#{self.project}/#{dir}")
      end
    end

    # Runs a migration
    #
    # option:: String, anything after rake db:migrate. Don't start it with a :
    #          for down, redo, reset and up.
    #
    # Example:
    #
    #   Utils.db_migrate "up VERSION=2"
    def self.db_migrate(option = "")
      cmd = Regexp.new("^down|^redo|^reset|^up").match(option) ? "rake db:migrate:#{option}" : "rake db:migrate #{option}"
      self.system(cmd)
    end

    private

    def self.project=(project)
      @project = project
    end

    # Saves the current directory, changes it to the Rails application dir and
    # to options[:directory] (if specified), executes cmd_line and goes back to 
    # the original saved location.
    def self.system(cmd_line, options = {})
      cwd = Dir.pwd
      Dir.chdir(self.project)
      Dir.chdir(options[:directory]) if options[:directory]
      puts cmd_line
      Kernel.system(cmd_line)
      Dir.chdir(cwd)
    end

    # Generates a config.gem line for gem and the options passed as argument
    def self.add_gem_string_for(gem, options = {})
      args = options.inspect
      args = args[1, args.length - 2] # removes the { }
      args = ", " + args unless args == ""
      %(  config.gem "#{gem}"#{args})
    end

    # Opens file, goes to the first line that matches marker and executes the block
    # passing the file description to file as argument.
    def self.add_to_file(file, marker)
      new_file = "#{file}.new"
      original_file = "#{file}.original"
      
      # Make a backup copy of config_environment just in case something goes wrong
      FileUtils.copy file, original_file

      # Open config/environment.rb.new to write
      # Open the copy of config_environment to read
      new_fd = File.new(new_file, "w")
      old_fd = File.new(original_file, "r")
      
      # Copy lines up to Rails::Initializers
      while true
        line = old_fd.gets
        new_fd.puts line
        break if line.match(marker)
      end

      yield old_fd, new_fd
      new_fd.puts

      # Keep copying the file
      while line = old_fd.gets
        new_fd.puts line
      end
      
      # Close the files
      new_fd.close
      old_fd.close

      # Copy new to .rb
      FileUtils.copy new_file, file
      
      # Delete the copies
      FileUtils.remove new_file
      FileUtils.remove original_file
    end

    # Appends lines to the end of file
    def self.append_to_file(file, lines)
      fd = File.new(file, "a")
      fd.puts lines
      fd.puts
    end

  end
  
  class Project
    
    # Creates a TavForRails::Project object but doesn't create the
    # Rails application. Use the +create+ method for that.
    # new is useful to call the +add+ method on an existing project
    # without overwriting the existing files.
    def initialize(project = nil, options = {})
      return if project.nil?

      @project = project
      Utils.project = project
      
      @version = options[:rails_version]
      options.delete(:rails_version)
      if @version
        @version = "_" + @version + "_"
      else
        @version = ""
      end

    end

    # Creates a new Rails project by running <tt>rails project</tt> and
    # passing to it the <tt>options</tt> hash as command line options,
    # transformed into --key=value pairs.
    #
    # If <tt>:database => "postgresql"</tt> it creates the 
    # <tt>#{project}_development</tt>
    # and the <tt>#{project}_test</tt>
    # databases and a <tt>project</tt> role which owns the two databases.
    # You can choose the version of rails to run by passing the
    # <tt>:version => "x.y.z"</tt> option.
    #
    # It returns a TavForRails::Project object.
    def self.create(project = nil, options = {})
      return if project.nil?
      rails = self.new(project, options)
      
      # Builds the rails command line from the options hash
      cmd = "rails #{@version} #{project} #{Utils.command_line_options(options)}"
      puts cmd
      system(cmd)
      
      if options[:database] == "postgresql"
        puts
        puts "Attempting to create the development and test databases"
        cmd = "createdb -U postgres --encoding=UTF-8 #{project}_development"
        puts cmd
        system(cmd)
        cmd = "createdb -U postgres --encoding=UTF-8 #{project}_test"
        puts cmd
        system(cmd)
        # creates the database user and gives it ownership of the dbs
        system("psql -U postgres -c 'create role #{project} login;alter database #{project}_development owner to #{project};alter database #{project}_test owner to #{project}'")
      end

      puts

      return rails
    end
    
    # Creates a instance of the <tt>what</tt> tav_for_rails plugin
    # and calls its <tt>add</tt> method to configure the Rails application.
    # The <tt>options</tt> hash is passed unchanged to the plugin.
    def add(what, options = {})
      puts "Adding #{what}"
      plugin = Utils.const_get(what).new
      plugin.add(options)
    end

    # Lists on standard output all the available plugins, one per line.
    def plugins
      Utils.available_plugins.each do |plugin|
        puts plugin
      end
    end

    # Executes rake gems:install to install all the gems configured in the application
    # so far. It defaults to run rake as the super user to make a system wide gem
    # installation. If you don't want to do that pass the <tt>:sudo => false</tt> argument.
    def install_gems(options = {})
      sudo = options[:sudo] == false ? "" : "sudo "
      puts
      puts "Installing gems"
      puts "This might take a while if gems are to be downloaded and compiled."
      if sudo == "sudo "
        puts
        puts "WARNING!"
        puts "You asked to install gems as root so you might be asked to type in"
        puts "your password to run the sudo command."
        puts "The password won't be asked if you used it recently." 
      end
      Utils.system("#{sudo}rake gems:install")
      puts "Done"
    end
  end

end
