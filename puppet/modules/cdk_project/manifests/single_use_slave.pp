# == Class: cdk_project::single_use_slave
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
#
class cdk_project::single_use_slave (
  $certname = $::fqdn,
  $install_users = false,
  $sudo = false,
  $thin = true,
  $python3 = false,
  $include_pypy = false,
  #$automatic_upgrades = false,
  $all_mysql_privs = false,
  $enable_unbound = false,
  $install_resolv_conf = true,
  $ssh_key = '',
  $bare = false,
  $user = true,
  $do_fortify = false,
){
  class { 'sysadmin_config::servers':
    certname            => $certname,
    #automatic_upgrades  => $automatic_upgrades,
    install_users       => false,
    install_resolv_conf => $install_resolv_conf,
    enable_unbound      => $enable_unbound,
    iptables_rules4     =>
      [
        # Ports 69 and 6385 allow to allow ironic VM nodes to reach tftp and
        # the ironic API from the neutron public net
        '-p udp --dport 69 -s 172.24.4.0/24 -j ACCEPT',
        '-p tcp --dport 6385 -s 172.24.4.0/24 -j ACCEPT',
        # Ports 8000, 8003, 8004 from the devstack neutron public net to allow
        # nova servers to reach heat-api-cfn, heat-api-cloudwatch, heat-api
        '-p tcp --dport 8000 -s 172.24.4.0/24 -j ACCEPT',
        '-p tcp --dport 8003 -s 172.24.4.0/24 -j ACCEPT',
        '-p tcp --dport 8004 -s 172.24.4.0/24 -j ACCEPT',
      ],
  }
  class { 'jenkins_config::slave':
    ssh_key      => $ssh_key,
    python3      => $python3,
    sudo         => $sudo,
    bare         => $bare,
    user         => $user,
    include_pypy => $include_pypy,
    do_fortify   => $do_fortify,
  }

}
