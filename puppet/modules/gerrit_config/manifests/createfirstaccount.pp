# == gerrit_config::createfirstaccount
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
# Our goal is to create the first user account with the gerrit2 user credentials.
#  If the first account was already created, then bail and be done with it.
# This is only useful for bootstraping other commands that we'll need for a
#  fully automated gerrit account setup.
#
#

class gerrit_config::createfirstaccount (
    $gerrit_id = 'gerrit2',
    $environment = $settings::environment,
    $debug_flag = false,
)
{
  include gerrit_config::pyscripts

  # if the accounts 0 id does not exist, then create it and take it for $gerrit_id
  if($debug_flag)
  {
    $debug_opts = '--loglevel debug'
  }
  else
  {
    $debug_opts = ''
  }

  cacerts::sshgenkeys{$gerrit_id:
                for_root     => true,
                make_default => true
              } ->
  cacerts::known_hosts { $gerrit_id:
    for_root      => true,
    hostname      => 'localhost',
    portnum       => '29418',
    manage_sshdir => true,        # TODO: turn this to false once we merge to latest config
                                  # option added to be compatible with upstream modules that create the ~/.ssh folder!!
                                  # see more info here:  https://bugs.launchpad.net/openstack-ci/+bug/1209464
  } ->
  exec { 'gerrit_config::createfirstaccount':
            path    => ['/bin', '/usr/bin'],
            command => "python /opt/config/${environment}/lib/createfirstaccount.py ${debug_opts} --ssh_pubkey /root/.ssh/gerrit2.pub",
            onlyif  => "python /opt/config/${environment}/lib/createfirstaccount.py --check_exists ${debug_opts}",
            notify  => Service['gerrit'],
        }

}