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
# == Class: cdk_project::nodepool
#
class cdk_project::nodepool(
  $vhost_name                       = hiera('cdk_project::nodepool::vhost_name'                       , $::fqdn),
  $mysql_password                   = hiera('cdk_project::nodepool::mysql_password'                   , ''),
  $mysql_root_password              = hiera('cdk_project::nodepool::mysql_root_password'              , ''),
  $nodepool_ssh_private_key         = hiera('cdk_project::nodepool::nodepool_ssh_private_key'         , ''),
  $nodepool_template                = hiera('cdk_project::nodepool::nodepool_template'                , 'nodepool.yaml.erb'),
  $sysadmins                        = hiera('cdk_project::nodepool::sysadmins'                        , []),
  $statsd_host                      = hiera('cdk_project::nodepool::statsd_host'                      , ''),
  $jenkins_api_user                 = hiera('cdk_project::nodepool::jenkins_api_user'                 , ''),
  $jenkins_api_key                  = hiera('cdk_project::nodepool::jenkins_api_key'                  , ''),
  $jenkins_credentials_id           = hiera('cdk_project::nodepool::jenkins_credentials_id'           , ''),
  $rackspace_username               = hiera('cdk_project::nodepool::rackspace_username'               , ''),
  $rackspace_password               = hiera('cdk_project::nodepool::rackspace_password'               , ''),
  $rackspace_project                = hiera('cdk_project::nodepool::rackspace_project'                , ''),
  $hpcloud_username                 = hiera('cdk_project::nodepool::hpcloud_username'                 , ''),
  $hpcloud_password                 = hiera('cdk_project::nodepool::hpcloud_password'                 , ''),
  $hpcloud_project                  = hiera('cdk_project::nodepool::hpcloud_project'                  , ''),
  $tripleo_username                 = hiera('cdk_project::nodepool::tripleo_username'                 , ''),
  $tripleo_password                 = hiera('cdk_project::nodepool::tripleo_password'                 , ''),
  $tripleo_project                  = hiera('cdk_project::nodepool::tripleo_project'                  , ''),
  $image_log_document_root          = hiera('cdk_project::nodepool::image_log_document_root'          , '/var/log/nodepool/image'),
  $enable_image_log_via_http        = hiera('cdk_project::nodepool::image_log_via_http'               , false),
  $environment                      = hiera_hash('cdk_project::nodepool::environment'                 , {}),
) {
#  class { 'openstack_project::server':
#    sysadmins                 => $sysadmins,
#    iptables_public_tcp_ports => [80],
#  }

  class { '::nodepool':
    vhost_name                => $vhost_name,
    mysql_root_password       => $mysql_root_password,
    mysql_password            => $mysql_password,
    nodepool_ssh_private_key  => $nodepool_ssh_private_key,
    statsd_host               => $statsd_host,
    image_log_document_root   => $image_log_document_root,
    enable_image_log_via_http => $enable_image_log_via_http,
    environment               => $environment,
  }

  file { '/etc/nodepool/nodepool.yaml':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'root',
    mode    => '0400',
    content => template("runtime_project/nodepool/${nodepool_template}"),
    require => [
      File['/etc/nodepool'],
      User['nodepool'],
    ],
  }

  file { '/etc/nodepool/scripts':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    require => File['/etc/nodepool'],
    source  => 'puppet:///modules/runtime_project/nodepool/scripts',
  }

}
