# ***************************************************************
# ** Paas
# ***************************************************************
# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#####################################################################

#
# Note: if you already have a Rakefile in your project, you can copy this
#       file and include it here:
#       <your_project_root_dir>/lib/tasks/
#
#       also include paas.yaml file
#       forj-paas.rake/Rakefile and paas.yml must exist in same dir (for the time being)

#
# Dependencies:
# CLIs:
# hp cloud paas: apaascli
#   download: https://api.shared.apaas.hpcloudsvc.com/console/client/
# activestate paas: stackato
# cloud foundry based paas: cf
#   download: https://github.com/cloudfoundry/cli/blob/master/README.md#stable-release
#   note: CF v2 endpoint
#

require 'rake'
require 'rubygems'
require 'shell'
require 'yaml'


def load_paas_config
  rake_root = File.dirname(__FILE__)
  begin
    paas_info = {}
    paas_info = YAML.load_file(File.join(rake_root,'paas.yml'))
    return paas_info
  rescue Errno::ENOENT
    abort('could not load paas.yml')
  end

end

def shell_exec(cmd, cmd_opts)
  begin
    #sh = Shell.new
    #sh.transact { system(cmd, cmd_opts) > STDOUT}
    cmd += ' '
    cmd.concat(cmd_opts)
    output = `#{cmd}`
    output.split(/\n/).each { |line|
      line = line.gsub('/\"(.*)\"/', 'here\2')
      p line
    }
    if $?.exitstatus !=0
      raise
    end
  rescue StandardError => e
    puts e.message
    exit(false)
  end
end

def is_nilorempty?(string)
    string.nil? || string.empty?
end

def is_supported?(supported_paas, paas_flavor)
    (supported_paas.include? paas_flavor and
        (PAAS_FLAVOR == :hp or PAAS_FLAVOR == :stackato or PAAS_FLAVOR == :cf)) ? true : false
end


# ..Initialization...
# paas.yml file is required

paas_info = load_paas_config
PAAS_CMD = paas_info['paas_cli']
PAAS_FLAVOR = paas_info['paas_flavor'].intern   # convert string from yml file to symbol, todo: is this cool?
#supported_paas = %w(hp , stackato)
supported_paas = [:hp, :stackato, :cf]


namespace :paas do

   desc 'aPaas login'
   task :login do
     if is_supported?(supported_paas,PAAS_FLAVOR)
       case PAAS_FLAVOR
         when :hp, :stackato
            opts = "#{paas_info['paas_login_cmd']} --email #{paas_info['user']} --passwd '#{paas_info['pwd']}' "
            shell_exec(PAAS_CMD, opts)
         when :cf
            opts = "#{paas_info['paas_login_cmd']} -a #{paas_info['target_url']}  --u #{paas_info['user']} --p '#{paas_info['pwd']}' "
            shell_exec(PAAS_CMD, opts)
       end
     end
   end

   desc 'aPaas info'
   task :info  do
     begin
       if is_supported?(supported_paas,PAAS_FLAVOR)
            shell_exec(PAAS_CMD, paas_info['paas_info_cmd'])
       end
     end
   end

   desc 'Set apaas targer URL'
   task :target  do
     begin
       if is_supported?(supported_paas,PAAS_FLAVOR)
          cmd_opts = "#{paas_info['paas_target_cmd']} #{paas_info['target_url']}"
          shell_exec(PAAS_CMD, cmd_opts)
       end
     end
   end


   desc 'start app_name'
   task :start, [:app_name] do |t, args|
     if is_supported?(supported_paas,PAAS_FLAVOR)
        cmd_opts = "#{paas_info['paas_start_cmd']} #{args.app_name}"
        shell_exec(PAAS_CMD, cmd_opts)
     end
   end

   desc 'stop app_name'
   task :stop, [:app_name] do |t, args|
     if is_supported?(supported_paas,PAAS_FLAVOR)
        cmd_opts = "#{paas_info['paas_stop_cmd']} #{args.app_name}"
        shell_exec(PAAS_CMD, cmd_opts)
     end
   end

   desc 'restart app_name'
   task :restart, [:app_name] do |t, args|
     if is_supported?(supported_paas,PAAS_FLAVOR)
        cmd_opts = "#{paas_info['paas_restart_cmd']} #{args.app_name}"
        shell_exec(PAAS_CMD, cmd_opts)
     end
   end

   desc 'delete app_name'
   task :delete, [:app_name] do |t, args|
     if is_supported?(supported_paas,PAAS_FLAVOR)
        cmd_opts = "#{paas_info['paas_del_cmd']} #{args.app_name} -n"
        shell_exec(PAAS_CMD, cmd_opts)
     end
   end

  desc 'application deployment - creates application instance'
  task :deploy, [:app_name] do |t, args|
    if is_supported?(supported_paas,PAAS_FLAVOR)
        cmd_opts = "#{paas_info['paas_push_cmd']} #{args.app_name} -n"
        shell_exec(PAAS_CMD, cmd_opts)
    end
  end

  desc 'application update'
  task :update, [:app_name] do  |t, args|
    if is_supported?(supported_paas,PAAS_FLAVOR)
        cmd_opts = "#{paas_info['paas_update_cmd']} #{args.app_name} -n"
        shell_exec(PAAS_CMD, cmd_opts)
    end
  end

   desc 'display resource usage for the application'
   task :stats, [:app_name] do  |t, args|
     if is_supported?(supported_paas,PAAS_FLAVOR)
       cmd_opts = "#{paas_info['paas_stats_cmd']} --json #{args.app_name}"
       shell_exec(PAAS_CMD, cmd_opts)
     end
   end

   desc 'list deployed applications'
   task :list do
     if is_supported?(supported_paas,PAAS_FLAVOR)
       cmd_opts = "#{paas_info['paas_list_cmd']} --json"
       shell_exec(PAAS_CMD, cmd_opts)
     end
   end

end
