# == Class: openstack_project::review
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

# Current thinking on Gerrit tuning parameters:

# database.poolLimit:
# This limit must be several units higher than the total number of
# httpd and sshd threads as some request processing code paths may need
# multiple connections.
# database.poolLimit = 1 + max(sshd.threads,sshd.batchThreads)
#   + sshd.streamThreads + sshd.commandStartThreads
#   + httpd.acceptorThreads + httpd.maxThreads
# http://groups.google.com/group/repo-discuss/msg/4c2809310cd27255
# or "2x sshd.threads"
# http://groups.google.com/group/repo-discuss/msg/269024c966e05d6a

# container.heaplimit:
# core.packedgit*
# http://groups.google.com/group/repo-discuss/msg/269024c966e05d6a

# sshd.threads:
# http:
#  //groups.google.com/group/repo-discuss/browse_thread/thread/b91491c185295a71

# httpd.maxWait:
# 12:07 <@spearce> httpd.maxwait defaults to 5 minutes and is how long gerrit
#                  waits for an idle sshd.thread before aboring the http request
# 12:08 <@spearce> ironically
# 12:08 <@spearce> ProjectQosFilter passes this value as minutes
# 12:08 <@spearce> to a method that accepts milliseconds
# 12:09 <@spearce> so. you get 5 milliseconds before aborting
# thus, set it to 5000minutes until the bug is fixed.
class cdk_project::review (
  $github_oauth_token               = '',
  $github_project_username          = '',
  $github_project_password          = '',
  $mysql_password                   = '',
  $mysql_root_password              = '',
  $email_private_key                = '',
  $gerritbot_password               = '',
  $ssl_cert_file_contents           = '',
  $ssl_key_file_contents            = '',
  $ssl_chain_file_contents          = '',
  $ssh_dsa_key_contents             = '',
  $ssh_dsa_pubkey_contents          = '',
  $ssh_rsa_key_contents             = '',
  $ssh_rsa_pubkey_contents          = '',
  $ssh_project_rsa_key_contents     = '',
  $ssh_project_rsa_pubkey_contents  = '',
  $lp_sync_key                      = '', # If left empty puppet will not create file.
  $lp_sync_pubkey                   = '', # If left empty puppet will not create file.
  $lp_sync_consumer_key             = '',
  $lp_sync_token                    = '',
  $lp_sync_secret                   = '',
  $contactstore_appsec              = '',
  $contactstore_pubkey              = '',
  $sysadmins                        = [],
  $swift_username                   = '',
  $swift_password                   = '',
  $ca_certs_db                      = '/vagrant/cacerts'
) {

  # Setup MySQL
  class { 'gerrit::mysql':
    mysql_root_password  => $mysql_root_password,
    database_name        => 'reviewdb',
    database_user        => 'gerrit2',
    database_password    => $mysql_password,
  } ->

  class { 'cdk_project::gerrit':
    serveradmin                     => "webmaster@${::domain}",
    ssl_cert_file                   => "/etc/ssl/certs/${::fqdn}.pem",
    ssl_key_file                    => "/etc/ssl/private/${::fqdn}.key",
    ssl_chain_file                  => '/etc/ssl/certs/intermediate.pem',

    # Create privately signed certs with orchestrator box :
    #
    ssl_cert_file_contents          => file(join([$ca_certs_db , "/ca2013/certs/${::fqdn}.crt"])),
    ssl_key_file_contents           => file(join([$ca_certs_db , "/ca2013/certs/${::fqdn}.key"])),
    ssl_chain_file_contents         => file(join([$ca_certs_db , '/ca/ca2013/chain.crt'])),

    #  These can be left empty and puppet will create it.
    ssh_dsa_key_contents            => '',
    ssh_dsa_pubkey_contents         => '',
    ssh_rsa_key_contents            => '',
    ssh_rsa_pubkey_contents         => '',
    ssh_project_rsa_key_contents    => '',
    ssh_project_rsa_pubkey_contents => '',

    email                           => "review@${::domain}",
      # 1 + 100 + 9 + 2 + 2 + 25 = 139(rounded up)
    database_poollimit              => '150',
    container_heaplimit_def         => '8g',
    core_packedgitopenfiles         => '4096',
    core_packedgitlimit             => '400m',
    core_packedgitwindowsize        => '16k',
    sshd_threads                    => '100',
    httpd_maxwait                   => '5000min',
    war                             => 'http://tarballs.openstack.org/ci/gerrit-2.4.4-14-gab7f4c1.war',
    contactstore                    => false,
    contactstore_appsec             => '',
    contactstore_pubkey             => '',
    contactstore_url                => 'http://www.openstack.org/verify/member/',
    script_user                     => 'launchpadsync',
    script_key_file                 => '/home/gerrit2/.ssh/launchpadsync_rsa',
    script_logging_conf             => '/home/gerrit2/.sync_logging.conf',
    projects_file                   => 'openstack_project/review.projects.yaml.erb',
    github_username                 => "${::domain}-gerrit",
    github_oauth_token              => '',
    github_project_username         => '',
    github_project_password         => '',
    trivial_rebase_role_id          => "trivial-rebase@review.${::domain}",
    email_private_key               => '',
    sysadmins                       => '',
    swift_username                  => '',
    swift_password                  => '',
    replication_targets             => [
      {
        name                 => 'local',
        url                  => 'file:///var/lib/git/',
        replicationDelay     => '0',
        threads              => '4',
        mirror               => true,
      }
    ],
    }

# TODO: need to figure out how we will enable bots for gerrit
# disable it for now
#  class { 'gerritbot':
#    nick       => 'openstackgerrit',
#    password   => $gerritbot_password,
#    server     => 'irc.freenode.net',
#    user       => 'gerritbot',
#    vhost_name => $::fqdn,
#  }

# need to figure out jeepy
#  include gerrit::remotes



# This section is covered by gerrit_config::connect_launchpad
  file { '/var/log/gerrit_user_sync':
    ensure  => directory,
    owner   => 'root',
    group   => 'gerrit2',
    mode    => '0775',
    require => User['gerrit2'],
  }
  file { '/home/gerrit2/.sync_logging.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'gerrit2',
    mode    => '0644',
    source  =>
      'puppet:///modules/openstack_project/gerrit/launchpad_sync_logging.conf',
    require => User['gerrit2'],
  }
  file { '/home/gerrit2/.ssh':
    ensure  => directory,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0700',
    require => User['gerrit2'],
  }
  if $lp_sync_key != '' {
    file { '/home/gerrit2/.ssh/launchpadsync_rsa':
      ensure  => present,
      owner   => 'gerrit2',
      group   => 'gerrit2',
      mode    => '0600',
      content => $lp_sync_key,
      replace => true,
      require => User['gerrit2'],
    }
  }
  if $lp_sync_pubkey != '' {
    file { '/home/gerrit2/.ssh/launchpadsync_rsa.pub':
      ensure  => present,
      owner   => 'gerrit2',
      group   => 'gerrit2',
      mode    => '0644',
      content => $lp_sync_pubkey,
      replace => true,
      require => User['gerrit2'],
    }
  }
  file { '/home/gerrit2/.launchpadlib':
    ensure  => directory,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0775',
    require => User['gerrit2'],
  }
  file { '/home/gerrit2/.launchpadlib/creds':
    ensure  => present,
    owner   => 'gerrit2',
    group   => 'gerrit2',
    mode    => '0600',
    content => template('openstack_project/gerrit_lp_creds.erb'),
    replace => true,
    require => User['gerrit2'],
  }
}
