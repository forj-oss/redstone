# Copyright 2014 Hewlett-Packard Development Company, L.P.
# Copyright 2013 OpenStack Foundation.
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
class exim_config(
  $mailman_domains    = hiera('exim_config::mailman_domains',[]),
  $queue_interval     = hiera('exim_config::queue_interval','30m'),
  $queue_run_max      = hiera('exim_config::queue_run_max','5'),
  $queue_smtp_domains = hiera('exim_config::queue_smtp_domains',''),
  $smarthost          = hiera('exim_config::smarthost',false),
  $port               = hiera('exim_config::port',false),
  $smtp_require_auth  = hiera('exim_config::smtp_require_auth',false),
  $smtp_username      = hiera('exim_config::smtp_username',''),
  $smtp_password      = hiera('exim_config::smtp_password',''),
  $smtp_auth_driver   = hiera('exim_config::smtp_auth_driver','plaintext'),
  $smtp_public_name   = hiera('exim_config::smtp_public_name','LOGIN'),
  $relay_from_hosts   = hiera('exim_config::relay_from_hosts',['127.0.0.1']),
  $sysadmin           = hiera('exim_config::sysadmin',[]),
) {
#Important: if you specify a relay host you need to make sure that port 25 is open.

  include exim_config::params
  include exim_config::utils

  package { $::exim_config::params::package:
    ensure => present,
  }

  if ($::osfamily == 'RedHat') {
    service { 'postfix':
      ensure      => stopped
    }
    file { $::exim_config::params::sysdefault_file:
      ensure  => present,
      content => template("${module_name}/exim.sysconfig.erb"),
      group   => 'root',
      mode    => '0444',
      owner   => 'root',
      replace => true,
      require => Package[$::exim_config::params::package],
    }
  }

  if ($::osfamily == 'Debian') {
    file { $::exim_config::params::sysdefault_file:
      ensure  => present,
      content => template("${module_name}/exim4.default.erb"),
      group   => 'root',
      mode    => '0444',
      owner   => 'root',
      replace => true,
      require => Package[$::exim_config::params::package],
    }
  }

  service { 'exim':
    ensure     => running,
    name       => $::exim_config::params::service_name,
    hasrestart => true,
    subscribe  => [File[$::exim_config::params::config_file],
                    File[$::exim_config::params::sysdefault_file]],
    require    => Package[$::exim_config::params::package],
  }

  file { $::exim_config::params::config_file:
    ensure  => present,
    content => template("${module_name}/exim4.conf.erb"),
    group   => 'root',
    mode    => '0444',
    owner   => 'root',
    replace => true,
    require => [Package[$::exim_config::params::package],
                Class['::exim_config::utils']],
  }

  file { '/etc/aliases':
    ensure  => present,
    content => template("${module_name}/aliases.erb"),
    group   => 'root',
    mode    => '0444',
    owner   => 'root',
    replace => true,
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
