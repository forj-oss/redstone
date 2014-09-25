# == Class: jeepyb_config
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
#TODO: need to fix upstream so we don't have to do this.
#
class jeepyb_config (
  $jeepyb_version = 'master',
  $git_source_repo = 'https://git.openstack.org/openstack-infra/jeepyb',
) {
  include mysql::python

  package { 'python-paramiko':
    ensure   => present,
  }

  package { 'gcc':
    ensure => present,
  }

  # A lot of things need yaml, be conservative requiring this package to avoid
  # conflicts with other modules.
  case $::osfamily {
    'Debian': {
      if ! defined(Package['python-yaml']) {
        package { 'python-yaml':
          ensure => present,
        }
      }
    }
    'RedHat': {
      if ! defined(Package['PyYAML']) {
        package { 'PyYAML':
          ensure => present,
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'jeepyb' module only supports osfamily Debian or RedHat.")
    }
  }

  vcsrepo { '/opt/jeepyb':
    ensure   => present,
    provider => git,
    revision => $jeepyb_version,
    source   => $git_source_repo,
  }

  exec { 'install_jeepyb' :
    command     => 'pip install /opt/jeepyb',
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    require     => Class['mysql::python'],
    subscribe   => Vcsrepo['/opt/jeepyb'],
  }
}
