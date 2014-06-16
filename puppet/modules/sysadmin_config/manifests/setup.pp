# == Class: sysadmin_config::setup
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
define sysadmin_config::setup(
            $msg                       = $title,
            $sysadmins                 = [],
            $iptables_public_tcp_ports = [],
            $iptables_rules4           = []
)
{
    # this is a workaround for dealing with existing puppet configuration in :
    # openstack_project/manifests/base.pp at line 101
    # save the puppet.conf file if one exist to /tmp/puppet.conf.cdk.bak
    # then replace it once we're done.
    # we only let puppet.conf be modified externally.

# Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" , "/usr/local/bin/"] }
#
# exec { "save puppet.conf":
#   command => "cp /etc/puppet/puppet.conf /tmp/puppet.conf.cdk.bak" ,
#   onlyif  => "test -f /etc/puppet/puppet.conf" ,
#   before  => File['/etc/puppet/puppet.conf']
# } ->

  class { '::sysadmin_config::servers' :
    iptables_public_tcp_ports => $iptables_public_tcp_ports,
    sysadmins                 => $sysadmins,
    iptables_rules4           => $iptables_rules4
  }

# ->
# exec { "restore puppet.conf":
#   command => "cp /tmp/puppet.conf.cdk.bak /etc/puppet/puppet.conf" ,
#   require => [Exec["check_/tmp/puppet.conf.cdk.bak"],]
# }
#
# exec { "check_/tmp/puppet.conf.cdk.bak":
#   command => '/usr/bin/true',
#   unless       => "/usr/bin/test -e /tmp/puppet.conf.cdk.bak",
# }

}