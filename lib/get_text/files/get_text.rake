desc "Update pot/po files to match new version." 
task :updatepo do
  require 'gettext/tools'
  MY_APP_TEXT_DOMAIN = "#####PROJECT_NAME#####"
  MY_APP_VERSION     = "#####PROJECT_NAME##### 1.0.0" 
  GetText::ErbParser.init(:extnames => ['.rhtml', '.erb'])
  files = Dir.glob("{app,lib,components}/**/*.{rb,rhtml,rxml,rjs}")
  # Add other paths with files + Dir.glob(path)
  files = files + Dir.glob("app/**/*.erb")
  GetText.update_pofiles(MY_APP_TEXT_DOMAIN, files, MY_APP_VERSION)
end

desc "Create mo-files for L10n" 
task :makemo do
  require 'gettext/tools'
  GetText.create_mofiles({ :verbose => true, :po_root => "po", :mo_root => "locale"})
end
