# = EmacsTags
#
# Adds a rake task to build the TAGS file for emacs.
# Run it as rake tags:emacs
# 
# == Usage
#
#   rails = TavForRails::Project.new(options)
#   rails.add "EmacsTags"
class EmacsTags
  def add(options = {})
    Utils.copy_to_tasks("emacs_tags", "emacs.rake")
  end
end
