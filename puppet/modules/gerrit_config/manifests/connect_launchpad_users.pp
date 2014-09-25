# == gerrit_config::connect_launchpad
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
# Connect a launchpad openid with gerrit
#
#

class gerrit_config::connect_launchpad_users (
  $source_module_name     = 'openstack_project',
  $lpsync_pub_key_content = undef,
  $lpsync_key_content     = undef,
  $lpuser                 = 'launchpadsync_rsa',
  $enabled                = false,
)
{

  if ($enabled == true) {

    if ($lpsync_pub_key_content == undef) {
      $lp_sync_pubkey = cacerts_getkey("${cacerts::params::ssh_keys_dir}/${lpuser}.pub")
    } else {
      $lp_sync_pubkey = $lpsync_pub_key_content
    }

    if ($lpsync_key_content == undef) {
      $lp_sync_key = cacerts_getkey("${cacerts::params::ssh_keys_dir}/${lpuser}")
    } else {
      $lp_sync_key = $lpsync_key_content
    }

  #
  #  initialize gerrit configuration for launchpad
  #

    file { '/var/log/gerrit_user_sync':
      ensure  => directory,
      owner   => 'root',
      group   => $gerrit_config::params::gerrit_user,
      mode    => '0775',
      require => User[$gerrit_config::params::gerrit_user],
    }
    file { "${gerrit_config::params::gerrit_home}/.sync_logging.conf":
      ensure  => present,
      owner   => 'root',
      group   => $gerrit_config::params::gerrit_user,
      mode    => '0644',
      source  =>
        "puppet:///modules/${source_module_name}/gerrit/launchpad_sync_logging.conf",
      require => User[$gerrit_config::params::gerrit_user],
    }
    file { $gerrit_config::params::gerrit_ssh_home:
      ensure  => directory,
      owner   => $gerrit_config::params::gerrit_user,
      group   => $gerrit_config::params::gerrit_user,
      mode    => '0700',
      require => User[$gerrit_config::params::gerrit_user],
    }
    if $lp_sync_key != '' {
      file { "${gerrit_config::params::gerrit_ssh_home}/launchpadsync_rsa":
        ensure  => present,
        owner   => $gerrit_config::params::gerrit_user,
        group   => $gerrit_config::params::gerrit_user,
        mode    => '0600',
        content => $lp_sync_key,
        replace => true,
        require => User[$gerrit_config::params::gerrit_user],
      }
    }
    if $lp_sync_pubkey != '' {
      file { "${gerrit_config::params::gerrit_ssh_home}/launchpadsync_rsa.pub":
        ensure  => present,
        owner   => $gerrit_config::params::gerrit_user,
        group   => $gerrit_config::params::gerrit_user,
        mode    => '0644',
        content => $lp_sync_pubkey,
        replace => true,
        require => User[$gerrit_config::params::gerrit_user],
      }
    }
    file { "${gerrit_config::params::gerrit_home}/.launchpadlib":
      ensure  => directory,
      owner   => $gerrit_config::params::gerrit_user,
      group   => $gerrit_config::params::gerrit_user,
      mode    => '0775',
      require => User[$gerrit_config::params::gerrit_user],
    }
    file { "${gerrit_config::params::gerrit_home}/.launchpadlib/creds":
      ensure  => present,
      owner   => $gerrit_config::params::gerrit_user,
      group   => $gerrit_config::params::gerrit_user,
      mode    => '0600',
      content => template("${source_module_name}/gerrit_lp_creds.erb"),
      replace => true,
      require => User[$gerrit_config::params::gerrit_user],
    }
  }

}