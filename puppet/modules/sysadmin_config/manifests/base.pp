# == Class: openstack_project::base
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
class sysadmin_config::base(
  $certname           = $::fqdn,
  $install_users      = true,
  $do_puppet_defaults = false,
) {
  if ($::osfamily == 'Debian') {
    include apt
  }
  include openstack_project::params
  include sysadmin_config::users
  include sudoers

  file { '/etc/profile.d/Z98-byobu.sh':
    ensure => absent,
  }

  package { 'popularity-contest':
    ensure => purged,
  }

  if ($::lsbdistcodename == 'oneiric') {
    apt::ppa { 'ppa:git-core/ppa': }
    package { 'git':
      ensure  => latest,
      require => Apt::Ppa['ppa:git-core/ppa'],
    }
  } else {
    package { 'git':
      ensure => present,
    }
  }

  if ($::operatingsystem == 'Fedora') {

    package { 'hiera':
      ensure   => latest,
      provider => 'gem',
    }

    exec { 'symlink hiera modules' :
      command     => 'ln -s /usr/local/share/gems/gems/hiera-puppet-* /etc/puppet/modules/',
      path        => '/bin:/usr/bin',
      subscribe   => Package['hiera'],
      refreshonly => true,
    }

  }

  sysadmin_config::base_install_package{$::openstack_project::params::packages:}

  include pip::python2
  $pip_provider = pip2
  $pip_class    = 'pip::python2'

  package { 'virtualenv':
    ensure   => latest,
    provider => $pip_provider,
    require  => Class[$pip_class],
  }

  if ($install_users) {
    package { $::openstack_project::params::user_packages:
      ensure => present
    }
  }

  # Use upstream puppet and pin to version 2.7.*
  if ($::osfamily == 'Debian') {
    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com',
      repos      => 'main',
      key        => '4BD6EC30',
      key_server => 'pgp.mit.edu',
    }

    file { '/etc/apt/preferences.d/00-puppet.pref':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      source  => 'puppet:///modules/openstack_project/00-puppet.pref',
      replace => true,
    }

  }
  if ($do_puppet_defaults)
  {
    file { '/etc/puppet/puppet.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      content => template('openstack_project/puppet.conf.erb'),
      replace => true,
    }
  }

}

# vim:sw=2:ts=2:expandtab:textwidth=79
