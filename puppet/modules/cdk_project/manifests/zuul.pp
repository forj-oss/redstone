# == Class: openstack_project::zuul_dev
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
#
class cdk_project::zuul(
  $vhost_name           = hiera('cdk_project::zuul::vhost_name'         ,$::fqdn),
  $gerrit_url           = hiera('cdk_project::zuul::gerrit_url'         ,''),
  $gerrit_user          = hiera('cdk_project::zuul::gerrit_user'        ,'jenkins'),
  $zuul_private_key     = hiera('cdk_project::zuul::zuul_private_key'   ,''),
  $url_pattern          = hiera('cdk_project::zuul::url_pattern'        ,''),
  $zuul_url             = hiera('cdk_project::zuul::zuul_url'           ,''),
  $graphite_url         = hiera('cdk_project::zuul::graphite_url'       ,''),
  $ca_certs_db          = hiera('cdk_project::zuul::ca_certs_db'        ,'/opt/config/cacerts'),
  $zuul_revision        = hiera('cdk_project::zuul::zuul_revision'      ,'29d99b7eb1d9bbc42564006d1401f48f4b82b226'),
  $replication_urls     = hiera('cdk_project::zuul::replication_urls'   ,''),
  $sysadmins            = hiera('cdk_project::zuul::sysadmins'          ,[]),
  $gearman_workers      = hiera('cdk_project::zuul::gearman_workers'    ,[]),
) {

  if $gerrit_url == ''
  {
    $gerrit_server = read_json('gerrit','tool_url',$::json_config_location,true)
  }
  else
  {
    $gerrit_server = $gerrit_url
  }

  if $zuul_private_key == ''
  {
    $zuul_ssh_private_key = cacerts_getkey(join([$ca_certs_db , '/ssh_keys/jenkins']))
  }
  else
  {
    $zuul_ssh_private_key = $zuul_private_key
  }

  if $graphite_url == ''
  {
    $statsd_host = read_json('graphite','tool_url',$::json_config_location,true)
  }
  else
  {
    $statsd_host = $graphite_url
  }

  if $replication_urls == ''
  {
    $replication_targets = [
          {
            name => 'url1',
            url  => "ssh://${gerrit_user}@${gerrit_server}:29418/"
          }
        ]
  }
  else
  {
    $replication_targets = $replication_urls
  }

  if ( $zuul_ssh_private_key != '' )  and ( $gerrit_server != '') {
    class { '::zuul':
        vhost_name           => $vhost_name,
        gerrit_server        => $gerrit_server,
        gerrit_user          => $gerrit_user,
        zuul_ssh_private_key => $zuul_ssh_private_key,
        url_pattern          => $url_pattern,
        zuul_url             => $zuul_url,
        #push_change_refs     => true,
        job_name_in_report   => true,
        status_url           => "http://${vhost_name}", #"http://$statsd_host:8080/",
        statsd_host          => $statsd_host,
        #replication_targets  => $replication_targets,
        revision             => $zuul_revision,
    }
    class { '::zuul::server': }
    class { '::zuul::merger': }
    file { '/etc/zuul/merger-logging.conf':
      ensure => present,
      source => 'puppet:///modules/openstack_project/zuul/merger-logging.conf',
    }

    $site_instance = '50'
    apache::vhost { "zuul-${vhost_name}":
        port       => 80,
        docroot    => 'MEANINGLESS ARGUMENT',
        priority   => $site_instance,
        template   => 'cdk_project/zuul.ipv4.vhost.erb',
        servername => 'localhost',
    }
    file { '/home/zuul':
      ensure  => directory,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0500',
      require => Class['::zuul'],
    }
    file { '/home/zuul/.ssh':
      ensure  => directory,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0744',
      require => File['/home/zuul'],
    }
    cacerts::known_hosts { 'zuul':
      for_root => true,
      hostname => $gerrit_server,
      portnum  => '29418',
      require  => File['/home/zuul/.ssh'],
    }
    file { '/etc/zuul/layout.yaml':
      ensure => present,
      owner  => 'zuul',
      group  => 'root',
      mode   => '0754',
      source => 'puppet:///modules/runtime_project/zuul/config/production/layout.yaml',
      notify => Exec['zuul-restart'],
    }
    file { '/etc/zuul/openstack_functions.py':
      ensure => present,
      owner  => 'zuul',
      group  => 'root',
      mode   => '0754',
      source => 'puppet:///modules/openstack_project/zuul/openstack_functions.py',
      notify => Exec['zuul-restart'],
    }
    file { '/etc/zuul/logging.conf':
      ensure => present,
      owner  => 'zuul',
      group  => 'root',
      mode   => '0754',
      source => 'puppet:///modules/openstack_project/zuul/logging.conf',
      notify => Exec['zuul-restart'],
    }
    file { '/etc/zuul/gearman-logging.conf':
      ensure => present,
      owner  => 'zuul',
      group  => 'root',
      mode   => '0754',
      source => 'puppet:///modules/openstack_project/zuul/gearman-logging.conf',
      notify => Exec['zuul-restart'],
    }
    class { '::recheckwatch':
      gerrit_server                => $gerrit_server,
      gerrit_user                  => $gerrit_user,
      recheckwatch_ssh_private_key => $zuul_ssh_private_key,
    }
    file { '/var/lib/recheckwatch/scoreboard.html':
      ensure  => present,
      #source => 'puppet:///modules/openstack_project/zuul/scoreboard.html',
      content => template('cdk_project/status/zuul/scoreboard.html.erb'),
      require => File['/var/lib/recheckwatch'],
    }
    #Service type for zuul is not working, so we need to start zuul manually.
    exec { 'zuul-start':
      user      => 'zuul',
      command   => '/etc/init.d/zuul start',
      require   => [Class['::zuul'],
                    Class['::zuul::server'],
                    Class['::zuul::merger'],
                    Cacerts::Known_hosts['zuul'],
                    Apache::Vhost["zuul-${vhost_name}"],
                    File['/etc/zuul/layout.yaml'],
                    File['/etc/zuul/openstack_functions.py'],
                    File['/etc/zuul/logging.conf'],
                    File['/etc/zuul/gearman-logging.conf']],
      onlyif    => "test $(ps -ef | grep zuul-server | grep -v grep | wc -l) -eq 0",
      path      => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
      logoutput => true,
    }
    exec { 'zuul-merger-start':
      user      => 'zuul',
      command   => '/etc/init.d/zuul-merger start',
      require   => [Class['::zuul'],
                    Class['::zuul::server'],
                    Class['::zuul::merger'],
                    Cacerts::Known_hosts['zuul'],
                    Apache::Vhost["zuul-${vhost_name}"],
                    File['/etc/zuul/layout.yaml'],
                    File['/etc/zuul/openstack_functions.py'],
                    File['/etc/zuul/logging.conf'],
                    File['/etc/zuul/gearman-logging.conf']],
      onlyif    => "test $(ps -ef | grep zuul-merger | grep -v grep | wc -l) -eq 0",
      path      => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
      logoutput => true,
    }
    #Service type for zuul is not working, so in order to get the latest changes from the layout.yaml and zuul.conf we need to restart the service manually.
    exec { 'zuul-restart':
      user        => 'zuul',
      command     => '/etc/init.d/zuul restart',
      require     => Exec['zuul-start'],
      onlyif      => "ssh -p 29418 -i /var/lib/zuul/ssh/id_rsa ${gerrit_user}@${gerrit_server} gerrit ls-projects | grep 'tutorials'",
      subscribe   => [
          File['/etc/zuul/layout.yaml'],
          File['/etc/zuul/openstack_functions.py'],
          File['/etc/zuul/logging.conf'],
          File['/etc/zuul/gearman-logging.conf'],
        ],
      refreshonly => true,
      path        => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ]
    }
    exec { 'recheckwatch-restart':
      command => '/etc/init.d/recheckwatch restart',
      require => Exec['zuul-start'],
      onlyif  => [
                  "ssh -p 29418 -i /var/lib/zuul/ssh/id_rsa ${gerrit_user}@${gerrit_server} gerrit ls-projects | grep 'tutorials'",
                  "test $(ps -ef | grep recheckwatch | grep -v grep | wc -l) -eq 0"
                  ],
      path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ]
    }
  }
}
