# == jenkins_config::createfirstaccount
# Copyright 2013 OpenStack Foundation.
# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Our goal is to create the first user account with the gerrit2 user
# credentials. If the first account was already created, then bail and
# be done with it.  This is only useful for bootstraping other commands
# that we'll need for a fully automated gerrit account setup.
#
#

class jenkins_config::createfirstaccount (
    $environment = $settings::environment,
)
{
  $config_lib = "/opt/config/${environment}/lib"
  $acct_script = 'createfirstaccount_jenkins.rb'
  file { "/opt/config/${environment}/lib/createfirstaccount_jenkins.rb":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0555',
      source  => "puppet:///modules/jenkins_config/scripts/${acct_script}",
      replace => true,
  }->
  exec { 'create first jenkins admin account':
            path      => ['/bin', '/usr/bin'],
            command   => "ruby1.8 ${config_lib}/${acct_script}",
            onlyif    => "ruby1.8 ${config_lib}/${acct_script} validate",
            logoutput => true,
        }
}