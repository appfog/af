require "af/cli"

command_files = "../af/cli/{app,framework,runtime,infra}/*.rb"
Dir[File.expand_path(command_files, __FILE__)].each do |file|
  require file unless File.basename(file) == 'base.rb'
end
