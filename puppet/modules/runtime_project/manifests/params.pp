# Class: runtime_project::params
#
# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# hold parameters for runtime_project config
class runtime_project::params {
  case $::osfamily {
    'Debian': {
      $config_project    = 'forj-config'
      $config_home       = "/opt/config/${settings::environment}"
      $git_home          = "/opt/config/${settings::environment}/git"
      $gerrit_user       = 'forjio'
      $gerrit_useremail  = 'forjio@localhost.org'
      $gerrit_username   = 'Forj Configuration User'
      $gerrit_port       = 29418
      $gerrit_config_dir = '/opt/config/cacerts/ssh_keys/config'
      $gerrit_pem        = '/opt/config/cacerts/ssh_keys/forjio'
      $ssh_cmd           = '/usr/bin/ssh'
      $sshex             = "exec ${ssh_cmd}"
      $strictopt         = '-oStrictHostKeyChecking=no'
      $portopt           = "-p ${gerrit_port}"
      $pemopt            = "-i ${gerrit_pem}"
      $gerrit_ssh        = "${sshex} ${strictopt} ${pemopt} ${portopt} \"\$@\""
      $environment       = $settings::environment
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}
             The 'runtime_project' module only supports osfamily Debian.")
    }
  }
}
