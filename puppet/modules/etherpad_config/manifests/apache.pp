# == Class: etherpad_lite::apache
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
class etherpad_config::apache (
  $vhost_name = $::fqdn,
  $ssl_cert_file = '',
  $ssl_key_file = '',
  $ssl_chain_file = '',
  $ssl_cert_file_contents = '', # If left empty puppet will not create file.
  $ssl_key_file_contents = '', # If left empty puppet will not create file.
  $ssl_chain_file_contents = '' # If left empty puppet will not create file.
) {

  package { 'ssl-cert':
    ensure => present,
  }

  include apache
  apache::vhost { 'etherpad-$vhost_name':
    port     => 443,
    docroot  => 'MEANINGLESS ARGUMENT',
    priority => '50',
    template => 'cdk_project/etherpadlite.vhost.erb',
    ssl      => true,
  }
  a2mod { 'rewrite':
    ensure => present,
  }
#  a2mod { 'proxy':
#    ensure => present,
#  }
#  a2mod { 'proxy_http':
#    ensure => present,
#  }
  file { '/etc/apache2/conf.d/connection-tuning':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/etherpad_lite/apache-connection-tuning',
    notify  => Service['httpd'],
  }

  file { '/etc/ssl/certs':
    ensure => directory,
    owner  => 'root',
    mode   => '0755',
  }

  file { '/etc/ssl/private':
    ensure => directory,
    owner  => 'root',
    mode   => '0700',
  }

  if $ssl_cert_file_contents != '' {
    file { $ssl_cert_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_cert_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }

  if $ssl_key_file_contents != '' {
    file { $ssl_key_file:
      owner   => 'root',
      group   => 'ssl-cert',
      mode    => '0640',
      content => $ssl_key_file_contents,
      require => Package['ssl-cert'],
      before  => Apache::Vhost[$vhost_name],
    }
  }

  if $ssl_chain_file_contents != '' {
    file { $ssl_chain_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_chain_file_contents,
      before  => Apache::Vhost[$vhost_name],
    }
  }
}
