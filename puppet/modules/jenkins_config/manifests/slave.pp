# == Class: jenkins_config::slave
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
class jenkins_config::slave(
  $ssh_key      = '',
  $sudo         = false,
  $bare         = false,
  $user         = true,
  $python3      = false,
  $include_pypy = false,
  $do_fortify   = false,
) {

  include jenkins_config::params

  if ($user == true) {
    if ! defined(Class['jenkins_config::jenkinsuser'])
    {
      class { 'jenkins_config::jenkinsuser':
        ensure  => present,
        sudo    => $sudo,
        ssh_key => $ssh_key,
      }
    }
  }

  if ($bare == false) {
    $dostandard = true
  }

  class { 'compiler_tools':
      install_fortify      => $do_fortify,
      install_common       => true,
      install_dblibs       => $dostandard,
      install_docs         => $dostandard,
      install_lispdev      => $dostandard,
      install_maven        => true,
      install_rubydev      => true,
      install_zookeeper    => true,
      install_puppetlint   => $dostandard,
      install_gittools     => true,
      install_jenkinstools => true,
      install_pypy         => $include_pypy,
      install_python3      => $python3,
    }

  # Temporary for debugging glance launch problem
  # https://lists.launchpad.net/openstack/msg13381.html
  # NOTE(dprince): ubuntu only as RHEL6 doesn't have sysctl.d yet
  if ($::osfamily == 'Debian') {
    file { '/etc/sysctl.d/10-ptrace.conf':
      ensure => present,
      source => 'puppet:///modules/jenkins/10-ptrace.conf',
      owner  => 'root',
      group  => 'root',
      mode   => '0444',
    }

    exec { 'ptrace sysctl':
      subscribe   => File['/etc/sysctl.d/10-ptrace.conf'],
      refreshonly => true,
      command     => '/sbin/sysctl -p /etc/sysctl.d/10-ptrace.conf',
    }
  }
}
