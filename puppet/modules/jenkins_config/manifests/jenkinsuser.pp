# == Class: jenkins_config::jenkinsuser
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
class jenkins_config::jenkinsuser(
  $ssh_key = '',
  $ensure = present,
  $sudo = true,
) {

  group { 'jenkins':
    ensure => present,
  }

  if ($sudo == true) {
    $groups = ['sudo', 'admin']
  } else {
    $groups = []
  }

  user { 'jenkins':
    ensure     => present,
    comment    => 'Jenkins User',
    home       => '/home/jenkins',
    gid        => 'jenkins',
    shell      => '/bin/bash',
    membership => 'minimum',
    groups     => $groups,
    require    => Group['jenkins'],
  }

  file { '/home/jenkins':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    require => User['jenkins'],
  }

  file { '/home/jenkins/.pip':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.gitconfig':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0640',
    source  => 'puppet:///modules/jenkins/gitconfig',
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.ssh':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.ssh/authorized_keys':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0640',
    content => $ssh_key,
    require => File['/home/jenkins/.ssh'],
  }

  #NOTE: not all distributions have default bash files in /etc/skel
  if ($::osfamily == 'Debian') {

    file { '/home/jenkins/.bashrc':
      ensure  => present,
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0640',
      source  => '/etc/skel/.bashrc',
      replace => false,
      require => File['/home/jenkins'],
    }

    file { '/home/jenkins/.bash_logout':
      ensure  => present,
      source  => '/etc/skel/.bash_logout',
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0640',
      replace => false,
      require => File['/home/jenkins'],
    }

    file { '/home/jenkins/.profile':
      ensure  => present,
      source  => '/etc/skel/.profile',
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0640',
      replace => false,
      require => File['/home/jenkins'],
    }

  }

  file { '/home/jenkins/.ssh/config':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0640',
    require => File['/home/jenkins/.ssh'],
    source  => 'puppet:///modules/jenkins/ssh_config',
    replace => false,
  }

  file { '/home/jenkins/.gnupg':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0700',
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.gnupg/pubring.gpg':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
    require => File['/home/jenkins/.gnupg'],
    source  => 'puppet:///modules/jenkins/pubring.gpg',
  }

  file { '/home/jenkins/.config':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.m2':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
    require => File['/home/jenkins'],
  }

  file { '/home/jenkins/.m2/settings.xml':
    ensure  => present,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0644',
    require => File['/home/jenkins/.m2'],
    source  => 'puppet:///modules/jenkins/settings.xml',
  }

}
