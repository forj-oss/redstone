# == Class: jeepyb_config::openstackwatch
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

class jeepyb_config::openstackwatch(
  $swift_username = '',
  $swift_password = '',
  $swift_auth_url = '',
  $auth_version = '',
  $projects = [],
  $mode = 'multiple',
  $container = 'rss',
  $feed = '',
  $json_url = '',
  $minute = '18',
  $hour = '*',
  $jeepyb_version  = hiera('jeepyb_config::jeepyb_version',undef),
) {
  if ($jeepyb_version != undef)
  {
    if !defined(Class['jeepyb_config'])
    {
      class { 'jeepyb_config':
        jeepyb_version => $jeepyb_version,
      }
    }
  }
  else
  {
    include jeepyb_config
  }

  group { 'openstackwatch':
    ensure => present,
  }

  user { 'openstackwatch':
    ensure     => present,
    managehome => true,
    comment    => 'OpenStackWatch User',
    shell      => '/bin/bash',
    gid        => 'openstackwatch',
    require    => Group['openstackwatch'],
  }

  if $swift_password != '' {
    cron { 'openstackwatch':
      ensure  => present,
      command => '/usr/local/bin/openstackwatch /home/openstackwatch/openstackwatch.ini',
      minute  => $minute,
      hour    => $hour,
      user    => 'openstackwatch',
      require => [
        File['/home/openstackwatch/openstackwatch.ini'],
        User['openstackwatch'],
        Class['jeepyb_config'],
      ],
    }
  }

  file { '/home/openstackwatch/openstackwatch.ini':
    ensure  => present,
    content => template('jeepyb_config/openstackwatch.ini.erb'),
    owner   => 'root',
    group   => 'openstackwatch',
    mode    => '0640',
    require => User['openstackwatch'],
  }

  if ! defined(Package['python-pyrss2gen']) {
    package { 'python-pyrss2gen':
      ensure => present,
    }
  }

  if ! defined(Package['python-swiftclient']) {
    package { 'python-swiftclient':
      ensure   => latest,
      provider => pip2,
      require  => Class['pip::python2'],
    }
  }
}
