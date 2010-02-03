# = Stack trace dump  
#
# Puts a stack dump into a string.
# 
# == Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "StackDump"
# 
# Installs the stack_dump.rb file into the lib directory.
# 
# == Example
# 
# This code writes the full stack dump in the log file.
#
#   begin
#     # some exception generating code here
#   rescue Exception => e
#     logger.error "EXCEPTION #\{e\}\n#\{StackDump.trace\}"
#   end
class StackDump
  def add(options = {})
    Utils.copy_to_lib("stack_dump", "stack_dump.rb")
  end
end
