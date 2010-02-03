#
# Rakefile for TavForRails
#
# Use setup.rb or gem for installation.
# You don't need to use this file directly.
#
# Copyright(c) 2009 Paolo Montrasio
# This program is licenced under the GPLv3
#

require "rubygems"
require "rake"
require "rake/rdoctask"
require "rake/packagetask"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"

PKG_VERSION = "0.1.0"

require "./tav_for_rails.gemspec"

############################################################
# Misc tasks
############################################################
desc "Run all tests"
task :test do
  Dir.chdir("test") do
    if RUBY_PLATFORM =~ /win32/
      sh "rake.bat", "test"
    else
      sh "rake", "test"
    end
  end
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end
