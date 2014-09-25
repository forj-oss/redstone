# == runtime_project::account_config
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
# Copyright 2012 Hewlett-Packard Development Company, L.P
# Make sure account configuration is in place.
# Testing it:
#
class runtime_project::account_config()
{
  include runtime_project::params
  $config_dir  = $runtime_project::params::gerrit_config_dir
  $config_spec ="${config_dir}/${runtime_project::params::gerrit_user}.config"
  $sshcmd        = "${runtime_project::params::ssh_cmd} -oStrictHostKeyChecking=no -i ${runtime_project::params::gerrit_pem} -p ${runtime_project::params::gerrit_port}"

  $cspec_content = "#!/bin/sh\nexec ${sshcmd} \"\$@\"\n"
  # setup gerrit configuration file in secure location
  file { $config_dir:
    ensure  => directory,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0700',
    recurse => true,
  } ->
  file { $config_spec:
    ensure  => present,
    replace => 'no',
    content => $cspec_content,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0700',
  }
}
