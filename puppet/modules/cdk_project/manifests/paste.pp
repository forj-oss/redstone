# == Class: cdk_project::paste
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
# forked from openstack_project::paste for customization
#
class cdk_project::paste (
  $vhost_name     = hiera('cdk_project::paste::vhost_name'        ,$::fqdn),
  $sysadmins      = hiera('cdk_project::paste::sysadmins'         ,[]),
  $site_name      = hiera('cdk_project::paste::site_name'         ,'cdkdev'),
  $image_name     = hiera('cdk_project::paste::image_name'        ,'header-bg2.png'),
  $image_source   = hiera('cdk_project::paste::image_source'      ,'puppet:///modules/lodgeit/header-bg2.png'),
  $serveraliases  = hiera('cdk_project::paste::serveraliases'     ,''),
) {
  require maestro::node_vhost_lookup
  include lodgeit
  if ($vhost_name != '')
  {
    lodgeit_config::site { $site_name:
      port          => '5000',
      image         => $image_name,
      image_source  => $image_source,
      vhost_name    => $vhost_name,
      serveraliases => $serveraliases,
    }
  } else {
    lodgeit_config::site { $site_name:
      port         => '5000',
      image        => $image_name,
      image_source => $image_source,
      serveraliase => $serveraliases,
    }
  }


  lodgeit::site { 'drizzle':
    port => '5001',
  }
}
