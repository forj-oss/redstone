# == Class: openstack_project::template
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
# A template host with no running services
#
class sysadmin_config::template (
  $iptables_public_tcp_ports = [],
  $iptables_public_udp_ports = [],
  $iptables_rules4           = [],
  $iptables_rules6           = [],
  $install_users = true,
  $certname = $::fqdn
) {
  include ssh
  include snmpd
  include openstack_project::automatic_upgrades

  class { 'iptables':
    public_tcp_ports => $iptables_public_tcp_ports,
    public_udp_ports => $iptables_public_udp_ports,
    rules4           => $iptables_rules4,
    rules6           => $iptables_rules6,
  }

  class { 'ntp': }

  class { 'sysadmin_config::base':
    install_users => $install_users,
    certname      => $certname,
  }

  package { 'strace':
    ensure => present,
  }

  package { 'tcpdump':
    ensure => present,
  }
}
