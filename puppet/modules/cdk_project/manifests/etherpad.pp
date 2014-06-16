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

class cdk_project::etherpad (
  $mysql_password          = undef,
  $ssl_cert_file_contents  = '',
  $ssl_key_file_contents   = '',
  $ssl_chain_file_contents = '',
  $mysql_host              = 'localhost',
  $mysql_user              = 'eplite',
  $mysql_db_name           = 'etherpad-lite',
  $sysadmins               = []
) {
  #class { 'openstack_project::server':
  #  iptables_public_tcp_ports => [22, 80, 443],
  #  sysadmins                 => $sysadmins
  #}

  include etherpad_lite

  class { 'etherpad_config::apache':
    ssl_cert_file           => '',
    ssl_key_file            => '',
    ssl_chain_file          => '',
    ssl_cert_file_contents  => $ssl_cert_file_contents,
    ssl_key_file_contents   => $ssl_key_file_contents,
    ssl_chain_file_contents => $ssl_chain_file_contents,
  }

  class { 'etherpad_lite::site':
    database_host     => $mysql_host,
    database_user     => $mysql_user,
    database_name     => $mysql_db_name,
    database_password => $mysql_password,
  }

  etherpad_lite::plugin { 'ep_headings':
    require => Class['etherpad_lite'],
  }

  mysql_backup::backup_remote { 'etherpad-lite':
    database_host     => $mysql_host,
    database_user     => $mysql_user,
    database_password => $mysql_password,
    require           => Class['etherpad_lite'],
  }

  include bup
  bup::site { 'rs-ord':
    backup_user   => 'bup-etherpad',
    backup_server => 'ci-backup-rs-ord.openstack.org',
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
