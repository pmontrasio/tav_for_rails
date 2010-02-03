# Currently supported adapters: postgresql, mysql, jdbcmysql.
#
# To use the helper methods build the migration like this:
# 
# require "migration_helpers"
# 
# class MyMigration < ActiveRecord::Migration
#   extend MigrationHelpers
#   def self.up
#     create :books do |t|
#       t.column author_id, :integer
#       ...
#     end
#     foreign_key :books, :author_id, :authors
#   end
#   
#   def self.down
#     remove_foreign_key :books, :author_id
#     drop_table :books
#   end
# end

# Added as is by tav_for_rails.
module MigrationHelpers
  # Adds a foreign key to a table
  # Examples
  #
  # foreign_key(:pictures, :user_id, :users)
  #   creates a foreign key from pictures.used_id to users.id
  #
  # foreign_key(:pictures, :user_name, :users, :name)
  #   creates a foreign key from pictures.user_name to users.name
  #
  def foreign_key(from_table, from_column, to_table, to_column = "id")
    constraint_name = "fk_#{from_table}_#{from_column}" 

    adapter = db_type
    case adapter
    when :mysql, :postgresql
      execute "alter table #{from_table}
              add constraint #{constraint_name}
              foreign key (#{from_column})
              references #{to_table}(#{to_column})"
    else
      puts "Don't know how to add foreign keys for a #{adapter} adapter"
    end
  end

  # Removes the foreign key at from_table.from_column
  def remove_foreign_key(from_table, from_column)
    constraint_name = "fk_#{from_table}_#{from_column}" 

    adapter = db_type
    case adapter
    when :postgresql
      execute "alter table #{from_table} drop constraint #{constraint_name}"
    when :mysql
      execute "alter table #{from_table} drop foreign key #{constraint_name}"
    else
      puts "Don't know how to remove foreign keys for a #{adapter} adapter"
    end
  end

  private

  def db_type

    adapters = {
      "postgresql" => :postgresql,
      "mysql" => :mysql,
      "jdbcmysql" => :mysql
    }

    adapter_type = Rails.configuration.database_configuration[Rails.configuration.environment]["adapter"]
    adapter = adapters[adapter_type]

    adapter ? adapter: adapter_type
  end

  # TODO It would be DRYer if the methods could access the models to add and remove the definitions of the has_many/belongs_to associations
  
end
