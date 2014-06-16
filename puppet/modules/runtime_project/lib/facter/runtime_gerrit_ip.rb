# == runtime_project::runtime_gerrit_ip
# Copyright 2012 Hewlett-Packard Development Company, L.P
# Get the current active ip from maestro for the gerrit server.
# this is currently contained in json file defined by :
# jimador::json_config_location  

# not working require 'json' if Puppet.features.json
require 'json'

Facter.add("runtime_gerrit_ip") do
  confine :kernel => "Linux"
# not working  confine :feature => :json
  setcode do
    json_config_location = Facter.value('json_config_location')
    if File.exist? json_config_location
      #Open json file and find the value gerrit in site.node['tools'].name
      # return value for ip in tool_url
      theobj  = nil
      git_url = nil
      git_ip  = nil
      File.open( json_config_location, "r" ) do |f|
        theobj = JSON.load( f )
      end
      theobj['site']['node'].each do |node|
        node['tools'].each do |tool|
          if tool['name'] == 'gerrit'
            git_url = tool['tool_url'] 
            break
          end
        end
      end
            
      if git_url == '' || git_url == nil || git_url == '#'
        Facter::Util::Resolution.exec("echo")
      else
        # need to parse out the hostname from URI value
        git_ip = URI.parse(git_url).host
        Facter::Util::Resolution.exec("echo #{git_ip}")
      end
    else
      Facter::Util::Resolution.exec("echo")  # config doesn't exist
    end
  end
end