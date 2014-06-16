# Class to configure graphite on a node.
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
# Takes a list of sysadmin email addresses as a parameter. Exim will be
# configured to email cron spam and other alerts to this list of admins.
class cdk_project::graphite (
  $vhost_name                       = hiera('cdk_project::graphite::vhost_name'                           ,$::fqdn),
  $sysadmins                        = hiera('cdk_project::graphite::sysadmins'                            ,[]),
  $graphite_admin_user              = hiera('cdk_project::graphite::graphite_admin_user'                  ,''),
  $graphite_admin_email             = hiera('cdk_project::graphite::graphite_admin_email'                 ,''),
  $graphite_admin_password          = hiera('cdk_project::graphite::graphite_admin_password'              ,''),
  $statsd_hosts_allowed             = hiera('cdk_project::graphite::statsd_hosts'                         ,[]),
) {
  require maestro::node_vhost_lookup
  if $statsd_hosts_allowed == []
  {
    $zuul_url = read_json('zuul','tool_url',$::json_config_location,false)
  }
  else
  {
    $statsd_hosts = $statsd_hosts_allowed
  }

  if $zuul_url != '' and $zuul_url != '#'
  {
    include apache::mod::wsgi
    class { 'graphite_config':
      graphite_admin_user     => $graphite_admin_user,
      graphite_admin_email    => $graphite_admin_email,
      graphite_admin_password => $graphite_admin_password,
    }->
    exec { "clean up /etc/apache2/sites-enabled/50-${::fqdn}.conf":
      command  => "rm -f /etc/apache2/sites-enabled/50-${::fqdn}.conf" ,
      require  => Class['graphite_config'],
      path     => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ]
    }->
    apache::vhost { "graphite-${vhost_name}":
        port          => 8080,
        docroot       => '/var/lib/graphite/webapp',
        priority      => 50,
        template      => 'cdk_project/graphite.ipv4.vhost.erb',
        servername    => 'localhost',
    }->
    exec { 'change folder permissions':
      command  => 'chown -R www-data:www-data /var/lib/graphite',
      path     => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ]
    }->
    exec { 'carbon-cache-start':
      command     => '/etc/init.d/carbon-cache start',
    }->
    exec { 'statsd-start':
      command     => '/etc/init.d/statsd start',
    }
  }
}
