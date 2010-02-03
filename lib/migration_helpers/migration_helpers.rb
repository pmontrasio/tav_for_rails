# = ForeignKeys
#
# Adds the foreign_key and remove_foreign_key methods to your migrations.
# You might want to check the more complete redhillonrails plugin at
# http://github.com/harukizaemon/redhillonrails (soon to be deleted as of
# November 2 2009)
# 
# == Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "ForeignKeys", options
# 
# Installs migration_helpers.rb into the lib directory.
# 
# It currently supports the postgresql, mysql and jdbcmysql adapters but it will
# probably work with most databases and adapters. You just have to modify
# migration_helpers.rb in the TavForRails lib/migration_helpers/file/ directory
# to use the right foreign key creation statement for your database and hook
# it up to the name of your adapter. It will be straightforward after you
# look at the code.
# 
# To use the helper methods build the migration like this:
# 
#   require "migration_helpers"
# 
#   class MyMigration < ActiveRecord::Migration
#     extend MigrationHelpers
#     def self.up
#       create :books do |t|
#          t.column author_id, :integer
#          ...
#       end
#       foreign_key :books, :author_id, :authors
#     end
#  
#     def self.down
#       remove_foreign_key :books, :author_id
#       drop_table :books
#     end
#   end
#
# There is further information about the methods arguments in the source code of the module.
class ForeignKeys
  def add(options = {})
    Utils.copy_to_lib("migration_helpers", "migration_helpers.rb")
  end
end
