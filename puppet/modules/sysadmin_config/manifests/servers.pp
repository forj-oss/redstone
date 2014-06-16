# == Class: sysadmin_config
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
# A module that deals with global sysadmin events.
# For now we utilize openstack_project::server but will also replace cdk_project::server
# We are currently doing several buried items here from openstack_project
# so this class will attempt to clean some of the changes up so they are more generic.
# as we understand it better, we may choose to drop the connection to openstack_project.
# iptable* specifies a list of ports and rules we will enforce
# sysadmins specifies a list of local users to make administrators
# certname specifies the server name to use as the /etc/puppet/puppet.conf user
# install_users specifies what local users from users.pp will be setup.  (currently disabled)
class sysadmin_config::servers (
  $iptables_public_tcp_ports = [],
  $iptables_public_udp_ports = [],
  $iptables_rules4           = [],
  $iptables_rules6           = [],
  $sysadmins                 = [],
  $certname                  = $::fqdn,
  $install_users             = false,
){
  class { 'sysadmin_config::template':
    iptables_public_tcp_ports => $iptables_public_tcp_ports,
    iptables_public_udp_ports => $iptables_public_udp_ports,
    iptables_rules4           => $iptables_rules4,
    iptables_rules6           => $iptables_rules6,
    certname                  => $certname,
    install_users             => $install_users,
  }
  #TODO: we won't be using this for now
  #class { 'exim':
  #  sysadmin => $sysadmins,
  #}

  if $::osfamily == 'Debian' {
    # Custom rsyslog config to disable /dev/xconsole noise on Debuntu servers
    file { '/etc/rsyslog.d/50-default.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  =>
        'puppet:///modules/openstack_project/rsyslog.d_50-default.conf',
      replace => true,
    }
    service { 'rsyslog':
      ensure      => running,
      hasrestart  => true,
      subscribe   => File['/etc/rsyslog.d/50-default.conf'],
    }

    # Ubuntu installs their whoopsie package by default, but it eats through
    # memory and we don't need it on servers
    package { 'whoopsie':
      ensure => absent,
    }
  }
}
