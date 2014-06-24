# == Class: github_config
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
class github_config(
  $username = '',
  $oauth_token = '',
  $project_username = '',
  $project_password = '',
  $projects = []
) {
#  include jeepyb
  include pip::python2

  if ! defined(Package['PyGithub']) {
    package { 'PyGithub':
      ensure   => latest,  # okay to use latest for pip
      provider => pip2,
      require  => Class['pip::python2'],
    }
  }

  # A lot of things need yaml, be conservative requiring this package to avoid
  # conflicts with other modules.
  if ! defined(Package['python-yaml']) {
    package { 'python-yaml':
      ensure => present,
    }
  }

  group { 'github':
    ensure => present,
  }

  user { 'github':
    ensure  => present,
    comment => 'Github API User',
    shell   => '/bin/bash',
    gid     => 'github',
    require => Group['github'],
  }

  file { '/etc/github':
    ensure => directory,
    group  => 'root',
    mode   => '0755',
    owner  => 'root',
  }

  file { '/etc/github/github.config':
    ensure => absent,
  }

  file { '/etc/github/github.secure.config':
    ensure  => present,
    content => template('github/github.secure.config.erb'),
    group   => 'github',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => [
      Group['github'],
      File['/etc/github'],
    ],
  }

  file { '/etc/github/github-projects.secure.config':
    ensure  => present,
    content => template('github/github-projects.secure.config.erb'),
    group   => 'github',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => [
      Group['github'],
      File['/etc/github'],
    ],
  }

  file { '/usr/local/github':
    ensure => directory,
    group  => 'root',
    mode   => '0755',
    owner  => 'root',
  }

  file { '/usr/local/github/scripts':
    ensure  => absent,
  }

  cron { 'githubclosepull':
    command => 'sleep $((RANDOM\%60+90)) && /usr/local/bin/close-pull-requests',
    minute  => '*/5',
    require => [
      Class['jeepyb_config'],
      Package['python-yaml'],
      Package['PyGithub'],
    ],
    user    => github,
  }
}