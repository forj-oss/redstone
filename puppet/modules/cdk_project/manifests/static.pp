# == Class: cdk_project::static
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
class cdk_project::static (
  $sysadmins = [],
) {

  # ::sysadmin_config::setup { 'setup static ports':
      # iptables_public_tcp_ports => [22, 80, 443],
      # sysadmins => $sysadmins,
  # }->

  #include openstack_project
  # class { 'jenkins_config::jenkinsuser':
    # ssh_key => "",
  # }

  include apache
  include apache::mod::wsgi

  a2mod { 'rewrite':
    ensure => present,
  }
#  a2mod { 'proxy':
#    ensure => present,
#  }
#  a2mod { 'proxy_http':
#    ensure => present,
#  }

  file { '/srv/static':
    ensure => directory,
  }

  # ###########################################################
  # # Tarballs
#
  # apache::vhost { 'tarballs.cdkdev.org':
    # port     => 80,
    # priority => '50',
    # docroot  => '/srv/static/tarballs',
    # require  => File['/srv/static/tarballs'],
  # }
#
  # file { '/srv/static/tarballs':
    # ensure  => directory,
    # owner   => 'jenkins',
    # group   => 'jenkins',
    # require => User['jenkins'],
  # }
#
  # ###########################################################
  # # CI
#
  # apache::vhost { 'ci.cdkdev.org':
    # port     => 80,
    # priority => '50',
    # docroot  => '/srv/static/ci',
    # require  => File['/srv/static/ci'],
  # }
#
  # file { '/srv/static/ci':
    # ensure  => directory,
    # owner   => 'jenkins',
    # group   => 'jenkins',
    # require => User['jenkins'],
  # }
#
  # ###########################################################
  # # Logs
#
  # apache::vhost { 'logs.cdkdev.org':
    # port     => 80,
    # priority => '50',
    # docroot  => '/srv/static/logs',
    # require  => File['/srv/static/logs'],
    # template => 'openstack_project/logs.vhost.erb',
  # }
#
  # apache::vhost { 'logs-dev.cdkdev.org':
    # port     => 80,
    # priority => '51',
    # docroot  => '/srv/static/logs',
    # require  => File['/srv/static/logs'],
    # template => 'openstack_project/logs-dev.vhost.erb',
  # }
#
  # file { '/srv/static/logs':
    # ensure  => directory,
    # owner   => 'jenkins',
    # group   => 'jenkins',
    # require => User['jenkins'],
  # }
#
  # file { '/srv/static/logs/robots.txt':
    # ensure  => present,
    # owner   => 'root',
    # group   => 'root',
    # mode    => '0444',
    # source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    # require => File['/srv/static/logs'],
  # }
#
  # vcsrepo { '/opt/os-loganalyze':
    # ensure   => latest,
    # provider => git,
    # revision => 'master',
    # source   => 'https://git.openstack.org/openstack-infra/os-loganalyze',
  # }
#
  # exec { 'install_os-loganalyze':
    # command     => 'python setup.py install',
    # cwd         => '/opt/os-loganalyze',
    # path        => '/bin:/usr/bin',
    # refreshonly => true,
    # subscribe   => Vcsrepo['/opt/os-loganalyze'],
  # }
#
  # # NOTE(sdague): soon to be deprecated
  # file { '/usr/local/bin/htmlify-screen-log.py':
    # ensure  => present,
    # owner   => 'root',
    # group   => 'root',
    # mode    => '0755',
    # source  => 'puppet:///modules/openstack_project/logs/htmlify-screen-log.py',
  # }
#
  # file { '/srv/static/logs/help':
    # ensure  => directory,
    # recurse => true,
    # owner   => 'root',
    # group   => 'root',
    # mode    => '0755',
    # source  => 'puppet:///modules/openstack_project/logs/help',
    # require => File['/srv/static/logs'],
  # }
#
  # file { '/usr/local/sbin/log_archive_maintenance.sh':
    # ensure => present,
    # owner  => 'root',
    # group  => 'root',
    # mode   => '0744',
    # source => 'puppet:///modules/openstack_project/log_archive_maintenance.sh',
  # }
#
  # cron { 'gziprmlogs':
    # user        => 'root',
    # minute      => '0',
    # hour        => '7',
    # weekday     => '6',
    # command     => 'bash /usr/local/sbin/log_archive_maintenance.sh',
    # environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
    # require     => File['/usr/local/sbin/log_archive_maintenance.sh'],
  # }
#
  # ###########################################################
  # # Docs-draft
#
  # apache::vhost { 'docs-draft.cdkdev.org':
    # port     => 80,
    # priority => '50',
    # docroot  => '/srv/static/docs-draft',
    # require  => File['/srv/static/docs-draft'],
  # }
#
  # file { '/srv/static/docs-draft':
    # ensure  => directory,
    # owner   => 'jenkins',
    # group   => 'jenkins',
    # require => User['jenkins'],
  # }
#
  # file { '/srv/static/docs-draft/robots.txt':
    # ensure  => present,
    # owner   => 'root',
    # group   => 'root',
    # mode    => '0444',
    # source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    # require => File['/srv/static/docs-draft'],
  # }
#
  # ###########################################################
  # # Pypi Mirror
#
  # apache::vhost { 'pypi.cdkdev.org':
    # port     => 80,
    # priority => '50',
    # docroot  => '/srv/static/pypi',
    # require  => File['/srv/static/pypi'],
  # }
#
  # file { '/srv/static/pypi':
    # ensure  => directory,
    # owner   => 'jenkins',
    # group   => 'jenkins',
    # require => User['jenkins'],
  # }
#
  # file { '/srv/static/pypi/robots.txt':
    # ensure  => present,
    # owner   => 'root',
    # group   => 'root',
    # mode    => '0444',
    # source  => 'puppet:///modules/openstack_project/disallow_robots.txt',
    # require => File['/srv/static/pypi'],
  # }
}